const request = require("supertest");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

// Integration test menggunakan real database connection
const app = require("../../src/app");

describe("Expense API Integration Tests", () => {
  const ADMIN_TOKEN = process.env.TEST_ADMIN_TOKEN;
  const RW_TOKEN = process.env.TEST_RW_TOKEN;
  const RT_TOKEN = process.env.TEST_RT_TOKEN;

  let createdExpenseIds = [];
  let testEventId = null;
  let testBroadcastId = null;

  // Helper untuk cleanup
  const cleanup = async () => {
    if (createdExpenseIds.length > 0) {
      await supabaseAdmin
        .from("expenses")
        .delete()
        .in("id", createdExpenseIds);
      createdExpenseIds = [];
    }
  };

  // Setup test data sebelum test dimulai
  beforeAll(async () => {
    // Create test event untuk testing expense dengan event_id
    const { data: event } = await supabaseAdmin
      .from("events")
      .insert({
        rw: 1,
        rt: null,
        title: "TEST_Event for Expense Integration",
        description: "Test event",
        start_datetime: new Date().toISOString(),
        end_datetime: new Date(Date.now() + 3600000).toISOString(),
        location: "Test Location",
        status: "planned",
        created_by_user_id: "test-user-id",
      })
      .select("id")
      .single();

    if (event) testEventId = event.id;

    // Create test broadcast untuk testing expense dengan broadcast_id
    const { data: broadcast } = await supabaseAdmin
      .from("broadcasts")
      .insert({
        rw: 1,
        rt: null,
        title: "TEST_Broadcast for Expense Integration",
        content: "Test broadcast",
        status: "published",
        created_by_user_id: "test-user-id",
      })
      .select("id")
      .single();

    if (broadcast) testBroadcastId = broadcast.id;
  });

  // Cleanup setelah semua test selesai
  afterAll(async () => {
    await cleanup();

    // Delete test event dan broadcast
    if (testEventId) {
      await supabaseAdmin.from("events").delete().eq("id", testEventId);
    }
    if (testBroadcastId) {
      await supabaseAdmin.from("broadcasts").delete().eq("id", testBroadcastId);
    }
  });

  // Cleanup setelah setiap test
  afterEach(async () => {
    await cleanup();
  });

  describe("GET /expenses - List Expenses", () => {
    test("should return expenses list with admin token", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    test("should return 401 without authentication", async () => {
      const response = await request(app).get("/expenses").expect(401);

      expect(response.body.message).toContain("Missing bearer token");
    });

    test("should filter expenses by scope for RW user", async () => {
      if (!RW_TOKEN) {
        console.log("Skipping: No RW_TOKEN in environment");
        return;
      }

      // Create expense di RW 1
      const expense = {
        description: "TEST_RW Scope Expense",
        amount: 100000,
        date: new Date().toISOString().split("T")[0],
        expense_type: "operational",
        rw: 1,
      };

      const createResponse = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${RW_TOKEN}`)
        .send(expense)
        .expect(201);

      createdExpenseIds.push(createResponse.body.data.id);

      // Get expenses - harus dapat expense RW 1
      const response = await request(app)
        .get("/expenses")
        .set("Authorization", `Bearer ${RW_TOKEN}`)
        .expect(200);

      expect(response.body.data).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            rw: 1,
          }),
        ])
      );
    });
  });

  describe("POST /expenses - Create Expense", () => {
    describe("Happy Path - Create Operational Expense", () => {
      test("should create operational expense with valid data", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const newExpense = {
          description: "TEST_Operational Expense",
          amount: 500000,
          date: new Date().toISOString().split("T")[0],
          payment_method: "cash",
          expense_type: "operational",
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(newExpense)
          .expect(201);

        expect(response.body).toHaveProperty("data");
        expect(response.body.data).toMatchObject({
          description: newExpense.description,
          amount: String(newExpense.amount),
          expense_type: "operational",
          rw: 1,
        });
        expect(response.body.data).toHaveProperty("id");
        expect(response.body.data).toHaveProperty("recorded_by_user_id");

        createdExpenseIds.push(response.body.data.id);
      });

      test("should create expense with default type 'other' when type not specified", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const newExpense = {
          description: "TEST_Default Type Expense",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(newExpense)
          .expect(201);

        expect(response.body.data.expense_type).toBe("other");
        createdExpenseIds.push(response.body.data.id);
      });
    });

    describe("Happy Path - Create Event Expense", () => {
      test("should create expense linked to event", async () => {
        if (!ADMIN_TOKEN || !testEventId) {
          console.log("Skipping: No ADMIN_TOKEN or testEventId");
          return;
        }

        const newExpense = {
          description: "TEST_Event Expense",
          amount: 1500000,
          date: new Date().toISOString().split("T")[0],
          payment_method: "transfer",
          expense_type: "event",
          event_id: testEventId,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(newExpense)
          .expect(201);

        expect(response.body.data).toMatchObject({
          expense_type: "event",
          event_id: testEventId,
        });

        createdExpenseIds.push(response.body.data.id);
      });
    });

    describe("Happy Path - Create Broadcast Expense", () => {
      test("should create expense linked to broadcast", async () => {
        if (!ADMIN_TOKEN || !testBroadcastId) {
          console.log("Skipping: No ADMIN_TOKEN or testBroadcastId");
          return;
        }

        const newExpense = {
          description: "TEST_Broadcast Expense",
          amount: 200000,
          date: new Date().toISOString().split("T")[0],
          payment_method: "cash",
          expense_type: "broadcast",
          broadcast_id: testBroadcastId,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(newExpense)
          .expect(201);

        expect(response.body.data).toMatchObject({
          expense_type: "broadcast",
          broadcast_id: testBroadcastId,
        });

        createdExpenseIds.push(response.body.data.id);
      });
    });

    describe("Validation Tests - Required Fields", () => {
      test("should return 400 when description is missing", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("wajib diisi");
      });

      test("should return 400 when amount is missing", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Missing Amount",
          date: new Date().toISOString().split("T")[0],
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("wajib diisi");
      });

      test("should return 400 when date is missing", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Missing Date",
          amount: 100000,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("wajib diisi");
      });
    });

    describe("Validation Tests - Business Rules", () => {
      test("should return 400 when expense_type is invalid", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Invalid Type",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "invalid_type",
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("expense_type tidak valid");
      });

      test("should return 400 when both event_id and broadcast_id provided", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Both IDs",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "operational",
          event_id: 1,
          broadcast_id: 1,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("Pilih salah satu");
      });

      test("should return 400 when event type missing event_id", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Event No ID",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "event",
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("event_id");
      });

      test("should return 400 when broadcast type missing broadcast_id", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Broadcast No ID",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "broadcast",
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("broadcast_id");
      });

      test("should return 403 when event_id does not exist", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Non-existent Event",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "event",
          event_id: 999999,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(403);

        expect(response.body.message).toContain("Event tidak ditemukan");
      });

      test("should return 403 when broadcast_id does not exist", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Non-existent Broadcast",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          expense_type: "broadcast",
          broadcast_id: 999999,
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(403);

        expect(response.body.message).toContain("Broadcast tidak ditemukan");
      });
    });

    describe("Scope Enforcement Tests", () => {
      test("should return 400 when admin does not provide rw", async () => {
        if (!ADMIN_TOKEN) {
          console.log("Skipping: No ADMIN_TOKEN in environment");
          return;
        }

        const invalidExpense = {
          description: "TEST_Admin No RW",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
          .send(invalidExpense)
          .expect(400);

        expect(response.body.message).toContain("rw wajib untuk admin");
      });

      test("should enforce RW scope for RW user", async () => {
        if (!RW_TOKEN) {
          console.log("Skipping: No RW_TOKEN in environment");
          return;
        }

        const newExpense = {
          description: "TEST_RW Scope",
          amount: 200000,
          date: new Date().toISOString().split("T")[0],
          // rw tidak dikirim, akan di-enforce oleh scope
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${RW_TOKEN}`)
          .send(newExpense)
          .expect(201);

        // RW harus ter-enforce dari scope user
        expect(response.body.data.rw).toBeDefined();
        expect(response.body.data.rt).toBeNull();

        createdExpenseIds.push(response.body.data.id);
      });

      test("should enforce RT scope for RT user", async () => {
        if (!RT_TOKEN) {
          console.log("Skipping: No RT_TOKEN in environment");
          return;
        }

        const newExpense = {
          description: "TEST_RT Scope",
          amount: 150000,
          date: new Date().toISOString().split("T")[0],
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${RT_TOKEN}`)
          .send(newExpense)
          .expect(201);

        // RT dan RW harus ter-enforce dari scope user
        expect(response.body.data.rw).toBeDefined();
        expect(response.body.data.rt).toBeDefined();

        createdExpenseIds.push(response.body.data.id);
      });
    });

    describe("Authorization Tests", () => {
      test("should return 401 without authentication", async () => {
        const newExpense = {
          description: "TEST_No Auth",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
          rw: 1,
        };

        const response = await request(app)
          .post("/expenses")
          .send(newExpense)
          .expect(401);

        expect(response.body.message).toContain("Missing bearer token");
      });

      test("should return 403 for unauthorized role", async () => {
        const WARGA_TOKEN = process.env.TEST_WARGA_TOKEN;

        if (!WARGA_TOKEN) {
          console.log("Skipping: No WARGA_TOKEN in environment");
          return;
        }

        const newExpense = {
          description: "TEST_Warga Forbidden",
          amount: 100000,
          date: new Date().toISOString().split("T")[0],
        };

        const response = await request(app)
          .post("/expenses")
          .set("Authorization", `Bearer ${WARGA_TOKEN}`)
          .send(newExpense)
          .expect(403);

        expect(response.body.message).toBe("Forbidden");
      });
    });
  });

  describe("Database Integrity Tests", () => {
    test("should persist expense data correctly in database", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const newExpense = {
        description: "TEST_DB Integrity",
        amount: 750000,
        date: new Date().toISOString().split("T")[0],
        payment_method: "transfer",
        expense_type: "operational",
        rw: 1,
      };

      const response = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newExpense)
        .expect(201);

      const createdId = response.body.data.id;
      createdExpenseIds.push(createdId);

      // Verify di database
      const { data: dbExpense } = await supabaseAdmin
        .from("expenses")
        .select("*")
        .eq("id", createdId)
        .single();

      expect(dbExpense).toBeDefined();
      expect(dbExpense.description).toBe(newExpense.description);
      expect(dbExpense.amount).toBe(String(newExpense.amount));
      expect(dbExpense.expense_type).toBe("operational");
    });

    test("should create expense with timestamp fields", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const newExpense = {
        description: "TEST_Timestamps",
        amount: 100000,
        date: new Date().toISOString().split("T")[0],
        rw: 1,
      };

      const response = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newExpense)
        .expect(201);

      expect(response.body.data).toHaveProperty("created_at");
      expect(response.body.data.created_at).toBeTruthy();

      createdExpenseIds.push(response.body.data.id);
    });
  });

  describe("Edge Cases", () => {
    test("should handle large amount values", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const newExpense = {
        description: "TEST_Large Amount",
        amount: 999999999,
        date: new Date().toISOString().split("T")[0],
        rw: 1,
      };

      const response = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newExpense)
        .expect(201);

      expect(response.body.data.amount).toBe(String(newExpense.amount));
      createdExpenseIds.push(response.body.data.id);
    });

    test("should handle special characters in description", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const newExpense = {
        description: "TEST_Special Chars: @#$%^&*() 中文 العربية",
        amount: 100000,
        date: new Date().toISOString().split("T")[0],
        rw: 1,
      };

      const response = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newExpense)
        .expect(201);

      expect(response.body.data.description).toBe(newExpense.description);
      createdExpenseIds.push(response.body.data.id);
    });

    test("should handle future dates", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 30);

      const newExpense = {
        description: "TEST_Future Date",
        amount: 100000,
        date: futureDate.toISOString().split("T")[0],
        rw: 1,
      };

      const response = await request(app)
        .post("/expenses")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newExpense)
        .expect(201);

      expect(response.body.data.date).toBe(newExpense.date);
      createdExpenseIds.push(response.body.data.id);
    });
  });
});
