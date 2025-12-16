const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");
const multer = require("multer");
const { randomUUID } = require("crypto");

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 3 * 1024 * 1024 }, // 3MB (ubah sesuai kebutuhan)
});


const STATUS = ["planned", "ongoing", "completed", "cancelled"];

function canManage(roleNames) {
  // yang boleh buat/update event
  const allowed = ["admin", "ketua_rw", "ketua_rt", "sekretaris"];
  return roleNames.some((r) => allowed.includes(r));
}

// untuk LIST/VIEW: RT boleh lihat event RW (rt null) + event RT dia
function applyScopeForRead(q, scope) {
  if (scope.mode === "all") return q;
  if (scope.mode === "rw") return q.eq("rw", scope.rw);
  if (scope.mode === "rt") {
    return q.eq("rw", scope.rw).or(`rt.is.null,rt.eq.${scope.rt}`);
  }
  return q;
}

// untuk UPDATE: ketua_rt hanya boleh update event RT dia (bukan event RW)
function isAllowedToUpdateEvent(eventRow, roleNames, scope) {
  if (roleNames.includes("admin")) return true;

  // Ketua RW: boleh update semua event di RW-nya (rt null maupun rt tertentu)
  if (roleNames.includes("ketua_rw")) {
    return scope.mode === "rw" && eventRow.rw === scope.rw;
  }

  // Ketua RT & Sekretaris (per RT): hanya event RT dia (bukan RW-level)
  if (roleNames.includes("ketua_rt") || roleNames.includes("sekretaris")) {
    return (
      scope.mode === "rt" &&
      eventRow.rw === scope.rw &&
      eventRow.rt === scope.rt
    );
  }

  return false;
}


// GET /events?from=YYYY-MM-DD&to=YYYY-MM-DD&status=planned
router.get("/", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;
    const { from, to, status } = req.query;

    let q = supabaseAdmin
      .from("events")
      .select("*")
      .order("start_datetime", { ascending: true });

    q = applyScopeForRead(q, scope);

    if (status) q = q.eq("status", status);
    if (from) q = q.gte("start_datetime", from);
    if (to) q = q.lte("start_datetime", to);

    const { data, error } = await q;
    if (error) return res.status(500).json({ message: error.message });

    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// GET /events/:id
router.get("/:id", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    let q = supabaseAdmin.from("events").select("*").eq("id", id);
    q = applyScopeForRead(q, scope);

    const { data, error } = await q.single();
    if (error) return res.status(404).json({ message: "Event not found / not accessible" });

    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /events
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const body = req.body ?? {};
    const { title, description, start_datetime, end_datetime, location, status, image_url } = body;

    if (!title || !description || !start_datetime) {
      return res.status(400).json({ message: "title, description, start_datetime wajib diisi" });
    }

    const finalStatus = status ?? "planned";
    if (!STATUS.includes(finalStatus)) {
      return res.status(400).json({ message: "status tidak valid" });
    }

    // enforce rw/rt berdasarkan scope
    let rw = body.rw ?? null;
    let rt = body.rt ?? null;

    if (scope.mode === "rw") {
      rw = scope.rw;
      // ketua_rw/sekretaris boleh buat event RW (rt null) atau target RT tertentu (optional)
      rt = rt ?? null;
    } else if (scope.mode === "rt") {
      rw = scope.rw;
      rt = scope.rt; // ketua_rt: event khusus RT dia
    } else if (scope.mode === "all") {
      if (rw == null) return res.status(400).json({ message: "rw wajib untuk admin" });
      rt = rt ?? null;
    } else {
      return res.status(403).json({ message: "No scope access" });
    }

    const payload = {
      rw,
      rt,
      title,
      description,
      start_datetime,
      end_datetime: end_datetime ?? null,
      location: location ?? null,
      status: finalStatus,
      image_url: image_url ?? null,
      created_by_user_id: appUser.id,
    };

    const { data, error } = await supabaseAdmin
      .from("events")
      .insert(payload)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.status(201).json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// PATCH /events/:id (update data umum)
router.patch("/:id", requireAuth, async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    // ambil event dulu untuk cek scope update
    const { data: ev, error: evErr } = await supabaseAdmin
      .from("events")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (evErr || !ev) return res.status(404).json({ message: "Event not found" });
    if (!isAllowedToUpdateEvent(ev, roleNames, scope)) {
      return res.status(403).json({ message: "Forbidden (scope)" });
    }

    const body = req.body ?? {};
    const patch = {};

    if (body.title !== undefined) patch.title = body.title;
    if (body.description !== undefined) patch.description = body.description;
    if (body.start_datetime !== undefined) patch.start_datetime = body.start_datetime;
    if (body.end_datetime !== undefined) patch.end_datetime = body.end_datetime;
    if (body.location !== undefined) patch.location = body.location;
    if (body.image_url !== undefined) patch.image_url = body.image_url;

    patch.updated_at = new Date().toISOString();

    const { data, error } = await supabaseAdmin
      .from("events")
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

// PATCH /events/:id/status
router.patch("/:id/status", requireAuth, async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { status } = req.body ?? {};
    if (!STATUS.includes(status)) return res.status(400).json({ message: "status tidak valid" });

    const { data: ev, error: evErr } = await supabaseAdmin
      .from("events")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (evErr || !ev) return res.status(404).json({ message: "Event not found" });
    if (!isAllowedToUpdateEvent(ev, roleNames, scope)) {
      return res.status(403).json({ message: "Forbidden (scope)" });
    }

    const { data, error } = await supabaseAdmin
      .from("events")
      .update({ status, updated_at: new Date().toISOString() })
      .eq("id", id)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /events/:id/image  (multipart form-data, field name: image)
router.post("/:id/image", requireAuth, upload.single("image"), async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;

    if (!canManage(roleNames)) {
      return res.status(403).json({ message: "Forbidden" });
    }

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    if (!req.file) return res.status(400).json({ message: "File 'image' wajib dikirim" });

    // ambil event untuk cek scope update
    const { data: ev, error: evErr } = await supabaseAdmin
      .from("events")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (evErr || !ev) return res.status(404).json({ message: "Event not found" });
    if (!isAllowedToUpdateEvent(ev, roleNames, scope)) {
      return res.status(403).json({ message: "Forbidden (scope)" });
    }

    // validasi mime
    const allowed = ["image/jpeg", "image/png", "image/webp"];
    if (!allowed.includes(req.file.mimetype)) {
      return res.status(400).json({ message: "Format harus jpg/png/webp" });
    }

    const ext =
      req.file.mimetype === "image/png" ? "png" :
      req.file.mimetype === "image/webp" ? "webp" : "jpg";

    const path = `rw_${ev.rw}/event_${id}/${randomUUID()}.${ext}`;

    // upload ke supabase storage
    const { error: upErr } = await supabaseAdmin
      .storage
      .from("event-images")
      .upload(path, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true,
      });

    if (upErr) return res.status(500).json({ message: upErr.message });

    // ambil public url (karena bucket public)
    const { data: pub } = supabaseAdmin.storage.from("event-images").getPublicUrl(path);
    const publicUrl = pub.publicUrl;

    // simpan url ke events.image_url
    const { data, error } = await supabaseAdmin
      .from("events")
      .update({ image_url: publicUrl, updated_at: new Date().toISOString() })
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
