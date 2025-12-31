const request = require("supertest");
const app = require("../../src/app");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

/**
 * Integration Test untuk Aspiration API
 * 
 * IMPORTANT: Test ini menggunakan database sebenarnya, bukan mock.
 * 
 * SETUP REQUIREMENTS:
 * 1. Update file .env.test dengan kredensial Supabase yang VALID
 * 2. Buat test user dengan role admin di Supabase Dashboard
 * 3. Jalankan: npm run get-token
 * 4. Copy token ke .env.test sebagai TEST_ADMIN_TOKEN
 */

describe("Aspiration API - Integration Tests", () => {
  let authToken;
  let createdAspirationId;

  beforeAll(() => {
    // Ambil token dari environment variable
    authToken = process.env.TEST_ADMIN_TOKEN;
    
    if (!authToken) {
      console.warn("\n⚠️  SKIPPING ASPIRATION INTEGRATION TESTS");
      console.warn("Reason: TEST_ADMIN_TOKEN not found in .env.test\n");
      console.warn("Setup instructions:");
      console.warn("1. Update .env.test dengan kredensial Supabase yang valid");
      console.warn("2. Buat test user dengan role admin");
      console.warn("3. Run: npm run get-token");
      console.warn("4. Copy token ke .env.test\n");
    }
  });

  afterAll(async () => {
    // Cleanup: Hapus data test yang dibuat
    if (createdAspirationId) {
      try {
        await supabaseAdmin
          .from("aspirations")
          .delete()
          .eq("id", createdAspirationId);
      } catch (error) {
        console.error("Cleanup error:", error.message);
      }
    }
  });

  describe("GET /aspirations", () => {
    test("should return 401 without authentication", async () => {
      if (!authToken) return; // Skip jika token tidak ada
      
      const response = await request(app)
        .get("/aspirations")
        .expect(401);

      expect(response.body).toHaveProperty("message");
    });

    test("should return list of aspirations with valid auth", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .get("/aspirations")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(Array.isArray(response.body.data)).toBe(true);
      
      // Verify structure if data exists
      if (response.body.data.length > 0) {
        const aspiration = response.body.data[0];
        expect(aspiration).toHaveProperty("id");
        expect(aspiration).toHaveProperty("title");
        expect(aspiration).toHaveProperty("description");
        expect(aspiration).toHaveProperty("status");
      }
    });
  });

  describe("GET /aspirations/:id", () => {
    test("should return 401 without authentication", async () => {
      await request(app)
        .get("/aspirations/1")
        .expect(401);
    });

    test("should return 400 for invalid id format", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .get("/aspirations/invalid")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(400);

      expect(response.body.message).toContain("Invalid id");
    });

    test("should return 404 for non-existent aspiration", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      await request(app)
        .get("/aspirations/999999")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe("PATCH /aspirations/:id/status", () => {
    test("should return 401 without authentication", async () => {
      await request(app)
        .patch("/aspirations/1/status")
        .send({ status: "resolved" })
        .expect(401);
    });

    test("should return 400 for invalid status", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .patch("/aspirations/1/status")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ status: "invalid_status" })
        .expect(400);

      expect(response.body.message).toContain("tidak valid");
    });

    test("should return 400 for invalid id", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .patch("/aspirations/invalid/status")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ status: "resolved" })
        .expect(400);

      expect(response.body.message).toContain("Invalid id");
    });
  });

  describe("POST /aspirations", () => {
    test("should return 401 without authentication", async () => {
      const newAspiration = {
        title: "Test Aspiration",
        description: "Test description",
      };

      await request(app)
        .post("/aspirations")
        .send(newAspiration)
        .expect(401);
    });

    test("should return 403 for admin/moderator (only warga can create)", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const newAspiration = {
        title: "Test Aspiration",
        description: "Test description",
        category: "infrastruktur",
      };

      const response = await request(app)
        .post("/aspirations")
        .set("Authorization", `Bearer ${authToken}`)
        .send(newAspiration)
        .expect(403);

      expect(response.body.message).toContain("Moderator tidak dapat membuat aspirasi");
    });
  });
});
