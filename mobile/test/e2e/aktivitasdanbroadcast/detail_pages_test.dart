import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/pages/add_kegiatan_page.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/pages/add_broadcast_page.dart';

/// E2E Test Suite untuk Detail Pages (Add Kegiatan/Broadcast)
///
/// Note: Test langsung ke halaman form tanpa navigasi
void main() {
  // Disable Google Fonts untuk testing
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Add Kegiatan Page E2E Tests', () {
    /// =========================================
    /// TC01: Halaman Tambah Kegiatan Loaded
    /// =========================================
    testWidgets('TC01 - Halaman tambah kegiatan berhasil dimuat', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify page loaded dengan adanya SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    /// =========================================
    /// TC02: Form Fields Exist
    /// =========================================
    testWidgets('TC02 - Form fields untuk input kegiatan ada', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify ada TextFormField untuk input
      expect(find.byType(TextFormField), findsWidgets);
    });

    /// =========================================
    /// TC03: Input Text ke Form
    /// =========================================
    testWidgets('TC03 - Input text ke form fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Find first text field dan input text
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // Input text ke field pertama
      await tester.enterText(textFields.first, 'Test Kegiatan');
      await tester.pump();

      // Verify text diinput
      expect(find.text('Test Kegiatan'), findsOneWidget);
    });

    /// =========================================
    /// TC04: Scroll Form
    /// =========================================
    testWidgets('TC04 - Scroll form tambah kegiatan', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Find scrollable
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsWidgets);

      // Try scroll
      await tester.drag(scrollable.first, const Offset(0, -200));
      await tester.pumpAndSettle();

      // If no error, scroll works
      expect(scrollable, findsWidgets);
    });

    /// =========================================
    /// TC05: Simpan Button Text Exists
    /// =========================================
    testWidgets('TC05 - Tombol simpan kegiatan tersedia', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Scroll ke bawah untuk melihat button
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify tombol simpan ada (menggunakan text)
      expect(find.text('Simpan Kegiatan'), findsOneWidget);
    });

    /// =========================================
    /// TC06: Category Dropdown/Selection Exists
    /// =========================================
    testWidgets('TC06 - Dropdown kategori tersedia', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify DropdownButton atau text terkait kategori ada
      final hasDropdown = find
          .byType(DropdownButton<String>)
          .evaluate()
          .isNotEmpty;
      final hasDropdownFormField = find
          .byType(DropdownButtonFormField<String>)
          .evaluate()
          .isNotEmpty;
      final hasCategoryText =
          find.text('Kategori').evaluate().isNotEmpty ||
          find.text('Pilih Kategori').evaluate().isNotEmpty;

      expect(hasDropdown || hasDropdownFormField || hasCategoryText, isTrue);
    });
  });

  group('Add Broadcast Page E2E Tests', () {
    /// =========================================
    /// TC07: Halaman Tambah Broadcast Loaded
    /// =========================================
    testWidgets('TC07 - Halaman tambah broadcast berhasil dimuat', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Verify page loaded dengan adanya SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    /// =========================================
    /// TC08: Form Fields untuk Broadcast Exist
    /// =========================================
    testWidgets('TC08 - Form fields untuk input broadcast ada', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Verify ada TextFormField untuk input
      expect(find.byType(TextFormField), findsWidgets);
    });

    /// =========================================
    /// TC09: Input Text ke Form Broadcast
    /// =========================================
    testWidgets('TC09 - Input text ke form fields broadcast', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Find first text field dan input text
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // Input text ke field pertama
      await tester.enterText(textFields.first, 'Test Broadcast');
      await tester.pump();

      // Verify text diinput
      expect(find.text('Test Broadcast'), findsOneWidget);
    });

    /// =========================================
    /// TC10: Scroll Form Broadcast
    /// =========================================
    testWidgets('TC10 - Scroll form tambah broadcast', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Find scrollable
      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsWidgets);

      // Try scroll
      await tester.drag(scrollable.first, const Offset(0, -200));
      await tester.pumpAndSettle();

      // If no error, scroll works
      expect(scrollable, findsWidgets);
    });

    /// =========================================
    /// TC11: Simpan Button Broadcast Exists
    /// =========================================
    testWidgets('TC11 - Tombol simpan broadcast tersedia', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Scroll ke bawah untuk melihat button
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify tombol simpan ada (menggunakan text)
      expect(find.text('Simpan Broadcast'), findsOneWidget);
    });
  });

  group('Form Layout E2E Tests', () {
    /// =========================================
    /// TC12: Kegiatan Form has Container Layout
    /// =========================================
    testWidgets('TC12 - Form kegiatan memiliki layout container', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify containers exist for layout
      expect(find.byType(Container), findsWidgets);
    });

    /// =========================================
    /// TC13: Broadcast Form has Container Layout
    /// =========================================
    testWidgets('TC13 - Form broadcast memiliki layout container', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddBroadcastPage()));
      await tester.pumpAndSettle();

      // Verify containers exist for layout
      expect(find.byType(Container), findsWidgets);
    });

    /// =========================================
    /// TC14: Column Layout for Form
    /// =========================================
    testWidgets('TC14 - Form menggunakan Column layout', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify Column layout exists
      expect(find.byType(Column), findsWidgets);
    });

    /// =========================================
    /// TC15: Padding Applied to Form
    /// =========================================
    testWidgets('TC15 - Form memiliki Padding', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddKegiatanPage()));
      await tester.pumpAndSettle();

      // Verify Padding exists
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
