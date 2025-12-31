/**
 * Unit Tests for income.routes.js
 * Tests helper functions and handlers directly with mocked dependencies
 */

// Set up environment variables to prevent errors
process.env.SUPABASE_URL = "http://localhost:54321";
process.env.SUPABASE_SERVICE_ROLE_KEY = "test-key";

// Mock @supabase/supabase-js at the module level
jest.mock("@supabase/supabase-js", () => ({
  createClient: jest.fn(() => ({
    from: jest.fn(),
  })),
}), { virtual: false });

// Now require the modules
const { applyScope, __test__ } = require("../../../src/routes/income.routes");
const { getIncomesHandler, postIncomeHandler } = __test__;
const { supabaseAdmin } = require("../../../src/lib/supabaseAdmin");

describe("Income Routes - Unit Tests", () => {
  let mockReq;
  let mockRes;

  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();

    // Create reusable mock request
    mockReq = {
      userContext: {},
      body: {},
    };

    // Create reusable mock response
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
  });

  // =====================================================
  // A) applyScope Helper Function Tests
  // =====================================================
  describe("applyScope", () => {
    let mockQuery;

    beforeEach(() => {
      mockQuery = {
        eq: jest.fn().mockReturnThis(),
      };
    });

    test('should return query unchanged when scope.mode is "all"', () => {
      const scope = { mode: "all" };
      const result = applyScope(mockQuery, scope);

      expect(result).toBe(mockQuery);
      expect(mockQuery.eq).not.toHaveBeenCalled();
    });

    test('should call eq("rw", scope.rw) when scope.mode is "rw"', () => {
      const scope = { mode: "rw", rw: 5 };
      const result = applyScope(mockQuery, scope);

      expect(mockQuery.eq).toHaveBeenCalledTimes(1);
      expect(mockQuery.eq).toHaveBeenCalledWith("rw", 5);
      expect(result).toBe(mockQuery);
    });

    test('should call eq("rw") and eq("rt") when scope.mode is "rt"', () => {
      const scope = { mode: "rt", rw: 5, rt: 3 };
      const result = applyScope(mockQuery, scope);

      expect(mockQuery.eq).toHaveBeenCalledTimes(2);
      expect(mockQuery.eq).toHaveBeenNthCalledWith(1, "rw", 5);
      expect(mockQuery.eq).toHaveBeenNthCalledWith(2, "rt", 3);
      expect(result).toBe(mockQuery);
    });

    test("should return query unchanged for unknown scope mode", () => {
      const scope = { mode: "unknown" };
      const result = applyScope(mockQuery, scope);

      expect(result).toBe(mockQuery);
      expect(mockQuery.eq).not.toHaveBeenCalled();
    });
  });

  // =====================================================
  // B) POST Handler Tests
  // =====================================================
  describe("POST handler - postIncomeHandler", () => {
    test("should return 403 when user has no allowed role", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["warga", "guest"],
        scope: { mode: "rt", rw: 1, rt: 1 },
      };
      mockReq.body = {
        source_name: "Test Income",
        amount: 100000,
        date: "2025-12-27",
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({ message: "Forbidden" });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when source_name is missing", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["admin"],
        scope: { mode: "all" },
      };
      mockReq.body = {
        amount: 100000,
        date: "2025-12-27",
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when amount is missing", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["bendahara"],
        scope: { mode: "rw", rw: 2 },
      };
      mockReq.body = {
        source_name: "Test Income",
        date: "2025-12-27",
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when date is missing", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["sekretaris"],
        scope: { mode: "rw", rw: 2 },
      };
      mockReq.body = {
        source_name: "Test Income",
        amount: 100000,
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test('should return 400 when scope.mode is "all" but rw is not provided', async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["admin"],
        scope: { mode: "all" },
      };
      mockReq.body = {
        source_name: "Test Income",
        amount: 100000,
        date: "2025-12-27",
        // rw is missing
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "rw wajib untuk admin",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 403 when scope.mode is invalid", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["admin"],
        scope: { mode: "invalid" },
      };
      mockReq.body = {
        source_name: "Test Income",
        amount: 100000,
        date: "2025-12-27",
      };

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(403);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "No scope access",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test('should enforce rw=scope.rw and rt=null when scope.mode is "rw"', async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["ketua_rw"],
        scope: { mode: "rw", rw: 5 },
      };
      mockReq.body = {
        source_name: "Iuran RW",
        amount: 100000,
        date: "2025-12-27",
        description: "Test description",
        payment_method: "cash",
        rw: 999, // should be overridden
        rt: 888, // should be overridden to null
      };

      const mockInsertChain = {
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({
          data: { id: 1, source_name: "Iuran RW" },
          error: null,
        }),
      };

      supabaseAdmin.from.mockReturnValue({
        insert: jest.fn().mockReturnValue(mockInsertChain),
      });

      await postIncomeHandler(mockReq, mockRes);

      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      
      const insertCall = supabaseAdmin.from().insert;
      expect(insertCall).toHaveBeenCalledWith({
        rw: 5, // from scope
        rt: null, // enforced to null
        source_name: "Iuran RW",
        description: "Test description",
        amount: 100000,
        date: "2025-12-27",
        payment_method: "cash",
        recorded_by_user_id: "user-123",
      });

      expect(mockInsertChain.select).toHaveBeenCalledWith("*");
      expect(mockInsertChain.single).toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        data: { id: 1, source_name: "Iuran RW" },
      });
    });

    test('should enforce rw=scope.rw and rt=scope.rt when scope.mode is "rt"', async () => {
      mockReq.userContext = {
        appUser: { id: "user-456" },
        roleNames: ["ketua_rt"],
        scope: { mode: "rt", rw: 3, rt: 7 },
      };
      mockReq.body = {
        source_name: "Iuran RT",
        amount: 50000,
        date: "2025-12-27",
        rw: 999, // should be overridden
        rt: 888, // should be overridden
      };

      const mockInsertChain = {
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({
          data: { id: 2, source_name: "Iuran RT" },
          error: null,
        }),
      };

      supabaseAdmin.from.mockReturnValue({
        insert: jest.fn().mockReturnValue(mockInsertChain),
      });

      await postIncomeHandler(mockReq, mockRes);

      const insertCall = supabaseAdmin.from().insert;
      expect(insertCall).toHaveBeenCalledWith({
        rw: 3, // from scope
        rt: 7, // from scope
        source_name: "Iuran RT",
        description: null, // default
        amount: 50000,
        date: "2025-12-27",
        payment_method: null, // default
        recorded_by_user_id: "user-456",
      });

      expect(mockRes.status).toHaveBeenCalledWith(201);
    });

    test("should successfully create income with valid data and defaults", async () => {
      mockReq.userContext = {
        appUser: { id: "admin-123" },
        roleNames: ["admin"],
        scope: { mode: "all" },
      };
      mockReq.body = {
        source_name: "Donation",
        amount: 200000,
        date: "2025-12-27",
        rw: 1,
        // description not provided
        // payment_method not provided
      };

      const mockInsertChain = {
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({
          data: {
            id: 10,
            source_name: "Donation",
            amount: 200000,
            date: "2025-12-27",
            rw: 1,
            rt: null,
            description: null,
            payment_method: null,
            recorded_by_user_id: "admin-123",
          },
          error: null,
        }),
      };

      supabaseAdmin.from.mockReturnValue({
        insert: jest.fn().mockReturnValue(mockInsertChain),
      });

      await postIncomeHandler(mockReq, mockRes);

      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      
      const insertCall = supabaseAdmin.from().insert;
      expect(insertCall).toHaveBeenCalledWith({
        rw: 1,
        rt: null,
        source_name: "Donation",
        description: null, // default
        amount: 200000,
        date: "2025-12-27",
        payment_method: null, // default
        recorded_by_user_id: "admin-123",
      });

      expect(mockInsertChain.select).toHaveBeenCalledWith("*");
      expect(mockInsertChain.single).toHaveBeenCalled();
      expect(mockRes.status).toHaveBeenCalledWith(201);
      expect(mockRes.json).toHaveBeenCalledWith({
        data: expect.objectContaining({
          id: 10,
          source_name: "Donation",
        }),
      });
    });

    test("should return 500 when Supabase returns an error", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["bendahara"],
        scope: { mode: "rw", rw: 2 },
      };
      mockReq.body = {
        source_name: "Test",
        amount: 100000,
        date: "2025-12-27",
      };

      const mockInsertChain = {
        select: jest.fn().mockReturnThis(),
        single: jest.fn().mockResolvedValue({
          data: null,
          error: { message: "Database connection failed" },
        }),
      };

      supabaseAdmin.from.mockReturnValue({
        insert: jest.fn().mockReturnValue(mockInsertChain),
      });

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Database connection failed",
      });
    });

    test("should return 500 when exception is thrown", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["admin"],
        scope: { mode: "all" },
      };
      mockReq.body = {
        source_name: "Test",
        amount: 100000,
        date: "2025-12-27",
        rw: 1,
      };

      supabaseAdmin.from.mockImplementation(() => {
        throw new Error("Unexpected error");
      });

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Unexpected error",
      });
    });

    test("should return 500 with fallback message when exception has no message", async () => {
      mockReq.userContext = {
        appUser: { id: "user-123" },
        roleNames: ["admin"],
        scope: { mode: "all" },
      };
      mockReq.body = {
        source_name: "Test",
        amount: 100000,
        date: "2025-12-27",
        rw: 1,
      };

      supabaseAdmin.from.mockImplementation(() => {
        throw {}; // Error without message
      });

      await postIncomeHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Server error",
      });
    });
  });

  // =====================================================
  // C) GET Handler Tests
  // =====================================================
  describe("GET handler - getIncomesHandler", () => {
    // Helper to create a thenable query mock
    function createQueryMock(data, error) {
      const mockQuery = {
        eq: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        then: function (resolve) {
          return Promise.resolve(resolve({ data, error }));
        },
      };
      return mockQuery;
    }

    test('should return data without eq calls when scope.mode is "all"', async () => {
      mockReq.userContext = {
        scope: { mode: "all" },
      };

      const mockData = [
        { id: 1, source_name: "Income 1", amount: 100000 },
        { id: 2, source_name: "Income 2", amount: 200000 },
      ];

      const mockQuery = createQueryMock(mockData, null);
      supabaseAdmin.from.mockReturnValue(mockQuery);

      await getIncomesHandler(mockReq, mockRes);

      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQuery.select).toHaveBeenCalledWith("*");
      expect(mockQuery.order).toHaveBeenCalledWith("date", { ascending: false });
      expect(mockQuery.eq).not.toHaveBeenCalled();
      expect(mockRes.json).toHaveBeenCalledWith({ data: mockData });
      expect(mockRes.status).not.toHaveBeenCalled(); // 200 is implicit
    });

    test('should call eq("rw", scope.rw) when scope.mode is "rw"', async () => {
      mockReq.userContext = {
        scope: { mode: "rw", rw: 5 },
      };

      const mockData = [{ id: 1, source_name: "Income", rw: 5 }];
      const mockQuery = createQueryMock(mockData, null);
      supabaseAdmin.from.mockReturnValue(mockQuery);

      await getIncomesHandler(mockReq, mockRes);

      expect(mockQuery.eq).toHaveBeenCalledTimes(1);
      expect(mockQuery.eq).toHaveBeenCalledWith("rw", 5);
      expect(mockRes.json).toHaveBeenCalledWith({ data: mockData });
    });

    test('should call eq("rw") and eq("rt") when scope.mode is "rt"', async () => {
      mockReq.userContext = {
        scope: { mode: "rt", rw: 3, rt: 7 },
      };

      const mockData = [{ id: 1, source_name: "Income", rw: 3, rt: 7 }];
      const mockQuery = createQueryMock(mockData, null);
      supabaseAdmin.from.mockReturnValue(mockQuery);

      await getIncomesHandler(mockReq, mockRes);

      expect(mockQuery.eq).toHaveBeenCalledTimes(2);
      expect(mockQuery.eq).toHaveBeenNthCalledWith(1, "rw", 3);
      expect(mockQuery.eq).toHaveBeenNthCalledWith(2, "rt", 7);
      expect(mockRes.json).toHaveBeenCalledWith({ data: mockData });
    });

    test("should return 500 when Supabase returns an error", async () => {
      mockReq.userContext = {
        scope: { mode: "all" },
      };

      const mockQuery = createQueryMock(null, { message: "Query failed" });
      supabaseAdmin.from.mockReturnValue(mockQuery);

      await getIncomesHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Query failed",
      });
    });

    test("should return 500 when exception is thrown", async () => {
      mockReq.userContext = {
        scope: { mode: "all" },
      };

      supabaseAdmin.from.mockImplementation(() => {
        throw new Error("Connection error");
      });

      await getIncomesHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Connection error",
      });
    });

    test("should return 500 with fallback message when exception has no message", async () => {
      mockReq.userContext = {
        scope: { mode: "all" },
      };

      supabaseAdmin.from.mockImplementation(() => {
        throw {}; // Error without message
      });

      await getIncomesHandler(mockReq, mockRes);

      expect(mockRes.status).toHaveBeenCalledWith(500);
      expect(mockRes.json).toHaveBeenCalledWith({
        message: "Server error",
      });
    });
  });
});
