const express = require("express");
const request = require("supertest");
const incomeRoutes = require("../../src/routes/income.routes");

// Mock dependencies
jest.mock("../../src/middlewares/requireAuth");
jest.mock("../../src/lib/supabaseAdmin");

const { requireAuth } = require("../../src/middlewares/requireAuth");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

describe("Income Routes Integration Tests", () => {
  let app;
  let currentUserContext;
  let mockQueryBuilder;

  // Default user context (admin with full access)
  const defaultUserContext = {
    appUser: { id: "test-user-123", email: "admin@test.com" },
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
    app.use("/incomes", incomeRoutes);

    // Mock requireAuth middleware
    requireAuth.mockImplementation((req, res, next) => {
      req.userContext = currentUserContext;
      next();
    });

    // Setup mock query builder for chainable methods
    mockQueryBuilder = {
      select: jest.fn().mockReturnThis(),
      order: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      single: jest.fn(),
      then: null, // Will be set per test
    };

    // Mock supabaseAdmin.from to return the query builder
    supabaseAdmin.from = jest.fn().mockReturnValue(mockQueryBuilder);
  });

  describe("GET /incomes", () => {
    test("should return incomes successfully with scope.mode='all'", async () => {
      const mockIncomes = [
        {
          id: 1,
          rw: 2,
          rt: 3,
          source_name: "Iuran Bulanan",
          amount: 50000,
          date: "2025-01-15",
        },
        {
          id: 2,
          rw: 1,
          rt: null,
          source_name: "Donasi",
          amount: 100000,
          date: "2025-01-10",
        },
      ];

      // Make query builder thenable for GET requests
      mockQueryBuilder.then = (resolve) =>
        Promise.resolve(resolve({ data: mockIncomes, error: null }));

      currentUserContext.scope = { mode: "all", rw: null, rt: null };

      const response = await request(app).get("/incomes");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({ data: mockIncomes });
      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQueryBuilder.select).toHaveBeenCalledWith("*");
      expect(mockQueryBuilder.order).toHaveBeenCalledWith("date", {
        ascending: false,
      });
      expect(mockQueryBuilder.eq).not.toHaveBeenCalled();
    });

    test("should filter by rw when scope.mode='rw'", async () => {
      const mockIncomes = [
        {
          id: 1,
          rw: 2,
          rt: null,
          source_name: "Iuran RW 2",
          amount: 50000,
          date: "2025-01-15",
        },
      ];

      mockQueryBuilder.then = (resolve) =>
        Promise.resolve(resolve({ data: mockIncomes, error: null }));

      currentUserContext.scope = { mode: "rw", rw: 2, rt: null };

      const response = await request(app).get("/incomes");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({ data: mockIncomes });
      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQueryBuilder.select).toHaveBeenCalledWith("*");
      expect(mockQueryBuilder.order).toHaveBeenCalledWith("date", {
        ascending: false,
      });
      expect(mockQueryBuilder.eq).toHaveBeenCalledWith("rw", 2);
      expect(mockQueryBuilder.eq).toHaveBeenCalledTimes(1);
    });

    test("should filter by rw and rt when scope.mode='rt'", async () => {
      const mockIncomes = [
        {
          id: 1,
          rw: 2,
          rt: 5,
          source_name: "Iuran RT 5",
          amount: 30000,
          date: "2025-01-15",
        },
      ];

      mockQueryBuilder.then = (resolve) =>
        Promise.resolve(resolve({ data: mockIncomes, error: null }));

      currentUserContext.scope = { mode: "rt", rw: 2, rt: 5 };

      const response = await request(app).get("/incomes");

      expect(response.status).toBe(200);
      expect(response.body).toEqual({ data: mockIncomes });
      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQueryBuilder.select).toHaveBeenCalledWith("*");
      expect(mockQueryBuilder.order).toHaveBeenCalledWith("date", {
        ascending: false,
      });
      expect(mockQueryBuilder.eq).toHaveBeenCalledWith("rw", 2);
      expect(mockQueryBuilder.eq).toHaveBeenCalledWith("rt", 5);
      expect(mockQueryBuilder.eq).toHaveBeenCalledTimes(2);
    });

    test("should return 500 when supabase returns an error", async () => {
      mockQueryBuilder.then = (resolve) =>
        Promise.resolve(
          resolve({ data: null, error: { message: "Database error" } })
        );

      const response = await request(app).get("/incomes");

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ message: "Database error" });
    });

    test("should return 500 when an exception is thrown", async () => {
      supabaseAdmin.from.mockImplementation(() => {
        throw new Error("Boom");
      });

      const response = await request(app).get("/incomes");

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ message: "Boom" });
    });
  });

  describe("POST /incomes", () => {
    test("should return 403 for forbidden role", async () => {
      currentUserContext.roleNames = ["warga"];

      const body = {
        source_name: "Iuran",
        amount: 50000,
        date: "2025-01-15",
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(403);
      expect(response.body).toEqual({ message: "Forbidden" });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when source_name is missing", async () => {
      currentUserContext.roleNames = ["admin"];

      const body = {
        amount: 50000,
        date: "2025-01-15",
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(400);
      expect(response.body).toEqual({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when amount is missing", async () => {
      currentUserContext.roleNames = ["admin"];

      const body = {
        source_name: "Iuran",
        date: "2025-01-15",
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(400);
      expect(response.body).toEqual({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when date is missing", async () => {
      currentUserContext.roleNames = ["admin"];

      const body = {
        source_name: "Iuran",
        amount: 50000,
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(400);
      expect(response.body).toEqual({
        message: "source_name, amount, date wajib diisi",
      });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 400 when admin scope.mode='all' but rw is missing", async () => {
      currentUserContext.roleNames = ["admin"];
      currentUserContext.scope = { mode: "all", rw: null, rt: null };

      const body = {
        source_name: "Iuran",
        amount: 50000,
        date: "2025-01-15",
        // rw not provided
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(400);
      expect(response.body).toEqual({ message: "rw wajib untuk admin" });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should return 403 for invalid scope mode", async () => {
      currentUserContext.roleNames = ["admin"];
      currentUserContext.scope = { mode: "unknown", rw: null, rt: null };

      const body = {
        source_name: "Iuran",
        amount: 50000,
        date: "2025-01-15",
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(403);
      expect(response.body).toEqual({ message: "No scope access" });
      expect(supabaseAdmin.from).not.toHaveBeenCalled();
    });

    test("should create income successfully with scope.mode='rw' and override rw/rt", async () => {
      currentUserContext.roleNames = ["bendahara"];
      currentUserContext.scope = { mode: "rw", rw: 3, rt: null };
      currentUserContext.appUser = { id: "user-456" };

      const mockCreatedIncome = {
        id: 10,
        rw: 3,
        rt: null,
        source_name: "Iuran Bulanan",
        description: null,
        amount: 75000,
        date: "2025-01-20",
        payment_method: null,
        recorded_by_user_id: "user-456",
      };

      // Mock the insert chain
      mockQueryBuilder.single.mockResolvedValue({
        data: mockCreatedIncome,
        error: null,
      });

      const body = {
        source_name: "Iuran Bulanan",
        amount: 75000,
        date: "2025-01-20",
        rw: 99, // Should be overridden to 3
        rt: 88, // Should be overridden to null
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(201);
      expect(response.body).toEqual({ data: mockCreatedIncome });
      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQueryBuilder.insert).toHaveBeenCalledWith({
        rw: 3,
        rt: null,
        source_name: "Iuran Bulanan",
        description: null,
        amount: 75000,
        date: "2025-01-20",
        payment_method: null,
        recorded_by_user_id: "user-456",
      });
      expect(mockQueryBuilder.select).toHaveBeenCalledWith("*");
      expect(mockQueryBuilder.single).toHaveBeenCalled();
    });

    test("should create income successfully with scope.mode='rt' and override rw/rt", async () => {
      currentUserContext.roleNames = ["ketua_rt"];
      currentUserContext.scope = { mode: "rt", rw: 3, rt: 7 };
      currentUserContext.appUser = { id: "user-789" };

      const mockCreatedIncome = {
        id: 11,
        rw: 3,
        rt: 7,
        source_name: "Kas RT",
        description: "Pemasukan kas",
        amount: 100000,
        date: "2025-01-21",
        payment_method: "tunai",
        recorded_by_user_id: "user-789",
      };

      mockQueryBuilder.single.mockResolvedValue({
        data: mockCreatedIncome,
        error: null,
      });

      const body = {
        source_name: "Kas RT",
        description: "Pemasukan kas",
        amount: 100000,
        date: "2025-01-21",
        payment_method: "tunai",
        rw: 99, // Should be overridden to 3
        rt: 88, // Should be overridden to 7
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(201);
      expect(response.body).toEqual({ data: mockCreatedIncome });
      expect(supabaseAdmin.from).toHaveBeenCalledWith("incomes");
      expect(mockQueryBuilder.insert).toHaveBeenCalledWith({
        rw: 3,
        rt: 7,
        source_name: "Kas RT",
        description: "Pemasukan kas",
        amount: 100000,
        date: "2025-01-21",
        payment_method: "tunai",
        recorded_by_user_id: "user-789",
      });
      expect(mockQueryBuilder.select).toHaveBeenCalledWith("*");
      expect(mockQueryBuilder.single).toHaveBeenCalled();
    });

    test("should create income with admin scope.mode='all' when rw is provided", async () => {
      currentUserContext.roleNames = ["admin"];
      currentUserContext.scope = { mode: "all", rw: null, rt: null };
      currentUserContext.appUser = { id: "admin-001" };

      const mockCreatedIncome = {
        id: 12,
        rw: 5,
        rt: 10,
        source_name: "Donasi",
        description: "Donasi dari warga",
        amount: 200000,
        date: "2025-01-22",
        payment_method: "transfer",
        recorded_by_user_id: "admin-001",
      };

      mockQueryBuilder.single.mockResolvedValue({
        data: mockCreatedIncome,
        error: null,
      });

      const body = {
        source_name: "Donasi",
        description: "Donasi dari warga",
        amount: 200000,
        date: "2025-01-22",
        payment_method: "transfer",
        rw: 5,
        rt: 10,
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(201);
      expect(response.body).toEqual({ data: mockCreatedIncome });
      expect(mockQueryBuilder.insert).toHaveBeenCalledWith({
        rw: 5,
        rt: 10,
        source_name: "Donasi",
        description: "Donasi dari warga",
        amount: 200000,
        date: "2025-01-22",
        payment_method: "transfer",
        recorded_by_user_id: "admin-001",
      });
    });

    test("should default description and payment_method to null when omitted", async () => {
      currentUserContext.roleNames = ["sekretaris"];
      currentUserContext.scope = { mode: "rw", rw: 2, rt: null };
      currentUserContext.appUser = { id: "user-sec" };

      const mockCreatedIncome = {
        id: 13,
        rw: 2,
        rt: null,
        source_name: "Iuran",
        description: null,
        amount: 50000,
        date: "2025-01-23",
        payment_method: null,
        recorded_by_user_id: "user-sec",
      };

      mockQueryBuilder.single.mockResolvedValue({
        data: mockCreatedIncome,
        error: null,
      });

      const body = {
        source_name: "Iuran",
        amount: 50000,
        date: "2025-01-23",
        // description and payment_method omitted
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(201);
      expect(mockQueryBuilder.insert).toHaveBeenCalledWith({
        rw: 2,
        rt: null,
        source_name: "Iuran",
        description: null,
        amount: 50000,
        date: "2025-01-23",
        payment_method: null,
        recorded_by_user_id: "user-sec",
      });
    });

    test("should return 500 when supabase insert returns an error", async () => {
      currentUserContext.roleNames = ["admin"];
      currentUserContext.scope = { mode: "all", rw: null, rt: null };

      mockQueryBuilder.single.mockResolvedValue({
        data: null,
        error: { message: "Insert failed" },
      });

      const body = {
        source_name: "Test",
        amount: 50000,
        date: "2025-01-15",
        rw: 1,
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ message: "Insert failed" });
    });

    test("should return 500 when an exception is thrown during POST", async () => {
      currentUserContext.roleNames = ["admin"];
      currentUserContext.scope = { mode: "all", rw: null, rt: null };

      supabaseAdmin.from.mockImplementation(() => {
        throw new Error("Unexpected error");
      });

      const body = {
        source_name: "Test",
        amount: 50000,
        date: "2025-01-15",
        rw: 1,
      };

      const response = await request(app).post("/incomes").send(body);

      expect(response.status).toBe(500);
      expect(response.body).toEqual({ message: "Unexpected error" });
    });
  });
});
