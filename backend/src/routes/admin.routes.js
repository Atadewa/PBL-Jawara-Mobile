const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");

const router = express.Router();

function requireAdmin(req, res, next) {
  const roleNames = req.userContext?.roleNames ?? [];
  if (!roleNames.includes("admin")) {
    return res.status(403).json({ message: "Admin only" });
  }
  next();
}

function parseIntOrNull(v) {
  if (v === null || v === undefined || v === "") return null;
  const n = Number(v);
  return Number.isInteger(n) ? n : null;
}

async function fetchRolesMap() {
  const { data, error } = await supabaseAdmin.from("roles").select("id,name");
  if (error) throw new Error(error.message);

  const map = new Map();
  (data || []).forEach((r) => map.set(r.name, r.id));
  return map;
}

async function attachRolesToUsers(users) {
  const userIds = (users || []).map((u) => u.id);
  if (!userIds.length) return users;

  // 1) coba query join roles(name)
  let { data: ur, error } = await supabaseAdmin
    .from("user_roles")
    .select("id,user_id,rw,rt,role_id,roles(name)")
    .in("user_id", userIds);

  // 2) fallback kalau join gagal
  if (error) {
    const { data: ur2, error: urErr2 } = await supabaseAdmin
      .from("user_roles")
      .select("id,user_id,rw,rt,role_id")
      .in("user_id", userIds);

    if (urErr2) throw new Error(urErr2.message);

    const roleIds = [...new Set((ur2 || []).map((x) => x.role_id))];
    const { data: roles, error: rErr } = await supabaseAdmin
      .from("roles")
      .select("id,name")
      .in("id", roleIds);

    if (rErr) throw new Error(rErr.message);

    const roleMap = new Map((roles || []).map((r) => [r.id, r.name]));
    ur = (ur2 || []).map((x) => ({
      ...x,
      roles: { name: roleMap.get(x.role_id) },
    }));
  }

  const byUser = new Map();
  (ur || []).forEach((row) => {
    const list = byUser.get(row.user_id) ?? [];
    list.push({
      id: row.id,
      name: row.roles?.name ?? null,
      rw: row.rw,
      rt: row.rt,
    });
    byUser.set(row.user_id, list);
  });

  return (users || []).map((u) => ({
    ...u,
    roles: byUser.get(u.id) ?? [],
  }));
}

function validateRoleScope(roleName, rw, rt) {
  const perRT = ["ketua_rt", "sekretaris", "bendahara", "warga"];
  if (perRT.includes(roleName)) {
    if (!Number.isInteger(rw) || rw <= 0) return "rw wajib integer positif untuk role RT";
    if (!Number.isInteger(rt) || rt <= 0) return "rt wajib integer positif untuk role RT";
    return null;
  }

  if (roleName === "ketua_rw") {
    if (!Number.isInteger(rw) || rw <= 0) return "rw wajib integer positif untuk ketua_rw";
    if (rt !== null) return "rt harus null untuk ketua_rw";
    return null;
  }

  if (roleName === "admin") {
    // admin biasanya global
    return null;
  }

  return "role tidak dikenali";
}

/**
 * GET /admin/users?status=pending|active&search=...&page=1&limit=20
 */
