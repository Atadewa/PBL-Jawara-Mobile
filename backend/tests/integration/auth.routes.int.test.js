const express = require("express");
const request = require("supertest");
const authRoutes = require("../../src/routes/auth.routes");

// Mock dependencies
jest.mock("../../src/middlewares/requireAuth");

const { requireAuth } = require("../../src/middlewares/requireAuth");

describe("Auth Routes Integration Tests", () => {
  let app;
  let currentUserContext;

  // Default user context
  const defaultUserContext = {
    appUser: {
      id: "test-user-123",
      email: "admin@test.com",
      name: "Test Admin",
    },
    roleNames: ["admin"],
    scope: { mode: "all", rw: null, rt: null },
  };

  beforeEach(() => {
    // Reset mocks
    jest.clearAllMocks();

    // Reset current user context to default
    currentUserContext = { ...defaultUserContext };

    // Setup Express app
    app = express();
    app.use(express.json());
    app.use("/auth", authRoutes);

    // Mock requireAuth middleware
    requireAuth.mockImplementation((req, res, next) => {
      req.userContext = currentUserContext;
      next();
    });
  });

  describe("GET /auth/me", () => {
    test("should return user context for admin with scope.mode='all'", async () => {
      currentUserContext = {
        appUser: {
          id: "admin-001",
          email: "admin@example.com",
          name: "Admin User",
        },
        roleNames: ["admin"],
        scope: { mode: "all", rw: null, rt: null },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: {
          id: "admin-001",
          email: "admin@example.com",
          name: "Admin User",
        },
        roles: ["admin"],
        scope: { mode: "all", rw: null, rt: null },
      });
    });

    test("should return user context for bendahara with scope.mode='rw'", async () => {
      currentUserContext = {
        appUser: {
          id: "bendahara-001",
          email: "bendahara@example.com",
          name: "Bendahara User",
        },
        roleNames: ["bendahara"],
        scope: { mode: "rw", rw: 2, rt: null },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: {
          id: "bendahara-001",
          email: "bendahara@example.com",
          name: "Bendahara User",
        },
        roles: ["bendahara"],
        scope: { mode: "rw", rw: 2, rt: null },
      });
    });

    test("should return user context for ketua_rt with scope.mode='rt'", async () => {
      currentUserContext = {
        appUser: {
          id: "rt-001",
          email: "ketuart@example.com",
          name: "Ketua RT",
        },
        roleNames: ["ketua_rt"],
        scope: { mode: "rt", rw: 3, rt: 5 },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: { id: "rt-001", email: "ketuart@example.com", name: "Ketua RT" },
        roles: ["ketua_rt"],
        scope: { mode: "rt", rw: 3, rt: 5 },
      });
    });

    test("should return user context for user with multiple roles", async () => {
      currentUserContext = {
        appUser: {
          id: "multi-001",
          email: "multi@example.com",
          name: "Multi Role User",
        },
        roleNames: ["sekretaris", "bendahara"],
        scope: { mode: "rw", rw: 1, rt: null },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: {
          id: "multi-001",
          email: "multi@example.com",
          name: "Multi Role User",
        },
        roles: ["sekretaris", "bendahara"],
        scope: { mode: "rw", rw: 1, rt: null },
      });
    });

    test("should return user context for warga with minimal data", async () => {
      currentUserContext = {
        appUser: { id: "warga-001", email: "warga@example.com" },
        roleNames: ["warga"],
        scope: { mode: "rt", rw: 2, rt: 3 },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: { id: "warga-001", email: "warga@example.com" },
        roles: ["warga"],
        scope: { mode: "rt", rw: 2, rt: 3 },
      });
    });

    test("should call requireAuth middleware", async () => {
      await request(app).get("/auth/me");

      expect(requireAuth).toHaveBeenCalled();
    });

    test("should handle user with empty roles array", async () => {
      currentUserContext = {
        appUser: { id: "norole-001", email: "norole@example.com" },
        roleNames: [],
        scope: { mode: "all", rw: null, rt: null },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({
        user: { id: "norole-001", email: "norole@example.com" },
        roles: [],
        scope: { mode: "all", rw: null, rt: null },
      });
    });

    test("should return complete user object with all properties", async () => {
      currentUserContext = {
        appUser: {
          id: "complete-001",
          email: "complete@example.com",
          name: "Complete User",
          phone: "081234567890",
          address: "Jl. Test No. 123",
        },
        roleNames: ["ketua_rw", "admin"],
        scope: { mode: "all", rw: null, rt: null },
      };

      const response = await request(app).get("/auth/me");

      expect(response.status).toBe(200);
      expect(response.body.user).toEqual({
        id: "complete-001",
        email: "complete@example.com",
        name: "Complete User",
        phone: "081234567890",
        address: "Jl. Test No. 123",
      });
      expect(response.body.roles).toEqual(["ketua_rw", "admin"]);
      expect(response.body.scope).toEqual({ mode: "all", rw: null, rt: null });
    });
  });
});
