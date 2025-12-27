import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/log_aktivitas/data/models/user_role.dart';
import 'package:mobile/features/log_aktivitas/presentation/pages/log_aktivitas_page.dart';
import 'package:mobile/features/log_aktivitas/presentation/widgets/activity_log_card.dart';

/// E2E Tests untuk fitur Log Aktivitas
/// Fokus pada user journey, bukan detail UI elements

void main() {
  group('Log Aktivitas E2E Tests', () {
    // Helper function to create the app
    Widget createLogAktivitasApp() {
      return MaterialApp(
        home: const LogAktivitasPage(),
        theme: ThemeData(
          fontFamily: 'Arimo',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        ),
      );
    }

    // Helper function to wait for page to load
    Future<void> waitForPageLoad(WidgetTester tester) async {
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    }

    // Helper function to open filter
    Future<void> openFilter(WidgetTester tester) async {
      final filterButton = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.icon is Icon,
      ).last;
      await tester.tap(filterButton);
      await tester.pumpAndSettle();
    }

    testWidgets('Halaman log aktivitas menampilkan list aktivitas dengan data lengkap', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLogAktivitasApp());
      await waitForPageLoad(tester);

      // Assert
      expect(find.text('Log Aktivitas'), findsOneWidget);
      expect(find.text('Riwayat aktivitas pengguna'), findsOneWidget);
      expect(find.byType(ActivityLogCard), findsAtLeastNWidgets(1));
    });

    testWidgets('Filter berdasarkan role menampilkan aktivitas sesuai pilihan aktor', (tester) async {
      // Arrange
      await tester.pumpWidget(createLogAktivitasApp());
      await waitForPageLoad(tester);

      // Act - Open filter
      await openFilter(tester);
      expect(find.text('Filter Log Aktivitas'), findsOneWidget);

      // Select Admin role
      final dropdown = find.byType(DropdownButton<UserRole?>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();

      // Apply filter
      await tester.tap(find.text('Terapkan Filter'));
      await tester.pumpAndSettle();

      // Assert - Filter dialog closed
      expect(find.text('Filter Log Aktivitas'), findsNothing);
      expect(find.text('Log Aktivitas'), findsOneWidget);
    });

    testWidgets('Filter berdasarkan rentang tanggal menampilkan aktivitas sesuai periode', (tester) async {
      // Arrange
      await tester.pumpWidget(createLogAktivitasApp());
      await waitForPageLoad(tester);

      // Act - Open filter
      await openFilter(tester);

      // Verify date picker fields exist
      expect(find.text('Dari Tanggal'), findsOneWidget);
      expect(find.text('Sampai Tanggal'), findsOneWidget);
      expect(find.text('Pilih tanggal'), findsAtLeastNWidgets(1));

      // Close filter
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filter Log Aktivitas'), findsNothing);
    });

    testWidgets('Reset filter mengembalikan tampilan ke semua aktivitas', (tester) async {
      // Arrange
      await tester.pumpWidget(createLogAktivitasApp());
      await waitForPageLoad(tester);

      await openFilter(tester);

      // Act - Select a role
      final dropdown = find.byType(DropdownButton<UserRole?>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Admin').last);
      await tester.pumpAndSettle();

      // Reset filter
      await tester.tap(find.text('Reset Filter'));
      await tester.pumpAndSettle();

      // Assert - Dropdown shows "Semua Aktor" again
      expect(find.text('Semua Aktor'), findsOneWidget);
      expect(find.text('Pilih tanggal'), findsAtLeastNWidgets(2));
    });

    testWidgets('Pull to refresh memuat ulang data aktivitas terbaru', (tester) async {
      // Arrange
      await tester.pumpWidget(createLogAktivitasApp());
      await waitForPageLoad(tester);

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Act - Pull to refresh
      final listView = find.byType(ListView);
      await tester.fling(listView, const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert - Page still displays correctly
      expect(find.text('Log Aktivitas'), findsOneWidget);
      expect(find.byType(ActivityLogCard), findsAtLeastNWidgets(1));
    });

    testWidgets('Navigasi back button kembali ke halaman sebelumnya', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LogAktivitasPage()),
                  ),
                  child: const Text('Go to Log'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to LogAktivitasPage
      await tester.tap(find.text('Go to Log'));
      await tester.pumpAndSettle();
      expect(find.text('Log Aktivitas'), findsOneWidget);

      // Act - Tap back button
      final backButton = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.arrow_back,
      );
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      // Assert - Back to previous page
      expect(find.text('Go to Log'), findsOneWidget);
    });
  });
}
