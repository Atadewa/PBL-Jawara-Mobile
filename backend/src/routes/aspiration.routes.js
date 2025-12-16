const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");

const router = express.Router();

const ALLOWED_STATUS = ["pending", "in_progress", "resolved", "rejected"];

function canModerate(roleNames) {
  // yang boleh mengelola status aspirasi
  const allowed = ["admin", "ketua_rw", "ketua_rt", "sekretaris"];
  return roleNames.some((r) => allowed.includes(r));
}

async function getResidentIdsByScope(scope) {
  // Ambil residents di wilayah scope rw/rt dengan join houses
  let q = supabaseAdmin.from("residents").select("id, houses!inner(rw, rt)");

  if (scope.mode === "rw") {
    q = q.eq("houses.rw", scope.rw);
  } else if (scope.mode === "rt") {
    q = q.eq("houses.rw", scope.rw).eq("houses.rt", scope.rt);
  } else if (scope.mode === "all") {
    // admin -> tidak perlu filter
  } else {
    return [];
  }

  const { data, error } = await q;
  if (error) throw new Error(error.message);

  return (data || []).map((x) => x.id);
}

// cek apakah resident_id berada dalam scope user
async function assertResidentInScope(residentId, scope) {
  if (scope.mode === "all") return { ok: true };

  const idNum = Number(residentId);
  if (!Number.isFinite(idNum))
    return { ok: false, message: "resident_id tidak valid" };

  let q = supabaseAdmin
    .from("residents")
    .select("id, houses!inner(rw, rt)")
    .eq("id", idNum);

  if (scope.mode === "rw") {
    q = q.eq("houses.rw", scope.rw);
  } else if (scope.mode === "rt") {
    q = q.eq("houses.rw", scope.rw).eq("houses.rt", scope.rt);
  } else {
    return { ok: false, message: "No scope access" };
  }

  const { data, error } = await q.single();
  if (error || !data)
    return { ok: false, message: "Aspirasi di luar scope RW/RT" };

  return { ok: true };
}

// GET /aspirations
// - warga: hanya aspirasinya sendiri (selama dia bukan pengurus)
// - pengurus/admin: sesuai scope
router.get("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;

    // warga-only: hanya kalau dia bukan pengurus
    if (roleNames.includes("warga") && !canModerate(roleNames)) {
      if (!appUser.resident_id) {
        return res.status(403).json({
          message: "Resident belum terhubung ke user (resident_id null)",
        });
      }

      const { data, error } = await supabaseAdmin
        .from("aspirations")
        .select(
          `
          *,
          created_by_resident:residents!created_by_resident_id (
            id,
            full_name,
            houses!residents_house_id_fkey (
              rw,
              rt,
              address
            )
          )
        `
        )
        .eq("created_by_resident_id", appUser.resident_id)
        .order("created_at", { ascending: false });

      if (error) return res.status(500).json({ message: error.message });
      return res.json({ data });
    }

    // admin/pengurus -> sesuai scope (with creator info)
    const selectQuery = `
      *,
      created_by_resident:residents!created_by_resident_id (
        id,
        full_name,
        houses!residents_house_id_fkey (
          rw,
          rt,
          address
        )
      )
    `;

    if (scope.mode === "all") {
      const { data, error } = await supabaseAdmin
        .from("aspirations")
        .select(selectQuery)
        .order("created_at", { ascending: false });

      if (error) return res.status(500).json({ message: error.message });
      return res.json({ data });
    }

    // rw/rt -> filter lewat daftar resident id
    const residentIds = await getResidentIdsByScope(scope);
    if (!residentIds.length) return res.json({ data: [] });

    const { data, error } = await supabaseAdmin
      .from("aspirations")
      .select(selectQuery)
      .in("created_by_resident_id", residentIds)
      .order("created_at", { ascending: false });

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /aspirations
// - ONLY warga-only (warga AND NOT moderator) can create
// - Moderators CANNOT create aspirations
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames } = req.userContext;

    // ✅ Only warga-only (not moderator) can create
    if (canModerate(roleNames)) {
      return res
        .status(403)
        .json({ message: "Moderator tidak dapat membuat aspirasi" });
    }

    if (!roleNames.includes("warga")) {
      return res
        .status(403)
        .json({ message: "Hanya warga yang dapat membuat aspirasi" });
    }

    if (!appUser.resident_id) {
      return res.status(403).json({
        message: "Resident belum terhubung ke user (resident_id null)",
      });
    }

    const body = req.body ?? {};
    const { title, description, category } = body;

    if (!title || !description) {
      return res
        .status(400)
        .json({ message: "title dan description wajib diisi" });
    }

    // warga-only: always use their own resident_id
    const createdByResidentId = appUser.resident_id;

    const payload = {
      title,
      description,
      category: category ?? null,
      status: "pending",
      created_by_resident_id: createdByResidentId,
      created_by_user_id: appUser.id,
    };

    const { data, error } = await supabaseAdmin
      .from("aspirations")
      .insert(payload)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.status(201).json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// PATCH /aspirations/:id
