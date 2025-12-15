const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");

const router = express.Router();

// helper: apply scope filter ke query
function applyScope(q, scope) {
  if (scope.mode === "all") return q;
  if (scope.mode === "rw") return q.eq("rw", scope.rw);
  if (scope.mode === "rt") return q.eq("rw", scope.rw).eq("rt", scope.rt);
  return q; // fallback
}

// GET /incomes
router.get("/", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;

    let q = supabaseAdmin
      .from("incomes")
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

// POST /incomes
router.post("/", requireAuth, async (req, res) => {
  try {
    const { appUser, roleNames, scope } = req.userContext;

    // role yang boleh input pemasukan
    const allowed = ["admin", "bendahara", "sekretaris", "ketua_rw", "ketua_rt"];
    const ok = roleNames.some((r) => allowed.includes(r));
    if (!ok) return res.status(403).json({ message: "Forbidden" });

    const body = req.body ?? {};
    const { source_name, description, amount, date, payment_method } = body;

    if (!source_name || !amount || !date) {
      return res.status(400).json({ message: "source_name, amount, date wajib diisi" });
    }

    // enforce rw/rt by scope (non-admin tidak boleh inject rw/rt)
    let rw = body.rw ?? null;
    let rt = body.rt ?? null;

    if (scope.mode === "rw") {
      rw = scope.rw;
      rt = null; // level RW
    } else if (scope.mode === "rt") {
      rw = scope.rw;
      rt = scope.rt;
    } else if (scope.mode === "all") {
      // admin boleh set rw/rt dari body, tapi rw wajib
      if (rw == null) return res.status(400).json({ message: "rw wajib untuk admin" });
    } else {
      return res.status(403).json({ message: "No scope access" });
    }

    const payload = {
      rw,
      rt,
      source_name,
      description: description ?? null,
      amount,
      date,
      payment_method: payment_method ?? null,
      recorded_by_user_id: appUser.id,
    };

    const { data, error } = await supabaseAdmin
      .from("incomes")
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
