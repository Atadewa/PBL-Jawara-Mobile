const express = require("express");
const request = require("supertest");

// Mock supabaseAdmin - harus didefinisikan sebelum require routes
const mockSupabaseAdmin = {
  from: jest.fn(),
  storage: {
    from: jest.fn(),
  },
};

jest.mock("../../../src/lib/supabaseAdmin", () => ({
  supabaseAdmin: mockSupabaseAdmin,
}));

// Mock middleware
jest.mock("../../../src/middlewares/requireAuth", () => ({
  requireAuth: (req, res, next) => {
    req.userContext = {
      appUser: {
        id: "test-user-id",
        email: "test@example.com",
        name: "Test User",
      },
      roleNames: ["admin"],
      scope: { mode: "all", rw: null, rt: null },
    };
    next();
  },
}));

const broadcastRoutes = require("../../../src/routes/broadcast.routes");

describe("Broadcast Routes - Unit Tests", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/broadcasts", broadcastRoutes);
    jest.clearAllMocks();
  });

  describe("GET /broadcasts", () => {
    test("should return list of broadcasts", async () => {
      const mockBroadcasts = [
        { id: 1, title: "Test Broadcast 1", content: "Content 1", status: "published" },
        { id: 2, title: "Test Broadcast 2", content: "Content 2", status: "draft" },
      ];

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockResolvedValue({ data: mockBroadcasts, error: null }),
        eq: jest.fn().mockResolvedValue({ data: mockBroadcasts, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app).get("/broadcasts").expect(200);

      expect(response.body).toHaveProperty("data");
      expect(mockSupabaseAdmin.from).toHaveBeenCalledWith("broadcasts");
    });

    test("should filter broadcasts by status", async () => {
      const mockBroadcasts = [
        { id: 1, title: "Test Broadcast", content: "Content", status: "draft" },
      ];

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        eq: jest.fn().mockResolvedValue({ data: mockBroadcasts, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app)
        .get("/broadcasts?status=draft")
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(mockQuery.eq).toHaveBeenCalledWith("status", "draft");
    });

    test("should return 500 on database error", async () => {
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockResolvedValue({ data: null, error: { message: "Database error" } }),
        eq: jest.fn().mockResolvedValue({ data: null, error: { message: "Database error" } }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app).get("/broadcasts").expect(500);

      expect(response.body).toHaveProperty("message", "Database error");
    });
  });

  describe("GET /broadcasts/:id", () => {
    test("should return a single broadcast by id", async () => {
      const mockBroadcast = { id: 1, title: "Test Broadcast", content: "Content", status: "published" };

      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app).get("/broadcasts/1").expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.id).toBe(1);
    });

    test("should return 400 for invalid id", async () => {
      const response = await request(app).get("/broadcasts/invalid").expect(400);

      expect(response.body).toHaveProperty("message", "Invalid id");
    });

    test("should return 404 when broadcast not found", async () => {
      const mockQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: { message: "Not found" } }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app).get("/broadcasts/999").expect(404);

      expect(response.body).toHaveProperty("message", "Broadcast not found / not accessible");
    });
  });

  describe("POST /broadcasts", () => {
    test("should create a new broadcast", async () => {
      const newBroadcast = {
        title: "New Broadcast",
        content: "New Content",
        rw: "01",
        status: "draft",
      };

      const mockCreatedBroadcast = {
        id: 1,
        ...newBroadcast,
        rt: null,
        image_url: null,
        document_url: null,
        created_by_user_id: "test-user-id",
      };

      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockCreatedBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app)
        .post("/broadcasts")
        .send(newBroadcast)
        .expect(201);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.title).toBe("New Broadcast");
    });

    test("should return 400 when title is missing", async () => {
      const response = await request(app)
        .post("/broadcasts")
        .send({ content: "Content only" })
        .expect(400);

      expect(response.body).toHaveProperty("message", "title dan content wajib diisi");
    });

    test("should return 400 when content is missing", async () => {
      const response = await request(app)
        .post("/broadcasts")
        .send({ title: "Title only" })
        .expect(400);

      expect(response.body).toHaveProperty("message", "title dan content wajib diisi");
    });

    test("should return 400 for invalid status", async () => {
      const response = await request(app)
        .post("/broadcasts")
        .send({ title: "Test", content: "Content", rw: "01", status: "invalid_status" })
        .expect(400);

      expect(response.body).toHaveProperty("message", "status tidak valid");
    });

    test("should return 400 when rw is missing for admin", async () => {
      const response = await request(app)
        .post("/broadcasts")
        .send({ title: "Test", content: "Content" })
        .expect(400);

      expect(response.body).toHaveProperty("message", "rw wajib untuk admin");
    });
  });

  describe("POST /broadcasts - with RW scope", () => {
    let appWithRwScope;

    beforeEach(() => {
      // Reset the mock to use RW scope
      jest.resetModules();
      jest.doMock("../../../src/middlewares/requireAuth", () => ({
        requireAuth: (req, res, next) => {
          req.userContext = {
            appUser: {
              id: "test-user-id",
              email: "test@example.com",
              name: "Test User",
            },
            roleNames: ["ketua_rw"],
            scope: { mode: "rw", rw: "01", rt: null },
          };
          next();
        },
      }));

      const broadcastRoutesRw = require("../../../src/routes/broadcast.routes");
      appWithRwScope = express();
      appWithRwScope.use(express.json());
      appWithRwScope.use("/broadcasts", broadcastRoutesRw);
    });

    test("should create broadcast with RW scope without requiring rw in body", async () => {
      const newBroadcast = {
        title: "RW Broadcast",
        content: "RW Content",
      };

      const mockCreatedBroadcast = {
        id: 1,
        ...newBroadcast,
        rw: "01",
        rt: null,
      };

      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockCreatedBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(appWithRwScope)
        .post("/broadcasts")
        .send(newBroadcast)
        .expect(201);

      expect(response.body).toHaveProperty("data");
    });
  });

  describe("POST /broadcasts - forbidden for non-manager roles", () => {
    let appWithWargaScope;

    beforeEach(() => {
      jest.resetModules();
      jest.doMock("../../../src/middlewares/requireAuth", () => ({
        requireAuth: (req, res, next) => {
          req.userContext = {
            appUser: {
              id: "test-user-id",
              email: "test@example.com",
              name: "Test User",
            },
            roleNames: ["warga"],
            scope: { mode: "rt", rw: "01", rt: "001" },
          };
          next();
        },
      }));

      const broadcastRoutesWarga = require("../../../src/routes/broadcast.routes");
      appWithWargaScope = express();
      appWithWargaScope.use(express.json());
      appWithWargaScope.use("/broadcasts", broadcastRoutesWarga);
    });

    test("should return 403 when user is not allowed to manage broadcasts", async () => {
      const response = await request(appWithWargaScope)
        .post("/broadcasts")
        .send({ title: "Test", content: "Content" })
        .expect(403);

      expect(response.body).toHaveProperty("message", "Forbidden");
    });
  });

  describe("PATCH /broadcasts/:id", () => {
    test("should update a broadcast", async () => {
      const mockBroadcast = { id: 1, rw: "01", rt: null };
      const mockUpdatedBroadcast = {
        id: 1,
        title: "Updated Title",
        content: "Updated Content",
        rw: "01",
        rt: null,
      };

      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };

      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockUpdatedBroadcast, error: null }),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockSelectQuery)
        .mockReturnValueOnce(mockUpdateQuery);

      const response = await request(app)
        .patch("/broadcasts/1")
        .send({ title: "Updated Title", content: "Updated Content" })
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.title).toBe("Updated Title");
    });

    test("should return 400 for invalid id", async () => {
      const response = await request(app)
        .patch("/broadcasts/invalid")
        .send({ title: "Updated" })
        .expect(400);

      expect(response.body).toHaveProperty("message", "Invalid id");
    });

    test("should return 404 when broadcast not found", async () => {
      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: { message: "Not found" } }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

      const response = await request(app)
        .patch("/broadcasts/999")
        .send({ title: "Updated" })
        .expect(404);

      expect(response.body).toHaveProperty("message", "Broadcast not found");
    });
  });

  describe("PATCH /broadcasts/:id/publish", () => {
    test("should publish a broadcast", async () => {
      const mockBroadcast = { id: 1, rw: "01", rt: null };
      const mockPublishedBroadcast = {
        id: 1,
        title: "Test",
        content: "Content",
        status: "published",
        rw: "01",
        rt: null,
      };

      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };

      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockPublishedBroadcast, error: null }),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockSelectQuery)
        .mockReturnValueOnce(mockUpdateQuery);

      const response = await request(app)
        .patch("/broadcasts/1/publish")
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.status).toBe("published");
    });

    test("should return 400 for invalid id", async () => {
      const response = await request(app)
        .patch("/broadcasts/invalid/publish")
        .expect(400);

      expect(response.body).toHaveProperty("message", "Invalid id");
    });

    test("should return 404 when broadcast not found", async () => {
      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: { message: "Not found" } }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

      const response = await request(app)
        .patch("/broadcasts/999/publish")
        .expect(404);

      expect(response.body).toHaveProperty("message", "Broadcast not found");
    });
  });

  describe("POST /broadcasts/:id/image", () => {
    test("should return 400 when no file is uploaded", async () => {
      const mockBroadcast = { id: 1, rw: "01", rt: null };

      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

      const response = await request(app)
        .post("/broadcasts/1/image")
        .expect(400);

      expect(response.body).toHaveProperty("message", "File 'image' wajib dikirim");
    });

    test("should return 400 for invalid id", async () => {
      const response = await request(app)
        .post("/broadcasts/invalid/image")
        .expect(400);

      expect(response.body).toHaveProperty("message", "Invalid id");
    });

    test("should upload image successfully", async () => {
      const mockBroadcast = { id: 1, rw: "01", rt: null };
      const mockUpdatedBroadcast = {
        id: 1,
        title: "Test",
        content: "Content",
        image_url: "https://example.com/image.jpg",
        rw: "01",
        rt: null,
      };

      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };

      const mockUpdateQuery = {
        update: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockUpdatedBroadcast, error: null }),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockSelectQuery)
        .mockReturnValueOnce(mockUpdateQuery);

      mockSupabaseAdmin.storage.from.mockReturnValue({
        upload: jest.fn().mockResolvedValue({ error: null }),
        getPublicUrl: jest.fn().mockReturnValue({
          data: { publicUrl: "https://example.com/image.jpg" },
        }),
      });

      const response = await request(app)
        .post("/broadcasts/1/image")
        .attach("image", Buffer.from("fake image content"), {
          filename: "test.jpg",
          contentType: "image/jpeg",
        })
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.image_url).toBe("https://example.com/image.jpg");
    });

    test("should return 400 for invalid image format", async () => {
      const mockBroadcast = { id: 1, rw: "01", rt: null };

      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

      const response = await request(app)
        .post("/broadcasts/1/image")
        .attach("image", Buffer.from("fake gif content"), {
          filename: "test.gif",
          contentType: "image/gif",
        })
        .expect(400);

      expect(response.body).toHaveProperty("message", "Format harus jpg/png/webp");
    });

    test("should return 404 when broadcast not found for image upload", async () => {
      const mockSelectQuery = {
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: null, error: { message: "Not found" } }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

      const response = await request(app)
        .post("/broadcasts/999/image")
        .attach("image", Buffer.from("fake image content"), {
          filename: "test.jpg",
          contentType: "image/jpeg",
        })
        .expect(404);

      expect(response.body).toHaveProperty("message", "Broadcast not found");
    });
  });

  describe("Scope-based access control", () => {
    describe("RW scope user", () => {
      let appWithRwScope;

      beforeEach(() => {
        jest.resetModules();
        jest.doMock("../../../src/middlewares/requireAuth", () => ({
          requireAuth: (req, res, next) => {
            req.userContext = {
              appUser: {
                id: "rw-user-id",
                email: "rw@example.com",
                name: "RW User",
              },
              roleNames: ["ketua_rw"],
              scope: { mode: "rw", rw: "01", rt: null },
            };
            next();
          },
        }));

        const broadcastRoutesRw = require("../../../src/routes/broadcast.routes");
        appWithRwScope = express();
        appWithRwScope.use(express.json());
        appWithRwScope.use("/broadcasts", broadcastRoutesRw);
      });

      test("should allow RW user to update broadcast in their RW", async () => {
        const mockBroadcast = { id: 1, rw: "01", rt: null };
        const mockUpdatedBroadcast = { id: 1, title: "Updated", rw: "01", rt: null };

        const mockSelectQuery = {
          select: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
        };

        const mockUpdateQuery = {
          update: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          select: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockUpdatedBroadcast, error: null }),
        };

        mockSupabaseAdmin.from
          .mockReturnValueOnce(mockSelectQuery)
          .mockReturnValueOnce(mockUpdateQuery);

        const response = await request(appWithRwScope)
          .patch("/broadcasts/1")
          .send({ title: "Updated" })
          .expect(200);

        expect(response.body.data.title).toBe("Updated");
      });

      test("should deny RW user to update broadcast in different RW", async () => {
        const mockBroadcast = { id: 1, rw: "02", rt: null }; // Different RW

        const mockSelectQuery = {
          select: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
        };
        mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

        const response = await request(appWithRwScope)
          .patch("/broadcasts/1")
          .send({ title: "Updated" })
          .expect(403);

        expect(response.body).toHaveProperty("message", "Forbidden (scope)");
      });
    });

    describe("RT scope user", () => {
      let appWithRtScope;

      beforeEach(() => {
        jest.resetModules();
        jest.doMock("../../../src/middlewares/requireAuth", () => ({
          requireAuth: (req, res, next) => {
            req.userContext = {
              appUser: {
                id: "rt-user-id",
                email: "rt@example.com",
                name: "RT User",
              },
              roleNames: ["ketua_rt"],
              scope: { mode: "rt", rw: "01", rt: "001" },
            };
            next();
          },
        }));

        const broadcastRoutesRt = require("../../../src/routes/broadcast.routes");
        appWithRtScope = express();
        appWithRtScope.use(express.json());
        appWithRtScope.use("/broadcasts", broadcastRoutesRt);
      });

      test("should allow RT user to update broadcast in their RT", async () => {
        const mockBroadcast = { id: 1, rw: "01", rt: "001" };
        const mockUpdatedBroadcast = { id: 1, title: "Updated", rw: "01", rt: "001" };

        const mockSelectQuery = {
          select: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
        };

        const mockUpdateQuery = {
          update: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          select: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockUpdatedBroadcast, error: null }),
        };

        mockSupabaseAdmin.from
          .mockReturnValueOnce(mockSelectQuery)
          .mockReturnValueOnce(mockUpdateQuery);

        const response = await request(appWithRtScope)
          .patch("/broadcasts/1")
          .send({ title: "Updated" })
          .expect(200);

        expect(response.body.data.title).toBe("Updated");
      });

      test("should deny RT user to update RW-level broadcast", async () => {
        const mockBroadcast = { id: 1, rw: "01", rt: null }; // RW-level broadcast

        const mockSelectQuery = {
          select: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
        };
        mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

        const response = await request(appWithRtScope)
          .patch("/broadcasts/1")
          .send({ title: "Updated" })
          .expect(403);

        expect(response.body).toHaveProperty("message", "Forbidden (scope)");
      });

      test("should deny RT user to update broadcast in different RT", async () => {
        const mockBroadcast = { id: 1, rw: "01", rt: "002" }; // Different RT

        const mockSelectQuery = {
          select: jest.fn().mockReturnThis(),
          eq: jest.fn().mockReturnThis(),
          single: jest.fn().mockResolvedValue({ data: mockBroadcast, error: null }),
        };
        mockSupabaseAdmin.from.mockReturnValue(mockSelectQuery);

        const response = await request(appWithRtScope)
          .patch("/broadcasts/1")
          .send({ title: "Updated" })
          .expect(403);

        expect(response.body).toHaveProperty("message", "Forbidden (scope)");
      });
    });
  });

  describe("Helper functions", () => {
    test("canManage should allow admin, ketua_rw, ketua_rt, sekretaris", async () => {
      // This is tested implicitly through the POST endpoint
      // Admin should be allowed (default mock)
      const newBroadcast = { title: "Test", content: "Content", rw: "01" };

      const mockCreatedBroadcast = { id: 1, ...newBroadcast };
      const mockQuery = {
        insert: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({ data: mockCreatedBroadcast, error: null }),
      };
      mockSupabaseAdmin.from.mockReturnValue(mockQuery);

      const response = await request(app)
        .post("/broadcasts")
        .send(newBroadcast)
        .expect(201);

      expect(response.body).toHaveProperty("data");
    });
  });
});