// - warga-only can update title/description/category of their own aspiration
router.patch("/:id", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames } = req.userContext;

    // Only warga-only can update content
    if (canModerate(roleNames)) {
      return res
        .status(403)
        .json({ message: "Moderator tidak dapat mengubah konten aspirasi" });
    }

    if (!roleNames.includes("warga")) {
      return res
        .status(403)
        .json({ message: "Hanya warga yang dapat mengubah aspirasi" });
    }

    const id = Number(req.params.id);
    if (!Number.isFinite(id))
      return res.status(400).json({ message: "Invalid id" });

    // Check ownership
    const { data: asp, error: aspErr } = await supabaseAdmin
      .from("aspirations")
      .select("id, created_by_user_id, created_by_resident_id")
      .eq("id", id)
      .single();

    if (aspErr || !asp)
      return res.status(404).json({ message: "Aspirasi tidak ditemukan" });

    // Verify ownership (prefer user_id check)
    const isOwner =
      asp.created_by_user_id === appUser.id ||
      (appUser.resident_id &&
        asp.created_by_resident_id === appUser.resident_id);

    if (!isOwner) {
      return res
        .status(403)
        .json({ message: "Anda tidak dapat mengubah aspirasi orang lain" });
    }

    const { title, description, category } = req.body ?? {};
    const patch = { updated_at: new Date().toISOString() };

    if (title !== undefined) patch.title = title;
    if (description !== undefined) patch.description = description;
    if (category !== undefined) patch.category = category;

    const { data, error } = await supabaseAdmin
      .from("aspirations")
      .update(patch)
      .eq("id", id)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// DELETE /aspirations/:id
// - warga-only can delete their own aspiration
router.delete("/:id", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames } = req.userContext;

    // Only warga-only can delete
    if (canModerate(roleNames)) {
      return res
        .status(403)
        .json({ message: "Moderator tidak dapat menghapus aspirasi" });
    }

    if (!roleNames.includes("warga")) {
      return res
        .status(403)
        .json({ message: "Hanya warga yang dapat menghapus aspirasi" });
    }

    const id = Number(req.params.id);
    if (!Number.isFinite(id))
      return res.status(400).json({ message: "Invalid id" });

    // Check ownership
    const { data: asp, error: aspErr } = await supabaseAdmin
      .from("aspirations")
      .select("id, created_by_user_id, created_by_resident_id")
      .eq("id", id)
      .single();

    if (aspErr || !asp)
      return res.status(404).json({ message: "Aspirasi tidak ditemukan" });

    // Verify ownership
    const isOwner =
      asp.created_by_user_id === appUser.id ||
      (appUser.resident_id &&
        asp.created_by_resident_id === appUser.resident_id);

    if (!isOwner) {
      return res
        .status(403)
        .json({ message: "Anda tidak dapat menghapus aspirasi orang lain" });
    }

    const { error } = await supabaseAdmin
      .from("aspirations")
      .delete()
      .eq("id", id);

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ message: "Aspirasi berhasil dihapus" });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// GET /aspirations/:id
// - warga-only: can read only their own
// - moderator: can read if inside scope
router.get("/:id", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;
    const id = Number(req.params.id);
    if (!Number.isFinite(id))
      return res.status(400).json({ message: "Invalid id" });

    // Fetch with creator info
    const { data: asp, error } = await supabaseAdmin
      .from("aspirations")
      .select(
        `
        *,
        created_by_resident:residents!created_by_resident_id (
          id,
          full_name,
          houses!residents_house_id_fkey (
            rw,
            rt,
            address
          )
        )
      `
      )
      .eq("id", id)
      .single();

    if (error || !asp)
      return res.status(404).json({ message: "Aspirasi tidak ditemukan" });

    // warga-only: only their own
    if (roleNames.includes("warga") && !canModerate(roleNames)) {
      const isOwner =
        asp.created_by_user_id === appUser.id ||
        (appUser.resident_id &&
          asp.created_by_resident_id === appUser.resident_id);

      if (!isOwner) {
        return res
          .status(403)
          .json({ message: "Anda tidak dapat melihat aspirasi orang lain" });
      }
      return res.json({ data: asp });
    }

    // moderator: check scope
    const check = await assertResidentInScope(
      asp.created_by_resident_id,
      scope
    );
    if (!check.ok) return res.status(403).json({ message: check.message });

    return res.json({ data: asp });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// PATCH /aspirations/:id/status
// - pengurus/admin mengubah status + decision_note (optional)
// ✅ sekarang ada cek scope RW/RT dulu sebelum update
router.patch("/:id/status", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;

    if (!canModerate(roleNames)) {
      return res.status(403).json({ message: "Forbidden" });
    }

    const id = Number(req.params.id);
    if (!Number.isFinite(id))
      return res.status(400).json({ message: "Invalid id" });

    const { status, decision_note } = req.body ?? {};
    if (!ALLOWED_STATUS.includes(status)) {
      return res.status(400).json({ message: "status tidak valid" });
    }

    // ✅ ambil aspiration dulu untuk cek scope berdasarkan created_by_resident_id
    const { data: asp, error: aspErr } = await supabaseAdmin
      .from("aspirations")
      .select("id, created_by_resident_id")
      .eq("id", id)
      .single();

    if (aspErr || !asp)
      return res.status(404).json({ message: "Aspirasi tidak ditemukan" });

    const check = await assertResidentInScope(
      asp.created_by_resident_id,
      scope
    );
    if (!check.ok) return res.status(403).json({ message: check.message });

    const patch = {
      status,
      updated_at: new Date().toISOString(),
      decision_note: decision_note ?? null,
    };

    // kalau resolved/rejected, set decided fields
    if (status === "resolved" || status === "rejected") {
      patch.decided_by_user_id = appUser.id;
      patch.decided_at = new Date().toISOString();
    } else {
      // opsional: kalau mau saat in_progress juga tercatat siapa yang memproses, uncomment:
      // patch.decided_by_user_id = appUser.id;
      // patch.decided_at = new Date().toISOString();
    }

    const { data, error } = await supabaseAdmin
      .from("aspirations")
      .update(patch)
      .eq("id", id)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

module.exports = router;
