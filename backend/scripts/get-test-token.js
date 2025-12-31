require("dotenv").config({ path: ".env.test" });
const { createClient } = require("@supabase/supabase-js");

async function getTestToken() {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  );

  const email = process.env.TEST_USER_EMAIL;
  const password = process.env.TEST_USER_PASSWORD;

  if (!email || !password) {
    console.error(
      "❌ TEST_USER_EMAIL and TEST_USER_PASSWORD must be set in .env.test"
    );
    process.exit(1);
  }

  console.log("🔐 Attempting to login...");
  console.log(`Email: ${email}`);

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }

  console.log("\n✅ Login successful!");
  console.log("\n📋 Access Token:");
  console.log(data.session.access_token);
  console.log("\n💡 Add this to .env.test:");
  console.log(`TEST_ADMIN_TOKEN=${data.session.access_token}`);
  console.log(
    "\n⏰ Token expires at:",
    new Date(data.session.expires_at * 1000).toLocaleString()
  );
}

getTestToken().catch(console.error);
