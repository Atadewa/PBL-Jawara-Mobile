require("dotenv").config();
const express = require("express");
const cors = require("cors");

const { supabase } = require("./lib/supabase");

const app = express();

// middleware dasar
app.use(cors());
app.use(express.json());

// health check
app.get("/health", (req, res) => {
  res.json({ ok: true, message: "Jawara API is running" });
});

app.get("/health2", (req, res) => {
  res.json({ ok: true, message: "Jawara API is running 2" });
});

// test supabase (opsional) - pastikan tabel "roles" ada di Supabase kamu
app.get("/test-roles", async (req, res) => {
  const { data, error } = await supabase.from("roles").select("*").limit(5);

  if (error) return res.status(500).json({ error: error.message });
  return res.json({ data });
});

// routes
const authRoutes = require("./routes/auth.routes");
const incomeRoutes = require("./routes/income.routes");
const expenseRoutes = require("./routes/expense.routes");
const summaryRoutes = require("./routes/summary.routes");
const aspirationRoutes = require("./routes/aspiration.routes");
const eventRoutes = require("./routes/event.routes");
const broadcastRoutes = require("./routes/broadcast.routes");
const adminRoutes = require("./routes/admin.routes");

app.use("/auth", authRoutes);
app.use("/incomes", incomeRoutes);
app.use("/expenses", expenseRoutes);
app.use("/summary", summaryRoutes);
app.use("/aspirations", aspirationRoutes);
app.use("/events", eventRoutes);
app.use("/broadcasts", broadcastRoutes);
app.use("/admin", adminRoutes);

module.exports = app;
