/**
 * Generate JWT Token untuk k6 Load Testing
 * Jalankan: node scripts/generate-k6-token.js
 */

const { createClient } = require("@supabase/supabase-js");
const readline = require("readline");
const fs = require("fs");
const path = require("path");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function question(query) {
  return new Promise((resolve) => rl.question(query, resolve));
}

// Read .env file from k6 folder
function readEnvFile() {
  const envPath = path.join(__dirname, "..", "k6", ".env");
  const env = {};

  console.log(`📁 Reading .env from: ${envPath}`);

  if (fs.existsSync(envPath)) {
    const content = fs.readFileSync(envPath, "utf-8");
    content.split("\n").forEach((line) => {
      // Skip comments and empty lines
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) return;

      // Parse KEY=VALUE
      const equalsIndex = trimmed.indexOf("=");
      if (equalsIndex > 0) {
        const key = trimmed.substring(0, equalsIndex).trim();
        const value = trimmed.substring(equalsIndex + 1).trim();
        env[key] = value;
      }
    });
    console.log(`✓ Found ${Object.keys(env).length} environment variables\n`);
  } else {
    console.log(`⚠️  .env file not found at ${envPath}\n`);
  }

  return env;
}

async function generateToken(supabase, email, password, userLabel) {
  console.log(`\n🔐 Logging in as ${userLabel} (${email})...\n`);

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    console.error(`❌ Login gagal untuk ${userLabel}:`, error.message);
    return null;
  }

  const token = data.session.access_token;
  const expiresAt = new Date(data.session.expires_at * 1000);

  console.log(`✅ Login berhasil untuk ${userLabel}!\n`);
  console.log(`📋 JWT Token (${userLabel}):`);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  console.log(token);
  console.log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
  console.log(`⏰ Token expires at: ${expiresAt.toLocaleString()}\n`);

  return { token, expiresAt };
}

async function main() {
  console.log("\n🔑 Generate JWT Tokens untuk k6 Load Testing\n");

  // Read from .env file
  const envVars = readEnvFile();

  // Input credentials (use .env as default)
  const supabaseUrl =
    envVars.SUPABASE_URL || (await question("Supabase URL: "));
  const supabaseKey =
    envVars.SUPABASE_ANON_KEY || (await question("Supabase Anon Key: "));

  if (envVars.SUPABASE_URL) {
    console.log(`✓ Using Supabase URL from .env: ${supabaseUrl}`);
  }

  const supabase = createClient(supabaseUrl, supabaseKey);

  // Generate token untuk User 1 (Admin/Moderator)
  const email1 = envVars.TEST_USER_EMAIL || (await question("User 1 Email: "));
  const password1 =
    envVars.TEST_USER_PASSWORD || (await question("User 1 Password: "));
  const user1Result = await generateToken(
    supabase,
    email1,
    password1,
    "User 1 (Admin)"
  );

  // Generate token untuk User 2 (Resident untuk aspiration)
  let user2Result = null;
  if (envVars.TEST_USER_EMAIL_2 && envVars.TEST_USER_PASSWORD_2) {
    console.log(`✓ Found User 2 credentials in .env`);
    user2Result = await generateToken(
      supabase,
      envVars.TEST_USER_EMAIL_2,
      envVars.TEST_USER_PASSWORD_2,
      "User 2 (Resident)"
    );
  }

  if (!user1Result) {
    console.error("❌ Gagal generate token untuk User 1");
    rl.close();
    process.exit(1);
  }

  // Update .env file
  const envPath = path.join(__dirname, "..", "k6", ".env");

  try {
    let envContent = "";

    if (fs.existsSync(envPath)) {
      envContent = fs.readFileSync(envPath, "utf-8");

      // Update AUTH_TOKEN (User 1)
      if (envContent.includes("AUTH_TOKEN=")) {
        envContent = envContent.replace(
          /AUTH_TOKEN=.*/g,
          `AUTH_TOKEN=${user1Result.token}`
        );
      } else {
        envContent += `\nAUTH_TOKEN=${user1Result.token}\n`;
      }

      // Update AUTH_TOKEN_2 (User 2) jika ada
      if (user2Result) {
        if (envContent.includes("AUTH_TOKEN_2=")) {
          envContent = envContent.replace(
            /AUTH_TOKEN_2=.*/g,
            `AUTH_TOKEN_2=${user2Result.token}`
          );
        } else {
          envContent += `\n# Token untuk User 2 (Resident - khusus create aspiration)\nAUTH_TOKEN_2=${user2Result.token}\n`;
        }
      }
    } else {
      // Buat .env baru
      envContent = `BASE_URL=https://backend-jawara.vercel.app\nAUTH_TOKEN=${user1Result.token}\n`;
      if (user2Result) {
        envContent += `\n# Token untuk User 2 (Resident - khusus create aspiration)\nAUTH_TOKEN_2=${user2Result.token}\n`;
      }
    }

    fs.writeFileSync(envPath, envContent);
    console.log("✅ Token(s) berhasil disimpan ke k6/.env\n");
  } catch (err) {
    console.error("⚠️  Gagal menyimpan ke .env:", err.message);
    console.log("\n💡 Copy token di atas dan paste ke k6/.env secara manual\n");
  }

  console.log("🚀 Next steps:");
  console.log("   1. Run: k6 run k6/load-test.js");
  console.log("   2. Test akan otomatis menggunakan:");
  console.log("      - AUTH_TOKEN untuk income/expense/operasi admin");
  console.log(
    "      - AUTH_TOKEN_2 untuk create aspiration (menghindari 403)\n"
  );

  rl.close();
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});
