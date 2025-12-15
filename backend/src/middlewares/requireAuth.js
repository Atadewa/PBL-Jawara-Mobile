const { supabaseAdmin } = require("../lib/supabaseAdmin");

function getBearerToken(req) {
  const h = req.headers.authorization || "";
  const [type, token] = h.split(" ");
  if (type !== "Bearer" || !token) return null;
  return token;
}

function computeScope(roleNames, roleRows) {
  // Prioritas: admin > ketua_rw > ketua_rt > lainnya
  if (roleNames.includes("admin")) return { mode: "all", rw: null, rt: null };

  // ambil scope yang paling “lebar”
  const rwRow = roleRows.find((x) => x.rw != null && x.rt == null);
  if (rwRow) return { mode: "rw", rw: rwRow.rw, rt: null };

  const rtRow = roleRows.find((x) => x.rw != null && x.rt != null);
  if (rtRow) return { mode: "rt", rw: rtRow.rw, rt: rtRow.rt };

  return { mode: "none", rw: null, rt: null };
}

async function requireAuth(req, res, next) {
  try {
    const token = getBearerToken(req);
    if (!token) return res.status(401).json({ message: "Missing bearer token" });

    // 1) validasi token -> auth user
    const { data: authData, error: authError } = await supabaseAdmin.auth.getUser(token);
    if (authError || !authData?.user) {
      return res.status(401).json({ message: "Invalid token" });
    }

    const authUser = authData.user;

    // 2) cari app user di tabel public.users
    const { data: appUser, error: appUserError } = await supabaseAdmin
      .from("users")
      .select("id, name, email, phone, is_active, resident_id")
      .eq("auth_user_id", authUser.id)
      .single();

    if (appUserError || !appUser) {
      return res.status(403).json({ message: "User profile not found in public.users" });
    }
    if (!appUser.is_active) {
      return res.status(403).json({ message: "Account not active (waiting approval)" });
    }

    // 3) ambil roles + scope dari user_roles join roles
    const { data: roleRows, error: roleError } = await supabaseAdmin
      .from("user_roles")
      .select("rt, rw, roles(name)")
      .eq("user_id", appUser.id);

    if (roleError) return res.status(500).json({ message: roleError.message });

    const roleNames = (roleRows || [])
      .map((r) => r.roles?.name)
      .filter(Boolean);

    const scope = computeScope(roleNames, roleRows || []);

    req.userContext = { authUser, appUser, roleNames, scope };
    return next();
  } catch (e) {
    return res.status(500).json({ message: e.message || "Server error" });
  }
}

module.exports = { requireAuth };
