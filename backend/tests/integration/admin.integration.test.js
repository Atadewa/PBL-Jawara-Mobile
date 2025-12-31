const request = require("supertest");
const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

// Integration test menggunakan real database connection
const app = require("../../src/app");

describe("Admin API Integration Tests", () => {
  const ADMIN_TOKEN = process.env.TEST_ADMIN_TOKEN;
  const RW_TOKEN = process.env.TEST_RW_TOKEN;
  const WARGA_TOKEN = process.env.TEST_WARGA_TOKEN;

  let createdUserIds = [];
  let createdResidentIds = [];
  let createdUserRoleIds = [];
  let testRoleMap = new Map();

  // Helper untuk cleanup
  const cleanup = async () => {
    if (createdUserRoleIds.length > 0) {
      await supabaseAdmin
        .from("user_roles")
        .delete()
        .in("id", createdUserRoleIds);
      createdUserRoleIds = [];
    }

    if (createdUserIds.length > 0) {
      await supabaseAdmin.from("users").delete().in("id", createdUserIds);
      createdUserIds = [];
    }

    if (createdResidentIds.length > 0) {
      await supabaseAdmin
        .from("residents")
        .delete()
        .in("id", createdResidentIds);
      createdResidentIds = [];
    }
  };

  // Setup test data sebelum test dimulai
  beforeAll(async () => {
    // Fetch roles map untuk test
    const { data: roles } = await supabaseAdmin
      .from("roles")
      .select("id,name");

    if (roles) {
      roles.forEach((role) => {
        testRoleMap.set(role.name, role.id);
      });
    }
  });

  // Cleanup setelah semua test selesai
  afterAll(async () => {
    await cleanup();
  });

  // Cleanup setelah setiap test
  afterEach(async () => {
    await cleanup();
  });

  describe("GET /admin/users - List Users", () => {
    test("should return paginated users list with admin token", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body).toHaveProperty("data");
      expect(Array.isArray(response.body.data)).toBe(true);
      expect(response.body).toHaveProperty("page");
      expect(response.body).toHaveProperty("limit");
      expect(response.body).toHaveProperty("total");
    });

    test("should support pagination parameters", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users?page=1&limit=5")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.page).toBe(1);
      expect(response.body.limit).toBe(5);
      expect(response.body.data.length).toBeLessThanOrEqual(5);
    });

    test("should filter by status=pending", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users?status=pending")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      // All users should have is_active=false
      if (response.body.data.length > 0) {
        response.body.data.forEach((user) => {
          expect(user.is_active).toBe(false);
        });
      }
    });

    test("should filter by status=active", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users?status=active")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      // All users should have is_active=true
      if (response.body.data.length > 0) {
        response.body.data.forEach((user) => {
          expect(user.is_active).toBe(true);
        });
      }
    });

    test("should support search by name/email/phone", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users?search=test")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN) {
        console.log("Skipping: No WARGA_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users")
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });

    test("should return 401 without authentication", async () => {
      const response = await request(app).get("/admin/users").expect(401);

      expect(response.body.message).toContain("Missing bearer token");
    });
  });

  describe("GET /admin/users/:id - Get User Detail", () => {
    let testUserId;

    beforeEach(async () => {
      // Create test user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Admin Detail User",
          email: `test-detail-${Date.now()}@testing.local`,
          phone: "081234567890",
          is_active: true,
        })
        .select("id")
        .single();

      if (user) {
        testUserId = user.id;
        createdUserIds.push(user.id);
      }
    });

    test("should return user detail by id", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .get(`/admin/users/${testUserId}`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.id).toBe(testUserId);
      expect(response.body.data).toHaveProperty("name");
      expect(response.body.data).toHaveProperty("email");
      expect(response.body.data).toHaveProperty("roles");
      expect(Array.isArray(response.body.data.roles)).toBe(true);
    });

    test("should return 400 for invalid user id", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users/invalid")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 404 when user not found", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .get("/admin/users/999999")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(404);

      expect(response.body.message).toBe("User not found");
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !testUserId) {
        console.log("Skipping: No WARGA_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .get(`/admin/users/${testUserId}`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/approve - Approve User", () => {
    let pendingUserId;

    beforeEach(async () => {
      // Create pending user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Pending User",
          email: `test-pending-${Date.now()}@testing.local`,
          phone: "081234567891",
          is_active: false,
        })
        .select("id")
        .single();

      if (user) {
        pendingUserId = user.id;
        createdUserIds.push(user.id);
      }
    });

    test("should approve pending user successfully", async () => {
      if (!ADMIN_TOKEN || !pendingUserId) {
        console.log("Skipping: No ADMIN_TOKEN or pendingUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${pendingUserId}/approve`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.id).toBe(pendingUserId);
      expect(response.body.data.is_active).toBe(true);

      // Verify in database
      const { data: dbUser } = await supabaseAdmin
        .from("users")
        .select("is_active")
        .eq("id", pendingUserId)
        .single();

      expect(dbUser.is_active).toBe(true);
    });

    test("should return 400 for invalid user id", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .patch("/admin/users/invalid/approve")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !pendingUserId) {
        console.log("Skipping: No WARGA_TOKEN or pendingUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${pendingUserId}/approve`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/deactivate - Deactivate User", () => {
    let activeUserId;

    beforeEach(async () => {
      // Create active user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Active User",
          email: `test-active-${Date.now()}@testing.local`,
          phone: "081234567892",
          is_active: true,
        })
        .select("id")
        .single();

      if (user) {
        activeUserId = user.id;
        createdUserIds.push(user.id);
      }
    });

    test("should deactivate active user successfully", async () => {
      if (!ADMIN_TOKEN || !activeUserId) {
        console.log("Skipping: No ADMIN_TOKEN or activeUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${activeUserId}/deactivate`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.id).toBe(activeUserId);
      expect(response.body.data.is_active).toBe(false);

      // Verify in database
      const { data: dbUser } = await supabaseAdmin
        .from("users")
        .select("is_active")
        .eq("id", activeUserId)
        .single();

      expect(dbUser.is_active).toBe(false);
    });

    test("should return 400 for invalid user id", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .patch("/admin/users/invalid/deactivate")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !activeUserId) {
        console.log("Skipping: No WARGA_TOKEN or activeUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${activeUserId}/deactivate`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("PATCH /admin/users/:id/link-resident - Link to Resident", () => {
    let testUserId;
    let testResidentId;

    beforeEach(async () => {
      // Create test user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Link User",
          email: `test-link-${Date.now()}@testing.local`,
          phone: "081234567893",
          is_active: true,
        })
        .select("id")
        .single();

      if (user) {
        testUserId = user.id;
        createdUserIds.push(user.id);
      }

      // Create test resident (need house first)
      const { data: house } = await supabaseAdmin
        .from("houses")
        .select("id")
        .eq("rw", 1)
        .eq("rt", 1)
        .limit(1)
        .single();

      if (house) {
        const { data: resident } = await supabaseAdmin
          .from("residents")
          .insert({
            house_id: house.id,
            full_name: "TEST_Resident for Link",
            nik: `TEST${Date.now()}`,
            kk_number: `TESTKK${Date.now()}`,
            date_of_birth: "1990-01-01",
            gender: "male",
            phone: "081234567894",
            relationship_status: "kepala_keluarga",
          })
          .select("id")
          .single();

        if (resident) {
          testResidentId = resident.id;
          createdResidentIds.push(resident.id);
        }
      }
    });

    test("should link user to resident successfully", async () => {
      if (!ADMIN_TOKEN || !testUserId || !testResidentId) {
        console.log("Skipping: No ADMIN_TOKEN, testUserId, or testResidentId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${testUserId}/link-resident`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ resident_id: testResidentId })
        .expect(200);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.id).toBe(testUserId);
      expect(response.body.data.resident_id).toBe(testResidentId);

      // Verify in database
      const { data: dbUser } = await supabaseAdmin
        .from("users")
        .select("resident_id")
        .eq("id", testUserId)
        .single();

      expect(dbUser.resident_id).toBe(testResidentId);
    });

    test("should return 400 when user id is invalid", async () => {
      if (!ADMIN_TOKEN || !testResidentId) {
        console.log("Skipping: No ADMIN_TOKEN or testResidentId");
        return;
      }

      const response = await request(app)
        .patch("/admin/users/invalid/link-resident")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ resident_id: testResidentId })
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 400 when resident_id is not a number", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${testUserId}/link-resident`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ resident_id: "invalid" })
        .expect(400);

      expect(response.body.message).toBe("resident_id wajib angka");
    });

    test("should return 404 when resident not found", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${testUserId}/link-resident`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ resident_id: 999999 })
        .expect(404);

      expect(response.body.message).toBe("Resident not found");
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !testUserId || !testResidentId) {
        console.log(
          "Skipping: No WARGA_TOKEN, testUserId, or testResidentId"
        );
        return;
      }

      const response = await request(app)
        .patch(`/admin/users/${testUserId}/link-resident`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .send({ resident_id: testResidentId })
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("POST /admin/users/:id/roles - Add Role", () => {
    let testUserId;

    beforeEach(async () => {
      // Create test user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Role User",
          email: `test-role-${Date.now()}@testing.local`,
          phone: "081234567895",
          is_active: true,
        })
        .select("id")
        .single();

      if (user) {
        testUserId = user.id;
        createdUserIds.push(user.id);
      }
    });

    test("should add warga role successfully", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const roleData = {
        role: "warga",
        rw: 1,
        rt: 1,
      };

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();
      expect(response.body.data.roles).toBeDefined();
      expect(response.body.data.roles.length).toBeGreaterThan(0);

      // Verify in database
      const { data: userRoles } = await supabaseAdmin
        .from("user_roles")
        .select("id,rw,rt")
        .eq("user_id", testUserId);

      expect(userRoles.length).toBeGreaterThan(0);
      createdUserRoleIds.push(...userRoles.map((ur) => ur.id));
    });

    test("should add admin role without scope", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const roleData = {
        role: "admin",
      };

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();

      // Verify in database
      const { data: userRoles } = await supabaseAdmin
        .from("user_roles")
        .select("id,rw,rt")
        .eq("user_id", testUserId);

      expect(userRoles.length).toBeGreaterThan(0);
      const adminRole = userRoles.find((ur) => ur.rw === null && ur.rt === null);
      expect(adminRole).toBeDefined();

      createdUserRoleIds.push(...userRoles.map((ur) => ur.id));
    });

    test("should add ketua_rw role with rw scope only", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const roleData = {
        role: "ketua_rw",
        rw: 1,
      };

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(roleData)
        .expect(201);

      expect(response.body.data).toBeDefined();

      // Verify in database
      const { data: userRoles } = await supabaseAdmin
        .from("user_roles")
        .select("id,rw,rt")
        .eq("user_id", testUserId);

      expect(userRoles.length).toBeGreaterThan(0);
      const rwRole = userRoles.find((ur) => ur.rw === 1 && ur.rt === null);
      expect(rwRole).toBeDefined();

      createdUserRoleIds.push(...userRoles.map((ur) => ur.id));
    });

    test("should return 400 when user id is invalid", async () => {
      if (!ADMIN_TOKEN) {
        console.log("Skipping: No ADMIN_TOKEN in environment");
        return;
      }

      const response = await request(app)
        .post("/admin/users/invalid/roles")
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ role: "warga", rw: 1, rt: 1 })
        .expect(400);

      expect(response.body.message).toBe("Invalid user id");
    });

    test("should return 400 when role is not provided", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({})
        .expect(400);

      expect(response.body.message).toBe("role wajib diisi");
    });

    test("should return 400 when role not found in database", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ role: "invalid_role" })
        .expect(400);

      expect(response.body.message).toBe("role tidak ditemukan di tabel roles");
    });

    test("should return 400 when warga role missing rw", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ role: "warga", rt: 1 })
        .expect(400);

      expect(response.body.message).toContain("rw wajib integer positif");
    });

    test("should return 400 when warga role missing rt", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ role: "warga", rw: 1 })
        .expect(400);

      expect(response.body.message).toContain("rt wajib integer positif");
    });

    test("should return 400 when ketua_rw has rt scope", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send({ role: "ketua_rw", rw: 1, rt: 1 })
        .expect(400);

      expect(response.body.message).toBe("rt harus null untuk ketua_rw");
    });

    test("should return 409 when role already exists", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const roleData = {
        role: "warga",
        rw: 1,
        rt: 1,
      };

      // Add role first time
      await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(roleData)
        .expect(201);

      // Try to add same role again
      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .send(roleData)
        .expect(409);

      expect(response.body.message).toBe("Role sudah ada untuk scope ini");

      // Cleanup
      const { data: userRoles } = await supabaseAdmin
        .from("user_roles")
        .select("id")
        .eq("user_id", testUserId);

      if (userRoles) {
        createdUserRoleIds.push(...userRoles.map((ur) => ur.id));
      }
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !testUserId) {
        console.log("Skipping: No WARGA_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .post(`/admin/users/${testUserId}/roles`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .send({ role: "warga", rw: 1, rt: 1 })
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("DELETE /admin/users/:id/roles/:userRoleId - Remove Role", () => {
    let testUserId;
    let testUserRoleId;

    beforeEach(async () => {
      // Create test user
      const { data: user } = await supabaseAdmin
        .from("users")
        .insert({
          name: "TEST_Delete Role User",
          email: `test-delrole-${Date.now()}@testing.local`,
          phone: "081234567896",
          is_active: true,
        })
        .select("id")
        .single();

      if (user) {
        testUserId = user.id;
        createdUserIds.push(user.id);

        // Add a role to delete
        const wargaRoleId = testRoleMap.get("warga");
        if (wargaRoleId) {
          const { data: userRole } = await supabaseAdmin
            .from("user_roles")
            .insert({
              user_id: user.id,
              role_id: wargaRoleId,
              rw: 1,
              rt: 1,
            })
            .select("id")
            .single();

          if (userRole) {
            testUserRoleId = userRole.id;
            createdUserRoleIds.push(userRole.id);
          }
        }
      }
    });

    test("should remove role successfully", async () => {
      if (!ADMIN_TOKEN || !testUserId || !testUserRoleId) {
        console.log("Skipping: No ADMIN_TOKEN, testUserId, or testUserRoleId");
        return;
      }

      const response = await request(app)
        .delete(`/admin/users/${testUserId}/roles/${testUserRoleId}`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(200);

      expect(response.body.message).toBe("Role removed");

      // Verify deleted from database
      const { data: userRole } = await supabaseAdmin
        .from("user_roles")
        .select("id")
        .eq("id", testUserRoleId)
        .single();

      expect(userRole).toBeNull();

      // Remove from cleanup list since already deleted
      createdUserRoleIds = createdUserRoleIds.filter(
        (id) => id !== testUserRoleId
      );
    });

    test("should return 400 for invalid user id", async () => {
      if (!ADMIN_TOKEN || !testUserRoleId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserRoleId");
        return;
      }

      const response = await request(app)
        .delete(`/admin/users/invalid/roles/${testUserRoleId}`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 400 for invalid userRoleId", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .delete(`/admin/users/${testUserId}/roles/invalid`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(400);

      expect(response.body.message).toBe("Invalid id");
    });

    test("should return 404 when user role not found", async () => {
      if (!ADMIN_TOKEN || !testUserId) {
        console.log("Skipping: No ADMIN_TOKEN or testUserId");
        return;
      }

      const response = await request(app)
        .delete(`/admin/users/${testUserId}/roles/999999`)
        .set("Authorization", `Bearer ${ADMIN_TOKEN}`)
        .expect(404);

      expect(response.body.message).toBe("User role not found");
    });

    test("should return 403 for non-admin user", async () => {
      if (!WARGA_TOKEN || !testUserId || !testUserRoleId) {
        console.log("Skipping: No WARGA_TOKEN, testUserId, or testUserRoleId");
        return;
      }

      const response = await request(app)
        .delete(`/admin/users/${testUserId}/roles/${testUserRoleId}`)
        .set("Authorization", `Bearer ${WARGA_TOKEN}`)
        .expect(403);

      expect(response.body.message).toBe("Admin only");
    });
  });

  describe("Authorization Tests", () => {
    test("should return 401 for all endpoints without authentication", async () => {
      await request(app).get("/admin/users").expect(401);
      await request(app).get("/admin/users/1").expect(401);
      await request(app).patch("/admin/users/1/approve").expect(401);
      await request(app).patch("/admin/users/1/deactivate").expect(401);
      await request(app)
        .patch("/admin/users/1/link-resident")
        .send({ resident_id: 1 })
        .expect(401);
      await request(app)
        .post("/admin/users/1/roles")
        .send({ role: "warga" })
        .expect(401);
      await request(app).delete("/admin/users/1/roles/1").expect(401);
    });
  });
});
