const express = require("express");
const { requireAuth } = require("../middlewares/requireAuth");
const { supabaseAdmin } = require("../lib/supabaseAdmin");

const router = express.Router();

function applyScope(q, scope) {
  if (scope.mode === "all") return q;
  if (scope.mode === "rw") return q.eq("rw", scope.rw);
  if (scope.mode === "rt") return q.eq("rw", scope.rw).eq("rt", scope.rt);
  return q;
}

// default range: last 30 days
function defaultRange() {
  const to = new Date();
  const from = new Date();
  from.setDate(to.getDate() - 30);

  const fmt = (d) => d.toISOString().slice(0, 10);
  return { from: fmt(from), to: fmt(to) };
}

// helper sum numeric(15,2) -> JS number
function toNum(v) {
  if (v === null || v === undefined) return 0;
  const n = Number(v);
  return Number.isFinite(n) ? n : 0;
}

// GET /summary/cashflow?from=YYYY-MM-DD&to=YYYY-MM-DD
router.get("/cashflow", requireAuth, async (req, res) => {
  try {
    const { scope } = req.userContext;

    const { from: defFrom, to: defTo } = defaultRange();
    const from = req.query.from || defFrom;
    const to = req.query.to || defTo;

    // INCOMES
    let qIncome = supabaseAdmin
      .from("incomes")
      .select("amount,date")
      .gte("date", from)
      .lte("date", to);

    qIncome = applyScope(qIncome, scope);

    const { data: incomes, error: incomeErr } = await qIncome;
    if (incomeErr) return res.status(500).json({ message: incomeErr.message });

    // EXPENSES
    let qExpense = supabaseAdmin
      .from("expenses")
      .select("amount,date")
      .gte("date", from)
      .lte("date", to);

    qExpense = applyScope(qExpense, scope);

    const { data: expenses, error: expErr } = await qExpense;
    if (expErr) return res.status(500).json({ message: expErr.message });

    // totals
    const totalIncome = (incomes || []).reduce((acc, x) => acc + toNum(x.amount), 0);
    const totalExpense = (expenses || []).reduce((acc, x) => acc + toNum(x.amount), 0);
    const balance = totalIncome - totalExpense;

    // daily breakdown (optional but useful for chart)
    const map = new Map(); // date -> {income, expense}
    for (const row of incomes || []) {
      const d = row.date;
      const cur = map.get(d) || { date: d, income: 0, expense: 0 };
      cur.income += toNum(row.amount);
      map.set(d, cur);
    }
    for (const row of expenses || []) {
      const d = row.date;
      const cur = map.get(d) || { date: d, income: 0, expense: 0 };
      cur.expense += toNum(row.amount);
      map.set(d, cur);
    }

    const daily = Array.from(map.values())
      .sort((a, b) => a.date.localeCompare(b.date))
      .map((x) => ({ ...x, balance: x.income - x.expense }));

    return res.json({
      range: { from, to },
      scope,
      totals: {
        income: totalIncome,
        expense: totalExpense,
        balance,
      },
      daily,
    });
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
});

module.exports = router;
