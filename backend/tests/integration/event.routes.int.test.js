const request = require("supertest");

const app = require("../../src/app");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

const token = process.env.TEST_ADMIN_TOKEN;
const hasEnv = Boolean(
  process.env.SUPABASE_URL &&
    process.env.SUPABASE_SERVICE_ROLE_KEY &&
    token
);

const describeIfReady = hasEnv ? describe : describe.skip;

describeIfReady("Event Routes - Integration Tests", () => {
  const createdEventIds = [];

  afterAll(async () => {
    try {
      if (createdEventIds.length > 0) {
        await supabaseAdmin.from("events").delete().in("id", createdEventIds);
      }
    } catch (e) {
      // avoid failing suite on cleanup issues
    }
  });

  test("GET /events without token should return 401", async () => {
    const res = await request(app).get("/events");

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty("message");
    expect(res.body.message).toBe("Missing bearer token");
  });

  test("GET /events with token should return list", async () => {
    const res = await request(app)
      .get("/events")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  test("GET /events/:id should return 400 when id is invalid", async () => {
    const res = await request(app)
      .get("/events/invalid")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty("message");
    expect(res.body.message).toContain("Invalid id");
  });

  test("POST /events should create new event with valid data", async () => {
    const payload = {
      title: `TEST_EVENT_${Date.now()}`,
      description: "Integration test event",
      start_datetime: "2025-12-28T08:00:00.000Z",
      end_datetime: "2025-12-28T12:00:00.000Z",
      location: "TEST_LOCATION",
      status: "planned",
      rw: 1,
      rt: null,
    };

    const res = await request(app)
      .post("/events")
      .set("Authorization", `Bearer ${token}`)
      .send(payload);

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("data");
    expect(res.body.data.title).toBe(payload.title);
    expect(res.body.data.status).toBe("planned");

    createdEventIds.push(res.body.data.id);
  });

  test("GET /events should include created event", async () => {
    const payload = {
      title: `TEST_EVENT_${Date.now()}`,
      description: "Integration test event 2",
      start_datetime: "2025-12-29T08:00:00.000Z",
      rw: 1,
      rt: null,
      status: "planned",
    };

    const createRes = await request(app)
      .post("/events")
      .set("Authorization", `Bearer ${token}`)
      .send(payload);

    expect(createRes.status).toBe(201);
    const eventId = createRes.body.data.id;
    createdEventIds.push(eventId);

    const listRes = await request(app)
      .get("/events")
      .set("Authorization", `Bearer ${token}`);

    expect(listRes.status).toBe(200);
    const found = listRes.body.data.find((x) => x.id === eventId);
    expect(found).toBeTruthy();
    expect(found.title).toBe(payload.title);
  });
});

if (!hasEnv) {
  // eslint-disable-next-line no-console
  console.warn(
    "[integration] Skipping Event integration tests. " +
      "Require SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and TEST_ADMIN_TOKEN in .env.test. " +
      "You can generate TEST_ADMIN_TOKEN via backend/scripts/get-test-token.js"
  );
}
