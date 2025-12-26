const { requireAuth } = require("../../../src/middlewares/requireAuth");
const {
  createMockRequest,
  createMockResponse,
  createMockNext,
} = require("../../helpers/testUtils");

// Mock supabaseAdmin
const mockAuthGetUser = jest.fn();
const mockFrom = jest.fn();

jest.mock("../../../src/lib/supabaseAdmin", () => ({
  supabaseAdmin: {
    auth: {
      getUser: (...args) => mockAuthGetUser(...args),
    },
    from: (...args) => mockFrom(...args),
  },
}));

const { supabaseAdmin } = require("../../../src/lib/supabaseAdmin");

describe("requireAuth Middleware - Unit Tests", () => {
  let req, res, next;

  beforeEach(() => {
    req = createMockRequest();
    res = createMockResponse();
    next = createMockNext();
    jest.clearAllMocks();
  });

  describe("Token Validation", () => {
    test("should return 401 when no authorization header is provided", async () => {
      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        message: "Missing bearer token",
      });
      expect(next).not.toHaveBeenCalled();
    });

    test("should return 401 when authorization header is invalid format", async () => {
      req.headers.authorization = "InvalidFormat";

      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        message: "Missing bearer token",
      });
    });

    test("should return 401 when token is invalid", async () => {
      req.headers.authorization = "Bearer invalid-token";
      mockAuthGetUser.mockResolvedValue({
        data: null,
        error: { message: "Invalid token" },
      });

      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ message: "Invalid token" });
    });
  });

  describe("User Profile Validation", () => {
    test("should return 403 when user profile not found", async () => {
      req.headers.authorization = "Bearer valid-token";
      mockAuthGetUser.mockResolvedValue({
        data: { user: { id: "auth-user-id" } },
        error: null,
      });

      mockFrom.mockReturnValue({
        select: jest.fn().mockReturnValue({
          eq: jest.fn().mockReturnValue({
            single: jest.fn().mockResolvedValue({
              data: null,
              error: { message: "User not found" },
            }),
          }),
        }),
      });

      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        message: "User profile not found in public.users",
      });
    });

    test("should return 403 when user account is not active", async () => {
      req.headers.authorization = "Bearer valid-token";
      mockAuthGetUser.mockResolvedValue({
        data: { user: { id: "auth-user-id" } },
        error: null,
      });

      mockFrom.mockReturnValueOnce({
        select: jest.fn().mockReturnValue({
          eq: jest.fn().mockReturnValue({
            single: jest.fn().mockResolvedValue({
              data: {
                id: "user-id",
                name: "Test User",
                email: "test@example.com",
                is_active: false,
              },
              error: null,
            }),
          }),
        }),
      });

      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        message: "Account not active (waiting approval)",
      });
    });
  });

  describe("Successful Authentication", () => {
    test("should set userContext and call next() for admin user", async () => {
      req.headers.authorization = "Bearer valid-token";

      // Mock auth.getUser
      mockAuthGetUser.mockResolvedValue({
        data: { user: { id: "auth-user-id", email: "admin@example.com" } },
        error: null,
      });

      // Mock from() calls - first untuk users, kedua untuk user_roles
      mockFrom
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockReturnValue({
              single: jest.fn().mockResolvedValue({
                data: {
                  id: "user-id",
                  name: "Admin User",
                  email: "admin@example.com",
                  phone: "081234567890",
                  is_active: true,
                  resident_id: null,
                },
                error: null,
              }),
            }),
          }),
        })
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockResolvedValue({
              data: [{ rw: null, rt: null, roles: { name: "admin" } }],
              error: null,
            }),
          }),
        });

      await requireAuth(req, res, next);

      expect(req.userContext).toBeDefined();
      expect(req.userContext.appUser.email).toBe("admin@example.com");
      expect(req.userContext.roleNames).toContain("admin");
      expect(req.userContext.scope.mode).toBe("all");
      expect(next).toHaveBeenCalled();
    });

    test("should set correct scope for ketua_rw", async () => {
      req.headers.authorization = "Bearer valid-token";

      mockAuthGetUser.mockResolvedValue({
        data: { user: { id: "auth-user-id" } },
        error: null,
      });

      mockFrom
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockReturnValue({
              single: jest.fn().mockResolvedValue({
                data: {
                  id: "user-id",
                  name: "Ketua RW",
                  email: "ketua@rw.com",
                  is_active: true,
                },
                error: null,
              }),
            }),
          }),
        })
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockResolvedValue({
              data: [{ rw: 1, rt: null, roles: { name: "ketua_rw" } }],
              error: null,
            }),
          }),
        });

      await requireAuth(req, res, next);

      expect(req.userContext.scope.mode).toBe("rw");
      expect(req.userContext.scope.rw).toBe(1);
      expect(req.userContext.scope.rt).toBe(null);
    });

    test("should set correct scope for ketua_rt", async () => {
      req.headers.authorization = "Bearer valid-token";

      mockAuthGetUser.mockResolvedValue({
        data: { user: { id: "auth-user-id" } },
        error: null,
      });

      mockFrom
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockReturnValue({
              single: jest.fn().mockResolvedValue({
                data: {
                  id: "user-id",
                  name: "Ketua RT",
                  email: "ketua@rt.com",
                  is_active: true,
                },
                error: null,
              }),
            }),
          }),
        })
        .mockReturnValueOnce({
          select: jest.fn().mockReturnValue({
            eq: jest.fn().mockResolvedValue({
              data: [{ rw: 1, rt: 2, roles: { name: "ketua_rt" } }],
              error: null,
            }),
          }),
        });

      await requireAuth(req, res, next);

      expect(req.userContext.scope.mode).toBe("rt");
      expect(req.userContext.scope.rw).toBe(1);
      expect(req.userContext.scope.rt).toBe(2);
    });
  });

  describe("Error Handling", () => {
    test("should return 500 on unexpected error", async () => {
      req.headers.authorization = "Bearer valid-token";
      mockAuthGetUser.mockRejectedValue(new Error("Database error"));

      await requireAuth(req, res, next);

      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({ message: "Database error" });
    });
  });
});
