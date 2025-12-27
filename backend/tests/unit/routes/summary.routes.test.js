const express = require("express");
const request = require("supertest");

// Mock supabaseAdmin - harus didefinisikan sebelum require routes
const mockSupabaseAdmin = {
  from: jest.fn(),
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

const summaryRoutes = require("../../../src/routes/summary.routes");

describe("Summary Routes - Unit Tests", () => {
  let app;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use("/summary", summaryRoutes);
    jest.clearAllMocks();
  });

  describe("GET /summary/cashflow", () => {
    test("should return cashflow summary with default date range", async () => {
      const mockIncomes = [
        { amount: "1000000", date: "2025-12-01" },
        { amount: "500000", date: "2025-12-02" },
      ];
      const mockExpenses = [
        { amount: "300000", date: "2025-12-01" },
        { amount: "200000", date: "2025-12-03" },
      ];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body).toHaveProperty("range");
      expect(response.body).toHaveProperty("scope");
      expect(response.body).toHaveProperty("totals");
      expect(response.body).toHaveProperty("daily");
      expect(response.body.totals.income).toBe(1500000);
      expect(response.body.totals.expense).toBe(500000);
      expect(response.body.totals.balance).toBe(1000000);
    });

    test("should return cashflow summary with custom date range", async () => {
      const mockIncomes = [{ amount: "2000000", date: "2025-11-15" }];
      const mockExpenses = [{ amount: "1000000", date: "2025-11-20" }];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app)
        .get("/summary/cashflow?from=2025-11-01&to=2025-11-30")
        .expect(200);

      expect(response.body.range.from).toBe("2025-11-01");
      expect(response.body.range.to).toBe("2025-11-30");
      expect(response.body.totals.income).toBe(2000000);
      expect(response.body.totals.expense).toBe(1000000);
      expect(response.body.totals.balance).toBe(1000000);
    });

    test("should return daily breakdown sorted by date", async () => {
      const mockIncomes = [
        { amount: "100000", date: "2025-12-03" },
        { amount: "200000", date: "2025-12-01" },
      ];
      const mockExpenses = [
        { amount: "50000", date: "2025-12-02" },
        { amount: "30000", date: "2025-12-01" },
      ];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.daily).toHaveLength(3);
      expect(response.body.daily[0].date).toBe("2025-12-01");
      expect(response.body.daily[1].date).toBe("2025-12-02");
      expect(response.body.daily[2].date).toBe("2025-12-03");

      // Check daily breakdown values
      expect(response.body.daily[0].income).toBe(200000);
      expect(response.body.daily[0].expense).toBe(30000);
      expect(response.body.daily[0].balance).toBe(170000);
    });

    test("should return zero totals when no data", async () => {
      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: [], error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: [], error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.totals.income).toBe(0);
      expect(response.body.totals.expense).toBe(0);
      expect(response.body.totals.balance).toBe(0);
      expect(response.body.daily).toHaveLength(0);
    });

    test("should handle null data from database", async () => {
      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: null, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: null, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.totals.income).toBe(0);
      expect(response.body.totals.expense).toBe(0);
      expect(response.body.totals.balance).toBe(0);
    });

    test("should return 500 on income database error", async () => {
      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: null, error: { message: "Income database error" } }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from.mockReturnValue(mockIncomeQuery);

      const response = await request(app).get("/summary/cashflow").expect(500);

      expect(response.body).toHaveProperty("message", "Income database error");
    });

    test("should return 500 on expense database error", async () => {
      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: [], error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: null, error: { message: "Expense database error" } }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(500);

      expect(response.body).toHaveProperty("message", "Expense database error");
    });

    test("should handle invalid amount values gracefully", async () => {
      const mockIncomes = [
        { amount: "invalid", date: "2025-12-01" },
        { amount: null, date: "2025-12-02" },
        { amount: undefined, date: "2025-12-03" },
        { amount: "500000", date: "2025-12-04" },
      ];
      const mockExpenses = [];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      // Only valid amount (500000) should be counted
      expect(response.body.totals.income).toBe(500000);
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

        const summaryRoutesRw = require("../../../src/routes/summary.routes");
        appWithRwScope = express();
        appWithRwScope.use(express.json());
        appWithRwScope.use("/summary", summaryRoutesRw);
      });

      test("should apply RW scope filter to queries", async () => {
        const mockIncomes = [{ amount: "1000000", date: "2025-12-01" }];
        const mockExpenses = [{ amount: "500000", date: "2025-12-01" }];

        const mockIncomeQuery = {
          select: jest.fn().mockReturnThis(),
          gte: jest.fn().mockReturnThis(),
          lte: jest.fn().mockReturnThis(),
          eq: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        };

        const mockExpenseQuery = {
          select: jest.fn().mockReturnThis(),
          gte: jest.fn().mockReturnThis(),
          lte: jest.fn().mockReturnThis(),
          eq: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        };

        mockSupabaseAdmin.from
          .mockReturnValueOnce(mockIncomeQuery)
          .mockReturnValueOnce(mockExpenseQuery);

        const response = await request(appWithRwScope)
          .get("/summary/cashflow")
          .expect(200);

        expect(response.body.scope.mode).toBe("rw");
        expect(response.body.scope.rw).toBe("01");
        expect(mockIncomeQuery.eq).toHaveBeenCalledWith("rw", "01");
        expect(mockExpenseQuery.eq).toHaveBeenCalledWith("rw", "01");
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

        const summaryRoutesRt = require("../../../src/routes/summary.routes");
        appWithRtScope = express();
        appWithRtScope.use(express.json());
        appWithRtScope.use("/summary", summaryRoutesRt);
      });

      test("should apply RT scope filter to queries", async () => {
        const mockIncomes = [{ amount: "500000", date: "2025-12-01" }];
        const mockExpenses = [{ amount: "200000", date: "2025-12-01" }];

        const mockIncomeQuery = {
          select: jest.fn().mockReturnThis(),
          gte: jest.fn().mockReturnThis(),
          lte: jest.fn().mockReturnThis(),
          eq: jest.fn().mockImplementation(function() { return this; }),
        };
        // Override last eq call to return data
        mockIncomeQuery.eq.mockReturnThis();
        mockIncomeQuery.eq.mockImplementationOnce(function() { return this; })
          .mockImplementationOnce(function() { 
            return Promise.resolve({ data: mockIncomes, error: null }); 
          });

        const mockExpenseQuery = {
          select: jest.fn().mockReturnThis(),
          gte: jest.fn().mockReturnThis(),
          lte: jest.fn().mockReturnThis(),
          eq: jest.fn().mockImplementation(function() { return this; }),
        };
        mockExpenseQuery.eq.mockReturnThis();
        mockExpenseQuery.eq.mockImplementationOnce(function() { return this; })
          .mockImplementationOnce(function() { 
            return Promise.resolve({ data: mockExpenses, error: null }); 
          });

        mockSupabaseAdmin.from
          .mockReturnValueOnce(mockIncomeQuery)
          .mockReturnValueOnce(mockExpenseQuery);

        const response = await request(appWithRtScope)
          .get("/summary/cashflow")
          .expect(200);

        expect(response.body.scope.mode).toBe("rt");
        expect(response.body.scope.rw).toBe("01");
        expect(response.body.scope.rt).toBe("001");
      });
    });
  });

  describe("Daily breakdown calculations", () => {
    test("should combine income and expense on same date", async () => {
      const mockIncomes = [
        { amount: "100000", date: "2025-12-01" },
        { amount: "150000", date: "2025-12-01" },
      ];
      const mockExpenses = [
        { amount: "50000", date: "2025-12-01" },
      ];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.daily).toHaveLength(1);
      expect(response.body.daily[0].date).toBe("2025-12-01");
      expect(response.body.daily[0].income).toBe(250000);
      expect(response.body.daily[0].expense).toBe(50000);
      expect(response.body.daily[0].balance).toBe(200000);
    });

    test("should handle dates with only income", async () => {
      const mockIncomes = [{ amount: "300000", date: "2025-12-05" }];
      const mockExpenses = [];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.daily[0].income).toBe(300000);
      expect(response.body.daily[0].expense).toBe(0);
      expect(response.body.daily[0].balance).toBe(300000);
    });

    test("should handle dates with only expense", async () => {
      const mockIncomes = [];
      const mockExpenses = [{ amount: "150000", date: "2025-12-10" }];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.daily[0].income).toBe(0);
      expect(response.body.daily[0].expense).toBe(150000);
      expect(response.body.daily[0].balance).toBe(-150000);
    });

    test("should handle negative balance correctly", async () => {
      const mockIncomes = [{ amount: "100000", date: "2025-12-01" }];
      const mockExpenses = [{ amount: "500000", date: "2025-12-01" }];

      const mockIncomeQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockIncomes, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      const mockExpenseQuery = {
        select: jest.fn().mockReturnThis(),
        gte: jest.fn().mockReturnThis(),
        lte: jest.fn().mockResolvedValue({ data: mockExpenses, error: null }),
        eq: jest.fn().mockReturnThis(),
      };

      mockSupabaseAdmin.from
        .mockReturnValueOnce(mockIncomeQuery)
        .mockReturnValueOnce(mockExpenseQuery);

      const response = await request(app).get("/summary/cashflow").expect(200);

      expect(response.body.totals.income).toBe(100000);
      expect(response.body.totals.expense).toBe(500000);
      expect(response.body.totals.balance).toBe(-400000);
    });
  });
});
