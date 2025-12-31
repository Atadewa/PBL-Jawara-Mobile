const request = require("supertest");

// Untuk integration tests, kita TIDAK mock Supabase
// Kita gunakan real database connection dari .env.test
const app = require("../../src/app");

describe("API Integration Tests", () => {
  describe("Health Check Endpoints", () => {
    test("GET /health should return success", async () => {
      const response = await request(app).get("/health").expect(200);

      expect(response.body).toHaveProperty("ok", true);
      expect(response.body.message).toContain("Jawara API");
    });

    test("GET /health2 should return success", async () => {
      const response = await request(app).get("/health2").expect(200);

      expect(response.body).toHaveProperty("ok", true);
    });
  });

  describe("Authentication Flow", () => {
    let authToken;

    // Skip jika tidak ada test credentials
    const TEST_EMAIL = process.env.TEST_USER_EMAIL;
    const TEST_PASSWORD = process.env.TEST_USER_PASSWORD;

    const shouldSkip = !TEST_EMAIL || !TEST_PASSWORD;

    test.skip("should authenticate user and return token", async () => {
      if (shouldSkip) {
        console.log("Skipping: No test credentials in environment");
        return;
      }

      // Login test (ini tergantung implementasi auth route kamu)
      // Sesuaikan dengan endpoint login yang sebenarnya
      const response = await request(app).post("/auth/login").send({
        email: TEST_EMAIL,
        password: TEST_PASSWORD,
      });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty("token");
      authToken = response.body.token;
    });

    test("should access protected route with valid token", async () => {
      const ADMIN_TOKEN = process.env.TEST_ADMIN_TOKEN;

      if (!ADMIN_TOKEN) {
        console.log("Skipping: No admin token in .env.test");
        return;
      }

      const response = await request(app)
        .get("/auth/me")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body).toHaveProperty("user");
      expect(response.body).toHaveProperty("roles");
    });

    test("should return 401 for protected route without token", async () => {
      const response = await request(app).get("/auth/me").expect(401);

      expect(response.body.message).toContain("Missing bearer token");
    });
  });

  describe("Income API Integration", () => {
    const ADMIN_TOKEN = process.env.TEST_ADMIN_TOKEN;

    test("should get list of incomes with valid auth", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No admin token in environment");
        return;
      }

      const response = await request(app)
        .get("/incomes")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    test("should create new income with valid data", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No admin token in environment");
        return;
      }

      const newIncome = {
        source_name: "TEST_Integration Test Income",
        amount: 50000,
        date: new Date().toISOString().split("T")[0],
        description: "Created by integration test",
        payment_method: "cash",
        rw: 1,
      };

      const response = await request(app)
        .post("/incomes")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(newIncome)
        .expect(201);

      expect(response.body).toHaveProperty("data");

      // Cleanup: Delete test data
      const createdId = response.body.data?.id;
      if (createdId) {
        await request(app)
          .delete(`/incomes/${createdId}`)
          .set("Authorization", `Bearer ${ADMIN_TOKEN}`);
      }
    });
  });

  describe("Error Handling", () => {
    test("should return 404 for non-existent routes", async () => {
      const response = await request(app)
        .get("/non-existent-route")
        .expect(404);
    });
  });
});
