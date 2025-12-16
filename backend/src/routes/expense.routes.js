const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");

const router = express.Router();

const EXPENSE_TYPES = ["operational", "event", "broadcast", "other"];

function applyScope(q, scope) {
  if (scope.mode === "all") return q;
  if (scope.mode === "rw") return q.eq("rw", scope.rw);
  if (scope.mode === "rt") return q.eq("rw", scope.rw).eq("rt", scope.rt);
  return q;
}

// cek apakah event bisa diakses oleh scope user
async function assertEventAccessible(eventId, scope) {
  const idNum = Number(eventId);
  if (!Number.isFinite(idNum)) return { ok: false, message: "event_id tidak valid" };

  const { data: ev, error } = await supabaseAdmin
    .from("events")
    .select("id,rw,rt")
    .eq("id", idNum)
    .single();

  if (error || !ev) return { ok: false, message: "Event tidak ditemukan" };

  if (scope.mode === "all") return { ok: true };

  if (scope.mode === "rw") {
    return ev.rw === scope.rw
      ? { ok: true, row: ev }
      : { ok: false, message: "Event di luar RW scope" };
  }

  if (scope.mode === "rt") {
    const allowed = ev.rw === scope.rw && (ev.rt === null || ev.rt === scope.rt);
    return allowed
      ? { ok: true, row: ev }
      : { ok: false, message: "Event di luar RT/RW scope" };
  }

  return { ok: false, message: "No scope access" };
}

// cek apakah broadcast bisa diakses oleh scope user
async function assertBroadcastAccessible(broadcastId, scope) {
  const idNum = Number(broadcastId);
  if (!Number.isFinite(idNum)) return { ok: false, message: "broadcast_id tidak valid" };

  const { data: bc, error } = await supabaseAdmin
    .from("broadcasts")
    .select("id,rw,rt")
    .eq("id", idNum)
    .single();

  if (error || !bc) return { ok: false, message: "Broadcast tidak ditemukan" };

  if (scope.mode === "all") return { ok: true };

  if (scope.mode === "rw") {
    return bc.rw === scope.rw
      ? { ok: true, row: bc }
      : { ok: false, message: "Broadcast di luar RW scope" };
  }

  if (scope.mode === "rt") {
    const allowed = bc.rw === scope.rw && (bc.rt === null || bc.rt === scope.rt);
    return allowed
      ? { ok: true, row: bc }
      : { ok: false, message: "Broadcast di luar RT/RW scope" };
  }

  return { ok: false, message: "No scope access" };
}

// GET /expenses
router.get("/", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;

    let q = supabaseAdmin
      .from("expenses")
      .select("*")
      .order("date", { ascending: false });

    q = applyScope(q, scope);

    const { data, error } = await q;
    if (error) return res.status(500).json({ message: error.message });

    return res.json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

// POST /expenses
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;

    // yang boleh input pengeluaran
    const allowed = ["admin", "bendahara", "sekretaris", "ketua_rw", "ketua_rt"];
    const okRole = roleNames.some((r) => allowed.includes(r));
    if (!okRole) return res.status(403).json({ message: "Forbidden" });

    const body = req.body ?? {};
    const {
      description,
      amount,
      date,
      payment_method,
      expense_type,
      event_id,
      broadcast_id,
    } = body;

    if (!description || amount === undefined || amount === null || !date) {
      return res.status(400).json({ message: "description, amount, date wajib diisi" });
    }

    const finalType = expense_type ?? "other";
    if (!EXPENSE_TYPES.includes(finalType)) {
      return res.status(400).json({ message: "expense_type tidak valid" });
    }

    // jangan link dua-duanya
    if (event_id && broadcast_id) {
      return res.status(400).json({ message: "Pilih salah satu: event_id atau broadcast_id (jangan keduanya)" });
    }

    // rule: jika type event/broadcast, id wajib ada
    if (finalType === "event" && !event_id) {
      return res.status(400).json({ message: "expense_type=event wajib mengisi event_id" });
    }
    if (finalType === "broadcast" && !broadcast_id) {
      return res.status(400).json({ message: "expense_type=broadcast wajib mengisi broadcast_id" });
    }

    // enforce rw/rt by scope
    let rw = body.rw ?? null;
    let rt = body.rt ?? null;

    if (scope.mode === "rw") {
      rw = scope.rw;

      // ✅ RW boleh catat expense RT tertentu atau RW-level
      // kalau kamu mau paksa RW-level saja, ganti jadi: rt = null;
      rt = rt ?? null;
      if (rt !== null) {
        const rtNum = Number(rt);
        if (!Number.isInteger(rtNum) || rtNum <= 0) {
          return res.status(400).json({ message: "rt harus integer positif atau null" });
        }
        rt = rtNum;
      }
    } else if (scope.mode === "rt") {
      rw = scope.rw;
      rt = scope.rt;
    } else if (scope.mode === "all") {
      if (rw == null) return res.status(400).json({ message: "rw wajib untuk admin" });
      if (rt !== null && rt !== undefined) {
        const rtNum = Number(rt);
        if (!Number.isInteger(rtNum) || rtNum <= 0) {
          return res.status(400).json({ message: "rt harus integer positif atau null" });
        }
        rt = rtNum;
      } else {
        rt = null;
      }
    } else {
      return res.status(403).json({ message: "No scope access" });
    }

    // ✅ VALIDASI SCOPE event/broadcast
    if (event_id) {
      const check = await assertEventAccessible(event_id, scope);
      if (!check.ok) return res.status(403).json({ message: check.message });

      // opsional: kalau expense rt spesifik dan event rt spesifik tapi beda → tolak
      if (rt !== null && check.row?.rt !== null && check.row?.rt !== rt) {
        return res.status(400).json({ message: "event_id tidak sesuai dengan rt expense" });
      }
    }

    if (broadcast_id) {
      const check = await assertBroadcastAccessible(broadcast_id, scope);
      if (!check.ok) return res.status(403).json({ message: check.message });

      if (rt !== null && check.row?.rt !== null && check.row?.rt !== rt) {
        return res.status(400).json({ message: "broadcast_id tidak sesuai dengan rt expense" });
      }
    }

    const payload = {
      rw,
      rt,
      expense_type: finalType,
      event_id: event_id ? Number(event_id) : null,
      broadcast_id: broadcast_id ? Number(broadcast_id) : null,
      description,
      amount,
      date,
      payment_method: payment_method ?? null,
      recorded_by_user_id: appUser.id,
    };

    const { data, error } = await supabaseAdmin
      .from("expenses")
      .insert(payload)
      .select("*")
      .single();

    if (error) return res.status(500).json({ message: error.message });
    return res.status(201).json({ data });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

module.exports = router;
