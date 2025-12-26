// Cleanup Helper untuk Integration Tests
// Digunakan untuk menghapus data test setelah testing selesai

const { supabaseAdmin } = require("../../src/lib/supabaseAdmin");

/**
 * Cleanup test data dari database
 * Hanya hapus data yang dibuat oleh integration tests
 */
async function cleanupTestData() {
  try {
    // Hapus incomes dengan prefix TEST_
    await supabaseAdmin.from("incomes").delete().like("source_name", "TEST_%");

    // Hapus expenses dengan prefix TEST_
    await supabaseAdmin
      .from("expenses")
      .delete()
      .like("expense_name", "TEST_%");

    // Hapus events dengan prefix TEST_
    await supabaseAdmin.from("events").delete().like("title", "TEST_%");

    // Hapus broadcasts dengan prefix TEST_
    await supabaseAdmin.from("broadcasts").delete().like("title", "TEST_%");

    // Hapus aspirations dengan prefix TEST_
    await supabaseAdmin.from("aspirations").delete().like("title", "TEST_%");

    console.log("✅ Test data cleaned up successfully");
  } catch (error) {
    console.error("❌ Error cleaning up test data:", error.message);
  }
}

/**
 * Cleanup specific test user data
 */
async function cleanupTestUserData(userId) {
  try {
    await supabaseAdmin
      .from("incomes")
      .delete()
      .eq("recorded_by_user_id", userId);

    await supabaseAdmin
      .from("expenses")
      .delete()
      .eq("recorded_by_user_id", userId);

    console.log(`✅ Cleaned up data for user: ${userId}`);
  } catch (error) {
    console.error("❌ Error cleaning up user data:", error.message);
  }
}

module.exports = {
  cleanupTestData,
  cleanupTestUserData,
};
