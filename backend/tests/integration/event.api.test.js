const request = require("supertest");
const app = require("../../src/app");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

/**
 * Integration Test untuk Event API
 * 
 * IMPORTANT: Test ini menggunakan database sebenarnya, bukan mock.
 * 
 * SETUP REQUIREMENTS:
 * 1. Update file .env.test dengan kredensial Supabase yang VALID
 * 2. Buat test user dengan role admin di Supabase Dashboard
 * 3. Jalankan: npm run get-token
 * 4. Copy token ke .env.test sebagai TEST_ADMIN_TOKEN
 */

describe("Event API - Integration Tests", () => {
  let authToken;
  let createdEventId;

  beforeAll(() => {
    // Ambil token dari environment variable
    authToken = process.env.TEST_ADMIN_TOKEN;
    
    if (!authToken) {
      console.warn("\n⚠️  SKIPPING EVENT INTEGRATION TESTS");
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
    if (createdEventId) {
      try {
        await supabaseAdmin
          .from("events")
          .delete()
          .eq("id", createdEventId);
      } catch (error) {
        console.error("Cleanup error:", error.message);
      }
    }
  });

  describe("GET /events", () => {
    test("should return 401 without authentication", async () => {
      if (!authToken) return; // Skip jika token tidak ada
      
      const response = await request(app)
        .get("/events")
        .expect(401);

      expect(response.body).toHaveProperty("message");
    });

    test("should return list of events with valid auth", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .get("/events")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(Array.isArray(response.body.data)).toBe(true);
      
      // Verify structure if data exists
      if (response.body.data.length > 0) {
        const event = response.body.data[0];
        expect(event).toHaveProperty("id");
        expect(event).toHaveProperty("title");
        expect(event).toHaveProperty("description");
        expect(event).toHaveProperty("start_datetime");
        expect(event).toHaveProperty("status");
      }
    });

    test("should filter events by status", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .get("/events?status=planned")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      
      // All returned events should have status "planned"
      response.body.data.forEach((event) => {
        expect(event.status).toBe("planned");
      });
    });

    test("should filter events by date range", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const fromDate = "2025-01-01";
      const toDate = "2025-12-31";

      const response = await request(app)
        .get(`/events?from=${fromDate}&to=${toDate}`)
        .set("Authorization", `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
    });
  });

  describe("GET /events/:id", () => {
    test("should return 401 without authentication", async () => {
      await request(app)
        .get("/events/1")
        .expect(401);
    });

    test("should return 400 for invalid id format", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .get("/events/invalid")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(400);

      expect(response.body.message).toContain("Invalid id");
    });

    test("should return 404 for non-existent event", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      await request(app)
        .get("/events/999999")
        .set("Authorization", `Bearer ${authToken}`)
        .expect(404);
    });
  });

  describe("POST /events", () => {
    test("should return 401 without authentication", async () => {
      const newEvent = {
        title: "Test Event",
        description: "Test description",
        start_datetime: new Date(Date.now() + 86400000).toISOString(),
      };

      await request(app)
        .post("/events")
        .send(newEvent)
        .expect(401);
    });

    test("should create new event with valid data and auth", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const newEvent = {
        rw: 1,
        title: `Test Event ${Date.now()}`,
        description: "Event from integration test",
        start_datetime: new Date(Date.now() + 86400000).toISOString(), // Tomorrow
        end_datetime: new Date(Date.now() + 90000000).toISOString(),
        location: "Test Location",
        status: "planned",
      };

      const response = await request(app)
        .post("/events")
        .set("Authorization", `Bearer ${authToken}`)
        .send(newEvent)
        .expect(201);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data).toHaveProperty("id");
      expect(response.body.data.title).toBe(newEvent.title);
      expect(response.body.data.status).toBe("planned");

      // Save ID for cleanup
      createdEventId = response.body.data.id;
    });

    test("should return 400 when required fields are missing", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const invalidEvent = {
        description: "Missing title and start_datetime",
      };

      const response = await request(app)
        .post("/events")
        .set("Authorization", `Bearer ${authToken}`)
        .send(invalidEvent)
        .expect(400);

      expect(response.body.message).toContain("wajib diisi");
    });

    test("should return 400 for invalid status", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const invalidEvent = {
        rw: 1,
        title: "Test Event",
        description: "Test",
        start_datetime: new Date().toISOString(),
        status: "invalid_status",
      };

      const response = await request(app)
        .post("/events")
        .set("Authorization", `Bearer ${authToken}`)
        .send(invalidEvent)
        .expect(400);

      expect(response.body.message).toContain("tidak valid");
    });
  });

  describe("PATCH /events/:id", () => {
    test("should return 401 without authentication", async () => {
      await request(app)
        .patch("/events/1")
        .send({ title: "Updated Title" })
        .expect(401);
    });

    test("should return 400 for invalid id", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .patch("/events/invalid")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ title: "Updated" })
        .expect(400);

      expect(response.body.message).toContain("Invalid id");
    });

    test("should update event with valid auth and data", async () => {
      if (!authToken || !createdEventId) {
        console.log("⏭️  Skipping: No auth token or test event");
        return;
      }

      const updateData = {
        title: `Updated Test Event ${Date.now()}`,
        description: "Updated description",
      };

      const response = await request(app)
        .patch(`/events/${createdEventId}`)
        .set("Authorization", `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.title).toBe(updateData.title);
      expect(response.body.data.description).toBe(updateData.description);
    });
  });

  describe("PATCH /events/:id/status", () => {
    test("should return 401 without authentication", async () => {
      await request(app)
        .patch("/events/1/status")
        .send({ status: "ongoing" })
        .expect(401);
    });

    test("should return 400 for invalid status", async () => {
      if (!authToken) {
        console.log("⏭️  Skipping: No auth token");
        return;
      }

      const response = await request(app)
        .patch("/events/1/status")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ status: "invalid_status" })
        .expect(400);

      expect(response.body.message).toContain("tidak valid");
    });

    test("should update event status with valid data", async () => {
      if (!authToken || !createdEventId) {
        console.log("⏭️  Skipping: No auth token or test event");
        return;
      }

      const response = await request(app)
        .patch(`/events/${createdEventId}/status`)
        .set("Authorization", `Bearer ${authToken}`)
        .send({ status: "ongoing" })
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(response.body.data.status).toBe("ongoing");
    });
  });
});
