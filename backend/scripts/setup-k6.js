/**
 * Quick Setup for k6 Load Testing
 *
 * This script helps you quickly generate a token for load testing
 * without needing .env.test configured.
 */

const readline = require("readline");
const { createClient } = require("@supabase/supabase-js");
const fs = require("fs");
const path = require("path");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function question(query) {
  return new Promise((resolve) => rl.question(query, resolve));
}

async function setup() {
  console.log("\n🚀 k6 Load Testing Setup\n");
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  // Get Supabase credentials
  const supabaseUrl = await question("Supabase URL: ");
  const supabaseKey = await question("Supabase Anon Key: ");
  const email = await question("Test User Email: ");
  const password = await question("Test User Password: ");

  console.log("\n🔐 Attempting to login...");

  const supabase = createClient(supabaseUrl, supabaseKey);

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    console.error("❌ Error:", error.message);
    rl.close();
    process.exit(1);
  }

  console.log("\n✅ Login successful!");

  // Get base URL
  const baseUrl =
    (await question(
      "\nBase URL for testing (default: http://localhost:3000): "
    )) || "http://localhost:3000";

  // Create .env file
  const envContent = `# k6 Load Testing Environment Variables
BASE_URL=${baseUrl}
AUTH_TOKEN=${data.session.access_token}

# Optional: Test user credentials
TEST_USER_EMAIL=${email}
TEST_USER_PASSWORD=${password}
`;

  const envPath = path.join(__dirname, "..", "k6", ".env");
  fs.writeFileSync(envPath, envContent);

  console.log("\n✅ Configuration saved to k6/.env");
  console.log("\n📋 Your auth token:");
  console.log(data.session.access_token);
  console.log(
    "\n⏰ Token expires at:",
    new Date(data.session.expires_at * 1000).toLocaleString()
  );
  console.log("\n🎯 Next steps:");
  console.log("  1. Start your backend: npm start");
  console.log("  2. Run smoke test: k6 run k6/smoke-test.js");
  console.log(
    '  3. Or run with inline env: $env:BASE_URL="http://localhost:3000"; $env:AUTH_TOKEN="your_token"; k6 run k6/smoke-test.js'
  );
  console.log("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

  rl.close();
}

setup().catch((err) => {
  console.error("Error:", err);
  rl.close();
  process.exit(1);
});
