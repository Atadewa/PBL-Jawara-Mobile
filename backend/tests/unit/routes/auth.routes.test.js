const express = require("express");
const request = require("supertest");
const authRoutes = require("../../../src/routes/auth.routes");

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

describe("Auth Routes - Unit Tests", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/auth", authRoutes);
  });

  describe("GET /auth/me", () => {
    test("should return user context when authenticated", async () => {
      const response = await request(app).get("/auth/me").expect(200);

      expect(response.body).toHaveProperty("user");
      expect(response.body).toHaveProperty("roles");
      expect(response.body).toHaveProperty("scope");
      expect(response.body.user.email).toBe("test@example.com");
      expect(response.body.roles).toContain("admin");
    });
  });
});
