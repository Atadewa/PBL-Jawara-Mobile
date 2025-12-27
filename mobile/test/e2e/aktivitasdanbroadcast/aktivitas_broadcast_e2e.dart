/// E2E Test Suite - Aktivitas & Broadcast Feature
///
/// File ini mengumpulkan semua test cases untuk fitur Aktivitas & Broadcast
/// Jalankan dengan command: flutter test test/e2e/aktivitasdanbroadcast/
///
/// Test Files:
/// - aktivitas_broadcast_test.dart: Main page tests
/// - detail_pages_test.dart: Detail pages tests
/// - widgets_test.dart: Widget component tests
///
/// Cara menjalankan:
/// ```bash
/// flutter test test/e2e/aktivitasdanbroadcast/
/// ```
///
/// Atau jalankan file test individual:
/// ```bash
/// flutter test test/e2e/aktivitasdanbroadcast/aktivitas_broadcast_test.dart
/// flutter test test/e2e/aktivitasdanbroadcast/detail_pages_test.dart
/// flutter test test/e2e/aktivitasdanbroadcast/widgets_test.dart
/// ```
library aktivitas_broadcast_e2e;

// Export robots dan mocks untuk reuse
export 'robots/aktivitas_robot.dart';
export 'robots/detail_robot.dart';
export 'mocks/mock_aktivitas_service.dart';