router.get("/users", requireAuth, requireAdmin, async (req, res) => {
  try {
    const status = (req.query.status || "").toLowerCase(); // pending | active
    const search = (req.query.search || "").trim();
    const page = Math.max(1, Number(req.query.page || 1));
    const limit = Math.min(100, Math.max(1, Number(req.query.limit || 20)));
    const from = (page - 1) * limit;
    const to = from + limit - 1;

    let q = supabaseAdmin
      .from("users")
      .select("id,name,email,phone,is_active,resident_id,last_login_at,created_at,updated_at", { count: "exact" })
      .order("created_at", { ascending: false })
      .range(from, to);

    if (status === "pending") q = q.eq("is_active", false);
    if (status === "active") q = q.eq("is_active", true);

    if (search) {
      // cari di name/email/phone
      const s = `%${search}%`;
      q = q.or(`name.ilike.${s},email.ilike.${s},phone.ilike.${s}`);
    }

    const { data, error, count } = await q;
    if (error) return res.status(500).json({ message: error.message });

    const withRoles = await attachRolesToUsers(data || []);
    return res.json({
      page,
      limit,
      total: count ?? (withRoles?.length ?? 0),
      data: withRoles,
    });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * GET /admin/users/:id
 */
router.get("/users/:id", requireAuth, requireAdmin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { data, error } = await supabaseAdmin
      .from("users")
      .select("id,name,email,phone,is_active,resident_id,last_login_at,created_at,updated_at")
      .eq("id", id)
      .single();

    if (error || !data) return res.status(404).json({ message: "User not found" });

    const [withRoles] = await attachRolesToUsers([data]);
    return res.json({ data: withRoles });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * PATCH /admin/users/:id/approve
 */
router.patch("/users/:id/approve", requireAuth, requireAdmin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { data, error } = await supabaseAdmin
      .from("users")
      .update({ is_active: true, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select("id,name,email,phone,is_active,resident_id,created_at,updated_at")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * PATCH /admin/users/:id/deactivate
 */
router.patch("/users/:id/deactivate", requireAuth, requireAdmin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { data, error } = await supabaseAdmin
      .from("users")
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select("id,name,email,phone,is_active,resident_id,created_at,updated_at")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * PATCH /admin/users/:id/link-resident
 * body: { resident_id: 123 }
 */
router.patch("/users/:id/link-resident", requireAuth, requireAdmin, async (req, res) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const residentId = Number(req.body?.resident_id);
    if (!Number.isFinite(residentId)) return res.status(400).json({ message: "resident_id wajib angka" });

    // pastikan resident ada
    const { data: r, error: rErr } = await supabaseAdmin
      .from("residents")
      .select("id")
      .eq("id", residentId)
      .single();

    if (rErr || !r) return res.status(404).json({ message: "Resident not found" });

    const { data, error } = await supabaseAdmin
      .from("users")
      .update({ resident_id: residentId, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select("id,name,email,phone,is_active,resident_id,created_at,updated_at")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * POST /admin/users/:id/roles
 * body: { role: "sekretaris", rw: 5, rt: 2 }
 */
router.post("/users/:id/roles", requireAuth, requireAdmin, async (req, res) => {
  try {
    const userId = Number(req.params.id);
    if (!Number.isFinite(userId)) return res.status(400).json({ message: "Invalid user id" });

    const roleName = (req.body?.role || "").trim();
    const rw = parseIntOrNull(req.body?.rw);
    const rt = parseIntOrNull(req.body?.rt);

    if (!roleName) return res.status(400).json({ message: "role wajib diisi" });

    const rolesMap = await fetchRolesMap();
    const roleId = rolesMap.get(roleName);
    if (!roleId) return res.status(400).json({ message: "role tidak ditemukan di tabel roles" });

    const scopeErr = validateRoleScope(roleName, rw, rt);
    if (scopeErr) return res.status(400).json({ message: scopeErr });

    // cek duplicate
    let dq = supabaseAdmin
      .from("user_roles")
      .select("id")
      .eq("user_id", userId)
      .eq("role_id", roleId)
      .eq("rw", rw ?? null);

    if (rt === null) dq = dq.is("rt", null);
    else dq = dq.eq("rt", rt);

    const { data: exists, error: exErr } = await dq.limit(1);
    if (exErr) return res.status(500).json({ message: exErr.message });
    if (exists && exists.length) return res.status(409).json({ message: "Role sudah ada untuk scope ini" });

    const payload = {
      user_id: userId,
      role_id: roleId,
      rw: rw ?? null,
      rt: rt ?? null,
    };

    const { data, error } = await supabaseAdmin
      .from("user_roles")
      .insert(payload)
      .select("id,user_id,rw,rt,role_id")
      .single();

    if (error) return res.status(500).json({ message: error.message });

    // return user detail + roles biar enak
    const { data: u, error: uErr } = await supabaseAdmin
      .from("users")
      .select("id,name,email,phone,is_active,resident_id,created_at,updated_at")
      .eq("id", userId)
      .single();

    if (uErr || !u) return res.json({ data, note: "role inserted, user not found on refetch" });

    const [withRoles] = await attachRolesToUsers([u]);
    return res.status(201).json({ data: withRoles });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

/**
 * DELETE /admin/users/:id/roles/:userRoleId
 */
router.delete("/users/:id/roles/:userRoleId", requireAuth, requireAdmin, async (req, res) => {
  try {
    const userId = Number(req.params.id);
    const userRoleId = Number(req.params.userRoleId);
    if (!Number.isFinite(userId) || !Number.isFinite(userRoleId)) {
      return res.status(400).json({ message: "Invalid id" });
    }

    // pastikan milik user itu
    const { data: ur, error: urErr } = await supabaseAdmin
      .from("user_roles")
      .select("id,user_id")
      .eq("id", userRoleId)
      .single();

    if (urErr || !ur) return res.status(404).json({ message: "User role not found" });
    if (ur.user_id !== userId) return res.status(400).json({ message: "Role tidak milik user ini" });

    const { error } = await supabaseAdmin.from("user_roles").delete().eq("id", userRoleId);
    if (error) return res.status(500).json({ message: error.message });

    return res.json({ message: "Role removed" });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

module.exports = router;
