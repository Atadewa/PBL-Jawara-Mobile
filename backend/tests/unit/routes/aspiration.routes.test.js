const express = require("express");
const request = require("supertest");

// Create mock function that returns chainable object
const createMockChain = (finalResult) => {
  const chain = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    in: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    single: jest.fn(),
  };
  
  if (finalResult) {
    chain.single.mockResolvedValue(finalResult);
    chain.order.mockResolvedValue(finalResult);
  }
  
  return chain;
};

// Mock supabaseAdmin sebelum import routes
jest.mock("../../../src/lib/supabaseAdmin", () => ({
  supabaseAdmin: createMockChain(),
}));

const aspirationRoutes = require("../../../src/routes/aspiration.routes");
const { supabaseAdmin } = require("../../../src/lib/supabaseAdmin");

// Mock middleware requireAuth
jest.mock("../../../src/middlewares/requireAuth", () => ({
  requireAuth: (req, res, next) => {
    req.userContext = {
      appUser: { id: "test-user-id", resident_id: 1 },
      roleNames: ["admin"],
      scope: { mode: "all", rw: null, rt: null },
    };
    next();
  },
}));

describe("Aspiration Routes - Unit Tests", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/aspirations", aspirationRoutes);
    jest.clearAllMocks();
  });

  describe("GET /aspirations", () => {
    test("should return list of aspirations for admin user", async () => {
      const mockAspirations = [
        {
          id: 1,
          title: "Perbaikan Jalan",
          description: "Jalan rusak perlu diperbaiki",
          status: "pending",
          created_by_resident_id: 1,
          created_at: "2025-12-26T00:00:00Z",
          created_by_resident: {
            id: 1,
            full_name: "John Doe",
            houses: { rw: 1, rt: 1, address: "Jl. Test No. 1" },
          },
        },
        {
          id: 2,
          title: "Lampu Jalan Mati",
          description: "Lampu jalan tidak menyala",
          status: "in_progress",
          created_by_resident_id: 2,
          created_at: "2025-12-25T00:00:00Z",
          created_by_resident: {
            id: 2,
            full_name: "Jane Smith",
            houses: { rw: 1, rt: 2, address: "Jl. Test No. 2" },
          },
        },
      ];

      supabaseAdmin.order.mockResolvedValue({
        data: mockAspirations,
        error: null,
      });

      const response = await request(app).get("/aspirations").expect(200);

      expect(response.body.data).toEqual(mockAspirations);
      expect(supabaseAdmin.from).toHaveBeenCalledWith("aspirations");
      expect(supabaseAdmin.order).toHaveBeenCalledWith("created_at", {
        ascending: false,
      });
    });

    test("should return 500 when database error occurs", async () => {
      supabaseAdmin.order.mockResolvedValue({
        data: null,
        error: { message: "Database connection failed" },
      });

      const response = await request(app).get("/aspirations").expect(500);

      expect(response.body).toHaveProperty("message");
      expect(response.body.message).toBe("Database connection failed");
    });
  });

  describe("POST /aspirations", () => {
    test("should return 403 for admin/moderator trying to create aspiration", async () => {
      // Admin tidak boleh membuat aspirasi
      const newAspiration = {
        title: "Test",
        description: "Test",
      };

      const response = await request(app)
        .post("/aspirations")
        .send(newAspiration)
        .expect(403);

      expect(response.body.message).toContain("Moderator tidak dapat membuat aspirasi");
    });
  });

  describe("PATCH /aspirations/:id/status", () => {
    test("should update aspiration status for moderator", async () => {
      const mockAspiration = {
        id: 1,
        status: "pending",
        created_by_resident_id: 1,
      };

      // First call untuk get data
      supabaseAdmin.single.mockResolvedValueOnce({
        data: mockAspiration,
        error: null,
      });

      // Second call untuk update
      const mockSelect = jest.fn().mockResolvedValue({
        data: { ...mockAspiration, status: "resolved", response: "Sudah diperbaiki" },
        error: null,
      });

      supabaseAdmin.update.mockReturnValue({
        eq: jest.fn().mockReturnValue({
          select: mockSelect,
        }),
      });

      mockSelect.mockReturnValue({
        single: jest.fn().mockResolvedValue({
          data: { ...mockAspiration, status: "resolved", response: "Sudah diperbaiki" },
          error: null,
        }),
      });

      const response = await request(app)
        .patch("/aspirations/1/status")
        .send({ status: "resolved", response: "Sudah diperbaiki" })
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(supabaseAdmin.from).toHaveBeenCalledWith("aspirations");
    });

    test("should return 400 when status is invalid", async () => {
      const response = await request(app)
        .patch("/aspirations/1/status")
        .send({ status: "invalid_status" })
        .expect(400);

      expect(response.body.message).toContain("tidak valid");
    });

    test("should return 400 when id is invalid", async () => {
      const response = await request(app)
        .patch("/aspirations/invalid/status")
        .send({ status: "resolved" })
        .expect(400);

      expect(response.body.message).toContain("Invalid id");
    });
  });

  describe("GET /aspirations/:id", () => {
    test("should return aspiration by id for admin", async () => {
      const mockAspiration = {
        id: 1,
        title: "Perbaikan Jalan",
        created_by_resident_id: 1,
        created_by_resident: {
          id: 1,
          full_name: "John Doe",
          houses: { rw: 1, rt: 1, address: "Jl. Test" },
        },
      };

      // Mock get aspiration
      supabaseAdmin.single.mockResolvedValue({
        data: mockAspiration,
        error: null,
      });

      // Mock getResidentIdsByScope untuk scope check (admin = mode all, tidak perlu filter)
      // Tidak perlu mock karena admin mode=all langsung lewat

      const response = await request(app)
        .get("/aspirations/1")
        .expect(200);

      expect(response.body.data).toEqual(mockAspiration);
      expect(supabaseAdmin.from).toHaveBeenCalledWith("aspirations");
    });

    test("should return 404 when aspiration not found", async () => {
      supabaseAdmin.single.mockResolvedValue({
        data: null,
        error: { message: "Not found" },
      });

      const response = await request(app)
        .get("/aspirations/999")
        .expect(404);

      expect(response.body.message).toContain("tidak ditemukan");
    });
  });
});
