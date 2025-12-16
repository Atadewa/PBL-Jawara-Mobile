const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");
const multer = require("multer");
const { randomUUID } = require("crypto");

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 3 * 1024 * 1024 }, // 3MB
});

// status sederhana (karena di DB kamu masih text)
const STATUS = ["draft", "published", "archived"];

function canManage(roleNames) {
  // pengumuman dikelola admin / pengurus
  const allowed = ["admin", "ketua_rw", "ketua_rt", "sekretaris"];
  return roleNames.some((r) => allowed.includes(r));
}

// READ:
// - RW: semua di RW-nya
// - RT: RW-level (rt null) + RT dia
function applyScopeForRead(q, scope) {
  if (scope.mode === "all") return q;
  if (scope.mode === "rw") return q.eq("rw", scope.rw);
  if (scope.mode === "rt") return q.eq("rw", scope.rw).or(`rt.is.null,rt.eq.${scope.rt}`);
  return q;
}

// UPDATE:
// - admin: bebas
// - ketua_rw: semua broadcast dalam RW (rt null maupun rt tertentu)
// - ketua_rt/sekretaris (per RT): hanya broadcast RT dia (rt = scope.rt), tidak boleh RW-level
function isAllowedToUpdate(bcRow, roleNames, scope) {
  if (roleNames.includes("admin")) return true;

  if (roleNames.includes("ketua_rw")) {
    return scope.mode === "rw" && bcRow.rw === scope.rw;
  }

  if (roleNames.includes("ketua_rt") || roleNames.includes("sekretaris")) {
    return (
      scope.mode === "rt" &&
      bcRow.rw === scope.rw &&
      bcRow.rt === scope.rt
    );
  }

  return false;
}

// GET /broadcasts?status=draft
router.get("/", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;
    const { status } = req.query;

    let q = supabaseAdmin
      .from("broadcasts")
      .select("*")
      .order("created_at", { ascending: false });

    q = applyScopeForRead(q, scope);
    if (status) q = q.eq("status", status);

    const { data, error } = await q;
    if (error) return res.status(500).json({ message: error.message });

    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// GET /broadcasts/:id
router.get("/:id", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;
    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    let q = supabaseAdmin.from("broadcasts").select("*").eq("id", id);
    q = applyScopeForRead(q, scope);

    const { data, error } = await q.single();
    if (error) return res.status(404).json({ message: "Broadcast not found / not accessible" });

    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /broadcasts
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const body = req.body ?? {};
    const { title, content, image_url, document_url, status } = body;

    if (!title || !content) {
      return res.status(400).json({ message: "title dan content wajib diisi" });
    }

    const finalStatus = status ?? "draft";
    if (!STATUS.includes(finalStatus)) return res.status(400).json({ message: "status tidak valid" });

    // enforce rw/rt berdasarkan scope
    let rw = body.rw ?? null;
    let rt = body.rt ?? null;

    if (scope.mode === "rw") {
      rw = scope.rw;
      // ketua_rw boleh buat RW-level (rt null) atau target RT tertentu
      rt = rt ?? null;
    } else if (scope.mode === "rt") {
      rw = scope.rw;
      rt = scope.rt; // ketua_rt/sekretaris: selalu RT dia
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
      content,
      image_url: image_url ?? null,
      document_url: document_url ?? null,
      status: finalStatus,
      created_by_user_id: appUser.id,
      published_at: finalStatus === "published" ? new Date().toISOString() : null,
    };

    const { data, error } = await supabaseAdmin
      .from("broadcasts")
      .insert(payload)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.status(201).json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// PATCH /broadcasts/:id (edit)
router.patch("/:id", requireAuth, async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { data: bc, error: bcErr } = await supabaseAdmin
      .from("broadcasts")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (bcErr || !bc) return res.status(404).json({ message: "Broadcast not found" });
    if (!isAllowedToUpdate(bc, roleNames, scope)) return res.status(403).json({ message: "Forbidden (scope)" });

    const body = req.body ?? {};
    const patch = {};

    if (body.title !== undefined) patch.title = body.title;
    if (body.content !== undefined) patch.content = body.content;
    if (body.image_url !== undefined) patch.image_url = body.image_url;
    if (body.document_url !== undefined) patch.document_url = body.document_url;

    patch.updated_at = new Date().toISOString();

    const { data, error } = await supabaseAdmin
      .from("broadcasts")
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

// PATCH /broadcasts/:id/publish
router.patch("/:id/publish", requireAuth, async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    const { data: bc, error: bcErr } = await supabaseAdmin
      .from("broadcasts")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (bcErr || !bc) return res.status(404).json({ message: "Broadcast not found" });
    if (!isAllowedToUpdate(bc, roleNames, scope)) return res.status(403).json({ message: "Forbidden (scope)" });

    const { data, error } = await supabaseAdmin
      .from("broadcasts")
      .update({
        status: "published",
        published_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /broadcasts/:id/image  (multipart form-data, field name: image)
router.post("/:id/image", requireAuth, upload.single("image"), async (req, res) => {
  try {
    const { roleNames, scope } = req.userContext;
    if (!canManage(roleNames)) return res.status(403).json({ message: "Forbidden" });

    const id = Number(req.params.id);
    if (!Number.isFinite(id)) return res.status(400).json({ message: "Invalid id" });

    if (!req.file) return res.status(400).json({ message: "File 'image' wajib dikirim" });

    const { data: bc, error: bcErr } = await supabaseAdmin
      .from("broadcasts")
      .select("id, rw, rt")
      .eq("id", id)
      .single();

    if (bcErr || !bc) return res.status(404).json({ message: "Broadcast not found" });
    if (!isAllowedToUpdate(bc, roleNames, scope)) return res.status(403).json({ message: "Forbidden (scope)" });

    const allowed = ["image/jpeg", "image/png", "image/webp"];
    if (!allowed.includes(req.file.mimetype)) {
      return res.status(400).json({ message: "Format harus jpg/png/webp" });
    }

    const ext =
      req.file.mimetype === "image/png" ? "png" :
      req.file.mimetype === "image/webp" ? "webp" : "jpg";

    const path = `rw_${bc.rw}/broadcast_${id}/${randomUUID()}.${ext}`;

    const { error: upErr } = await supabaseAdmin
      .storage
      .from("broadcast-images")
      .upload(path, req.file.buffer, { contentType: req.file.mimetype, upsert: true });

    if (upErr) return res.status(500).json({ message: upErr.message });

    const { data: pub } = supabaseAdmin.storage.from("broadcast-images").getPublicUrl(path);
    const publicUrl = pub.publicUrl;

    const { data, error } = await supabaseAdmin
      .from("broadcasts")
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
