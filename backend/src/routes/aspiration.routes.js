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
  let q = supabaseAdmin
    .from("residents")
    .select("id, houses!inner(rw, rt)");

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
  if (!Number.isFinite(idNum)) return { ok: false, message: "resident_id tidak valid" };

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
  if (error || !data) return { ok: false, message: "Aspirasi di luar scope RW/RT" };

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
        .select("*")
        .eq("created_by_resident_id", appUser.resident_id)
        .order("created_at", { ascending: false });

      if (error) return res.status(500).json({ message: error.message });
      return res.json({ data });
    }

    // admin/pengurus -> sesuai scope
    if (scope.mode === "all") {
      const { data, error } = await supabaseAdmin
        .from("aspirations")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) return res.status(500).json({ message: error.message });
      return res.json({ data });
    }

    // rw/rt -> filter lewat daftar resident id
    const residentIds = await getResidentIdsByScope(scope);
    if (!residentIds.length) return res.json({ data: [] });

    const { data, error } = await supabaseAdmin
      .from("aspirations")
      .select("*")
      .in("created_by_resident_id", residentIds)
      .order("created_at", { ascending: false });

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /aspirations
// - warga: otomatis pakai resident_id milik dia
// - admin/pengurus: boleh create (kalau resident_id null, wajib kirim created_by_resident_id)
//   + validasi scope agar pengurus RT/RW tidak bisa buat untuk wilayah lain
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;

    const body = req.body ?? {};
    const { title, description, category } = body;

    if (!title || !description) {
      return res.status(400).json({ message: "title dan description wajib diisi" });
    }

    // tentukan created_by_resident_id
    let createdByResidentId = appUser.resident_id;

    // kalau user tidak terhubung resident (mis. admin non-warga), boleh set manual
    if (!createdByResidentId) {
      if (!body.created_by_resident_id) {
        return res.status(400).json({
          message:
            "User belum punya resident_id. Kirim created_by_resident_id di body (untuk admin/pengurus).",
        });
      }
      createdByResidentId = body.created_by_resident_id;

      // ✅ validasi scope (kecuali admin all)
      const check = await assertResidentInScope(createdByResidentId, scope);
      if (!check.ok) return res.status(403).json({ message: check.message });
    }

    // warga sebaiknya tidak boleh "impersonate"
    if (roleNames.includes("warga") && body.created_by_resident_id) {
      return res.status(403).json({ message: "Warga tidak boleh set created_by_resident_id manual" });
    }

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
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

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

    if (aspErr || !asp) return res.status(404).json({ message: "Aspirasi tidak ditemukan" });

    const check = await assertResidentInScope(asp.created_by_resident_id, scope);
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
