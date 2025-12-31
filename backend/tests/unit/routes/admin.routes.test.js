const express = require("express");
const request = require("supertest");

// Mock supabaseAdmin sebelum import routes
jest.mock("../../../src/lib/supabaseAdmin", () => ({
  supabaseAdmin: {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    single: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    range: jest.fn().mockReturnThis(),
    or: jest.fn().mockReturnThis(),
    in: jest.fn().mockReturnThis(),
    is: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
  },
}));

// Mock middleware requireAuth dengan setup yang bisa diubah
const mockUserContext = {
  appUser: { id: "test-user-id" },
  roleNames: ["admin"],
  scope: { mode: "all", rw: null, rt: null },
};

jest.mock("../../../src/middlewares/requireAuth", () => ({
  requireAuth: (req, res, next) => {
    req.userContext = { ...mockUserContext };
    next();
  },
}));

const adminRoutes = require("../../../src/routes/admin.routes");
const { supabaseAdmin } = require("../../../src/lib/supabaseAdmin");

describe("Admin Routes - Unit Tests", () => {
  let app;

  beforeEach(() => {
    // Reset mock user context to admin
    mockUserContext.appUser = { id: "test-user-id" };
    mockUserContext.roleNames = ["admin"];
    mockUserContext.scope = { mode: "all", rw: null, rt: null };

    app = express();
    app.use(express.json());
    app.use("/admin", adminRoutes);
    jest.clearAllMocks();
  });

  describe("GET /admin/users", () => {
    test("should return paginated list of users for admin", async () => {
      const mockUsers = [
        {
          id: 1,
          name: "John Doe",
          email: "john@example.com",
          phone: "081234567890",
          is_active: true,
          resident_id: null,
          created_at: "2025-12-01T00:00:00Z",
        },
        {
          id: 2,
          name: "Jane Smith",
          email: "jane@example.com",
          phone: "081234567891",
          is_active: false,
          resident_id: null,
          created_at: "2025-12-02T00:00:00Z",
        },
      ];

      // Mock untuk GET users
      supabaseAdmin.range.mockResolvedValue({
        data: mockUsers,
        error: null,
        count: 2,
      });

      // Mock untuk attachRolesToUsers - query user_roles
      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app).get("/admin/users").expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.page).toBe(1);
      expect(response.body.limit).toBe(20);
      expect(response.body.total).toBe(2);
      expect(supabaseAdmin.from).toHaveBeenCalledWith("users");
    });

    test("should filter users by status=pending", async () => {
      const mockPendingUsers = [
        {
          id: 2,
          name: "Pending User",
          email: "pending@example.com",
          is_active: false,
        },
      ];

      // Mock untuk chain: from().select().order().range().eq()
      const mockRange = jest.fn().mockResolvedValue({
        data: mockPendingUsers,
        error: null,
        count: 1,
      });

      const mockEq = jest.fn().mockReturnValue({
        range: mockRange,
      });

      supabaseAdmin.order.mockReturnValue({
        range: jest.fn().mockReturnValue({
          eq: mockEq,
        }),
      });

      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .get("/admin/users?status=pending")
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(mockEq).toHaveBeenCalledWith("is_active", false);
    });

    test("should filter users by status=active", async () => {
      const mockActiveUsers = [
        {
          id: 1,
          name: "Active User",
          email: "active@example.com",
          is_active: true,
        },
      ];

      // Mock untuk chain: from().select().order().range().eq()
      const mockRange = jest.fn().mockResolvedValue({
        data: mockActiveUsers,
        error: null,
        count: 1,
      });

      const mockEq = jest.fn().mockReturnValue({
        range: mockRange,
      });

      supabaseAdmin.order.mockReturnValue({
        range: jest.fn().mockReturnValue({
          eq: mockEq,
        }),
      });

      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .get("/admin/users?status=active")
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(mockEq).toHaveBeenCalledWith("is_active", true);
    });

    test("should search users by name/email/phone", async () => {
      const mockUsers = [
        {
          id: 1,
          name: "John Doe",
          email: "john@example.com",
        },
      ];

      // Mock untuk chain: from().select().order().range().or()
      const mockOr = jest.fn().mockResolvedValue({
        data: mockUsers,
        error: null,
        count: 1,
      });

      supabaseAdmin.order.mockReturnValue({
        range: jest.fn().mockReturnValue({
          or: mockOr,
        }),
      });

      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .get("/admin/users?search=john")
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(mockOr).toHaveBeenCalled();
    });

    test("should support pagination parameters", async () => {
      // Mock untuk chain dengan pagination
      const mockRange = jest.fn().mockResolvedValue({
        data: [],
        error: null,
        count: 50,
      });

      supabaseAdmin.order.mockReturnValue({
        range: mockRange,
      });

      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .get("/admin/users?page=2&limit=10")
        .expect(200);

      expect(response.body.page).toBe(2);
      expect(response.body.limit).toBe(10);
      expect(mockRange).toHaveBeenCalledWith(10, 19);
    });

    test("should return 500 when database error occurs", async () => {
      // Mock error pada chain
      supabaseAdmin.order.mockReturnValue({
        range: jest.fn().mockResolvedValue({
          data: null,
          error: { message: "Database error" },
        }),
      });

      const response = await request(app).get("/admin/users").expect(500);

      expect(response.body.message).toBe("Database error");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app).get("/admin/users").expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("GET /admin/users/:id", () => {
    test("should return user detail by id", async () => {
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        phone: "081234567890",
        is_active: true,
        resident_id: null,
      };

      supabaseAdmin.single.mockResolvedValue({
        data: mockUser,
        error: null,
      });

      // Mock attachRolesToUsers
      supabaseAdmin.in.mockResolvedValue({
        data: [
          {
            id: 1,
            user_id: 1,
            role_id: 1,
            rw: 1,
            rt: 1,
            roles: { name: "warga" },
          },
        ],
        error: null,
      });

      const response = await request(app).get("/admin/users/1").expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.id).toBe(1);
      expect(response.body.data.roles).toBeDefined();
    });

    test("should return 400 for invalid user id", async () => {
      const response = await request(app)
        .get("/admin/users/invalid")
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 404 when user not found", async () => {
      supabaseAdmin.single.mockResolvedValue({
        data: null,
        error: { message: "Not found" },
      });

      const response = await request(app).get("/admin/users/999").expect(404);

      expect(response.body.message).toBe("User not found");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app).get("/admin/users/1").expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/approve", () => {
    test("should approve user successfully", async () => {
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        is_active: true,
      };

      const mockSingle = jest.fn().mockResolvedValue({
        data: mockUser,
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      const mockEq = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      supabaseAdmin.update.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .patch("/admin/users/1/approve")
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.is_active).toBe(true);
      expect(supabaseAdmin.update).toHaveBeenCalledWith(
        expect.objectContaining({
          is_active: true,
        })
      );
    });

    test("should return 400 for invalid user id", async () => {
      const response = await request(app)
        .patch("/admin/users/invalid/approve")
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 500 when database error occurs", async () => {
      const mockSingle = jest.fn().mockResolvedValue({
        data: null,
        error: { message: "Database error" },
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      const mockEq = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      supabaseAdmin.update.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .patch("/admin/users/1/approve")
        .expect(500);

      expect(response.body.message).toBe("Database error");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app)
        .patch("/admin/users/1/approve")
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/deactivate", () => {
    test("should deactivate user successfully", async () => {
      const mockUser = {
        id: 1,
        name: "John Doe",
        email: "john@example.com",
        is_active: false,
      };

      const mockSingle = jest.fn().mockResolvedValue({
        data: mockUser,
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      const mockEq = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      supabaseAdmin.update.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .patch("/admin/users/1/deactivate")
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.is_active).toBe(false);
      expect(supabaseAdmin.update).toHaveBeenCalledWith(
        expect.objectContaining({
          is_active: false,
        })
      );
    });

    test("should return 400 for invalid user id", async () => {
      const response = await request(app)
        .patch("/admin/users/invalid/deactivate")
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app)
        .patch("/admin/users/1/deactivate")
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/link-resident", () => {
    test("should link user to resident successfully", async () => {
      const linkData = { resident_id: 123 };

      // Mock resident check
      supabaseAdmin.single.mockResolvedValueOnce({
        data: { id: 123 },
        error: null,
      });

      // Mock user update
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          name: "John Doe",
          resident_id: 123,
        },
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      const mockEq = jest.fn().mockReturnValue({
        select: mockSelect,
      });

      supabaseAdmin.update.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .patch("/admin/users/1/link-resident")
        .send(linkData)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.resident_id).toBe(123);
    });

    test("should return 400 when user id is invalid", async () => {
      const response = await request(app)
        .patch("/admin/users/invalid/link-resident")
        .send({ resident_id: 123 })
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 400 when resident_id is not a number", async () => {
      const response = await request(app)
        .patch("/admin/users/1/link-resident")
        .send({ resident_id: "invalid" })
        .expect(400);

      expect(response.body.message).toBe("resident_id wajib angka");
    });

    test("should return 404 when resident not found", async () => {
      supabaseAdmin.single.mockResolvedValue({
        data: null,
        error: { message: "Not found" },
      });

      const response = await request(app)
        .patch("/admin/users/1/link-resident")
        .send({ resident_id: 999 })
        .expect(404);

      expect(response.body.message).toBe("Resident not found");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app)
        .patch("/admin/users/1/link-resident")
        .send({ resident_id: 123 })
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("POST /admin/users/:id/roles", () => {
    test("should add role to user successfully", async () => {
      const roleData = {
        role: "warga",
        rw: 1,
        rt: 1,
      };

      // Mock fetchRolesMap
      supabaseAdmin.select.mockResolvedValueOnce({
        data: [{ id: 1, name: "warga" }],
        error: null,
      });

      // Mock duplicate check
      supabaseAdmin.limit.mockResolvedValueOnce({
        data: [],
        error: null,
      });

      // Mock insert role
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          user_id: 1,
          role_id: 1,
          rw: 1,
          rt: 1,
        },
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.insert.mockReturnValueOnce({
        select: mockSelect,
      });

      // Mock fetch user for return
      supabaseAdmin.single.mockResolvedValueOnce({
        data: {
          id: 1,
          name: "John Doe",
          email: "john@example.com",
        },
        error: null,
      });

      // Mock attachRolesToUsers
      supabaseAdmin.in.mockResolvedValue({
        data: [
          {
            id: 1,
            user_id: 1,
            role_id: 1,
            rw: 1,
            rt: 1,
            roles: { name: "warga" },
          },
        ],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();
      expect(supabaseAdmin.insert).toHaveBeenCalledWith(
        expect.objectContaining({
          user_id: 1,
          role_id: 1,
          rw: 1,
          rt: 1,
        })
      );
    });

    test("should add admin role without rw/rt scope", async () => {
      const roleData = {
        role: "admin",
      };

      // Mock fetchRolesMap
      supabaseAdmin.select.mockResolvedValueOnce({
        data: [{ id: 1, name: "admin" }],
        error: null,
      });

      // Mock duplicate check
      supabaseAdmin.limit.mockResolvedValueOnce({
        data: [],
        error: null,
      });

      // Mock insert
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          user_id: 1,
          role_id: 1,
          rw: null,
          rt: null,
        },
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.insert.mockReturnValueOnce({
        select: mockSelect,
      });

      // Mock fetch user
      supabaseAdmin.single.mockResolvedValueOnce({
        data: { id: 1, name: "Admin User" },
        error: null,
      });

      // Mock attachRolesToUsers
      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();
    });

    test("should add ketua_rw role with rw scope only", async () => {
      const roleData = {
        role: "ketua_rw",
        rw: 1,
      };

      // Mock fetchRolesMap
      supabaseAdmin.select.mockResolvedValueOnce({
        data: [{ id: 2, name: "ketua_rw" }],
        error: null,
      });

      // Mock duplicate check
      supabaseAdmin.limit.mockResolvedValueOnce({
        data: [],
        error: null,
      });

      // Mock insert
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 2,
          user_id: 1,
          role_id: 2,
          rw: 1,
          rt: null,
        },
        error: null,
      });

      const mockSelect = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.insert.mockReturnValueOnce({
        select: mockSelect,
      });

      // Mock fetch user
      supabaseAdmin.single.mockResolvedValueOnce({
        data: { id: 1, name: "RW User" },
        error: null,
      });

      // Mock attachRolesToUsers
      supabaseAdmin.in.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();
    });

    test("should return 400 for invalid user id", async () => {
      const response = await request(app)
        .post("/admin/users/invalid/roles")
        .send({ role: "warga" })
        .expect(400);

      expect(response.body.message).toBe("Invalid user id");
    });

    test("should return 400 when role is not provided", async () => {
      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({})
        .expect(400);

      expect(response.body.message).toBe("role wajib diisi");
    });

    test("should return 400 when role not found in database", async () => {
      supabaseAdmin.select.mockResolvedValue({
        data: [],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "invalid_role" })
        .expect(400);

      expect(response.body.message).toBe("role tidak ditemukan di tabel roles");
    });

    test("should return 400 when RT role missing rw", async () => {
      supabaseAdmin.select.mockResolvedValue({
        data: [{ id: 1, name: "warga" }],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "warga", rt: 1 })
        .expect(400);

      expect(response.body.message).toContain("rw wajib integer positif");
    });

    test("should return 400 when RT role missing rt", async () => {
      supabaseAdmin.select.mockResolvedValue({
        data: [{ id: 1, name: "warga" }],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "warga", rw: 1 })
        .expect(400);

      expect(response.body.message).toContain("rt wajib integer positif");
    });

    test("should return 400 when ketua_rw has rt scope", async () => {
      supabaseAdmin.select.mockResolvedValue({
        data: [{ id: 2, name: "ketua_rw" }],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "ketua_rw", rw: 1, rt: 1 })
        .expect(400);

      expect(response.body.message).toBe("rt harus null untuk ketua_rw");
    });

    test("should return 400 when ketua_rw missing rw", async () => {
      supabaseAdmin.select.mockResolvedValue({
        data: [{ id: 2, name: "ketua_rw" }],
        error: null,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "ketua_rw" })
        .expect(400);

      expect(response.body.message).toContain("rw wajib integer positif");
    });

    test("should return 409 when role already exists", async () => {
      // Mock fetchRolesMap
      supabaseAdmin.select.mockResolvedValueOnce({
        data: [{ id: 1, name: "warga" }],
        error: null,
      });

      // Mock duplicate check chain: from().select().eq().eq().eq().eq().limit()
      const mockLimit = jest.fn().mockResolvedValue({
        data: [{ id: 1 }],
        error: null,
      });

      const mockEq4 = jest.fn().mockReturnValue({
        limit: mockLimit,
      });

      const mockEq3 = jest.fn().mockReturnValue({
        eq: mockEq4,
      });

      const mockEq2 = jest.fn().mockReturnValue({
        eq: mockEq3,
      });

      const mockEq1 = jest.fn().mockReturnValue({
        eq: mockEq2,
      });

      supabaseAdmin.select.mockReturnValueOnce({
        eq: mockEq1,
      });

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "warga", rw: 1, rt: 1 })
        .expect(409);

      expect(response.body.message).toBe("Role sudah ada untuk scope ini");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "warga", rw: 1, rt: 1 })
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("DELETE /admin/users/:id/roles/:userRoleId", () => {
    test("should remove role from user successfully", async () => {
      // Mock user_role check chain: from().select().eq().single()
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          user_id: 1,
        },
        error: null,
      });

      const mockEq = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.select.mockReturnValueOnce({
        eq: mockEq,
      });

      // Mock delete chain: from().delete().eq()
      const mockDeleteEq = jest.fn().mockResolvedValue({
        error: null,
      });

      supabaseAdmin.delete.mockReturnValue({
        eq: mockDeleteEq,
      });

      const response = await request(app)
        .delete("/admin/users/1/roles/1")
        .expect(200);

      expect(response.body.message).toBe("Role removed");
      expect(supabaseAdmin.delete).toHaveBeenCalled();
    });

    test("should return 400 for invalid user id", async () => {
      const response = await request(app)
        .delete("/admin/users/invalid/roles/1")
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 400 for invalid userRoleId", async () => {
      const response = await request(app)
        .delete("/admin/users/1/roles/invalid")
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 404 when user role not found", async () => {
      // Mock chain: from().select().eq().single()
      const mockSingle = jest.fn().mockResolvedValue({
        data: null,
        error: { message: "Not found" },
      });

      const mockEq = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.select.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .delete("/admin/users/1/roles/999")
        .expect(404);

      expect(response.body.message).toBe("User role not found");
    });

    test("should return 400 when role does not belong to user", async () => {
      // Mock chain: from().select().eq().single()
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          user_id: 2, // Different user
        },
        error: null,
      });

      const mockEq = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.select.mockReturnValue({
        eq: mockEq,
      });

      const response = await request(app)
        .delete("/admin/users/1/roles/1")
        .expect(400);

      expect(response.body.message).toBe("Role tidak milik user ini");
    });

    test("should return 500 when database delete fails", async () => {
      // Mock user_role check
      const mockSingle = jest.fn().mockResolvedValue({
        data: {
          id: 1,
          user_id: 1,
        },
        error: null,
      });

      const mockEq = jest.fn().mockReturnValue({
        single: mockSingle,
      });

      supabaseAdmin.select.mockReturnValue({
        eq: mockEq,
      });

      // Mock delete failure
      const mockDeleteEq = jest.fn().mockResolvedValue({
        error: { message: "Delete failed" },
      });

      supabaseAdmin.delete.mockReturnValue({
        eq: mockDeleteEq,
      });

      const response = await request(app)
        .delete("/admin/users/1/roles/1")
        .expect(500);

      expect(response.body.message).toBe("Delete failed");
    });

    test("should return 403 for non-admin user", async () => {
      mockUserContext.roleNames = ["warga"];

      const response = await request(app)
        .delete("/admin/users/1/roles/1")
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });
});
