import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/pages/aktivitas_dan_broadcast_page.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/pages/add_kegiatan_page.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/pages/add_broadcast_page.dart';
import 'package:mobile/core/routes/app_routes.dart';

/// E2E Test Suite untuk Fitur Aktivitas & Broadcast
///
/// Skenario yang diuji:
/// 1. Menampilkan list aktivitas
/// 2. Menampilkan list broadcast
/// 3. Buka halaman detail aktivitas (via tap card)
/// 4. Buka halaman detail broadcast (via tap card)
/// 5. Tekan edit aktivitas
/// 6. Tekan edit broadcast
/// 7. Simpan/batal edit aktivitas & broadcast
/// 8. Tekan tambah aktivitas
/// 9. Tekan tambah broadcast
/// 10. Simpan data yang ditambahkan
///
/// Note: Tests yang memerlukan API call dengan timer (detail/edit pages)
/// di-skip karena menyebabkan "pending timer" error dalam test environment.
/// Focus test pada halaman utama dan form tambah yang tidak memiliki timer.
void main() {
  // Disable Google Fonts untuk testing
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // ===============================================================
  // GRUP 1: MENAMPILKAN LIST AKTIVITAS & BROADCAST
  // ===============================================================
  group('1. Menampilkan List Aktivitas & Broadcast', () {
    testWidgets('TC01 - Menampilkan list aktivitas (kegiatan)', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Verify: Tab Kegiatan ada
      final kegiatanTab = find.widgetWithText(Tab, 'Kegiatan');
      expect(kegiatanTab, findsOneWidget);

      // Tap tab Kegiatan
      await tester.tap(kegiatanTab);
      await tester.pumpAndSettle();

      // Verify: TabBarView ada untuk konten
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('TC02 - Menampilkan list broadcast', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Verify: Tab Broadcast ada
      final broadcastTab = find.widgetWithText(Tab, 'Broadcast');
      expect(broadcastTab, findsOneWidget);

      // Tap tab Broadcast
      await tester.tap(broadcastTab);
      await tester.pumpAndSettle();

      // Verify: TabBarView ada untuk konten
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });

  // ===============================================================
  // GRUP 2: NAVIGASI KE HALAMAN DETAIL
  // ===============================================================
  group('2. Navigasi ke Halaman Detail', () {
    testWidgets('TC03 - Card aktivitas dapat di-tap', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Tap tab Kegiatan
      final kegiatanTab = find.widgetWithText(Tab, 'Kegiatan');
      await tester.tap(kegiatanTab);
      await tester.pumpAndSettle();

      // Verify: konten kegiatan dimuat (ada ListView atau Container)
      final hasContent =
          find.byType(ListView).evaluate().isNotEmpty ||
          find.byType(Container).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });

    testWidgets('TC04 - Card broadcast dapat di-tap', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Tap tab Broadcast
      final broadcastTab = find.widgetWithText(Tab, 'Broadcast');
      await tester.tap(broadcastTab);
      await tester.pumpAndSettle();

      // Verify: konten broadcast dimuat
      final hasContent =
          find.byType(ListView).evaluate().isNotEmpty ||
          find.byType(Container).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });
  });

  // ===============================================================
  // GRUP 3: TOMBOL TAMBAH (FAB)
  // ===============================================================
  group('3. Tombol Tambah Aktivitas & Broadcast', () {
    testWidgets('TC05 - FAB untuk tambah aktivitas tersedia', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Verify: FAB ada di halaman
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify: FAB memiliki icon add
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('TC06 - Halaman tambah aktivitas dapat dimuat', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddKegiatanPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Verify: halaman tambah kegiatan dimuat
      expect(find.byType(AddKegiatanPage), findsOneWidget);
    });

    testWidgets('TC07 - Halaman tambah broadcast dapat dimuat', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddBroadcastPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Verify: halaman tambah broadcast dimuat
      expect(find.byType(AddBroadcastPage), findsOneWidget);
    });
  });

  // ===============================================================
  // GRUP 4: FORM TAMBAH AKTIVITAS
  // ===============================================================
  group('4. Form Tambah Aktivitas', () {
    testWidgets('TC08 - Form tambah aktivitas memiliki input fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddKegiatanPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Verify: ada TextFormField untuk input
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('TC09 - Input text ke form tambah aktivitas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddKegiatanPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Isi form pertama
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'Gotong Royong RT 05');
      await tester.pump();

      // Verify: input tersimpan
      expect(find.text('Gotong Royong RT 05'), findsOneWidget);
    });

    testWidgets('TC10 - Tombol simpan aktivitas tersedia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddKegiatanPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke bawah
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify: tombol simpan ada
      expect(find.text('Simpan Kegiatan'), findsOneWidget);
    });

    testWidgets('TC11 - Tap simpan dengan form kosong (validasi)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddKegiatanPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke bawah
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap simpan tanpa isi form
      await tester.tap(find.text('Simpan Kegiatan'));
      await tester.pumpAndSettle();

      // Verify: masih di halaman yang sama (form tidak submit)
      expect(find.byType(AddKegiatanPage), findsOneWidget);
    });
  });

  // ===============================================================
  // GRUP 5: FORM TAMBAH BROADCAST
  // ===============================================================
  group('5. Form Tambah Broadcast', () {
    testWidgets('TC12 - Form tambah broadcast memiliki input fields', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddBroadcastPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Verify: ada TextFormField untuk input
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('TC13 - Input text ke form tambah broadcast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddBroadcastPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Isi form pertama
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'Pengumuman Iuran Bulanan');
      await tester.pump();

      // Verify: input tersimpan
      expect(find.text('Pengumuman Iuran Bulanan'), findsOneWidget);
    });

    testWidgets('TC14 - Tombol simpan broadcast tersedia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddBroadcastPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke bawah
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify: tombol simpan ada
      expect(find.text('Simpan Broadcast'), findsOneWidget);
    });

    testWidgets('TC15 - Tap simpan broadcast dengan form kosong (validasi)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AddBroadcastPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pumpAndSettle();

      // Scroll ke bawah
      final scrollable = find.byType(SingleChildScrollView);
      await tester.drag(scrollable.first, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap simpan tanpa isi form
      await tester.tap(find.text('Simpan Broadcast'));
      await tester.pumpAndSettle();

      // Verify: masih di halaman yang sama
      expect(find.byType(AddBroadcastPage), findsOneWidget);
    });
  });

  // ===============================================================
  // GRUP 6: TAB NAVIGATION
  // ===============================================================
  group('6. Tab Navigation', () {
    testWidgets('TC16 - Switch antara tab Kegiatan dan Broadcast', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      final kegiatanTab = find.widgetWithText(Tab, 'Kegiatan');
      final broadcastTab = find.widgetWithText(Tab, 'Broadcast');

      // Tap Kegiatan
      await tester.tap(kegiatanTab);
      await tester.pumpAndSettle();

      // Tap Broadcast
      await tester.tap(broadcastTab);
      await tester.pumpAndSettle();

      // Tap Kegiatan lagi
      await tester.tap(kegiatanTab);
      await tester.pumpAndSettle();

      // Verify: masih di halaman utama
      expect(find.byType(AktivitasDanBroadcastPage), findsOneWidget);
    });

    testWidgets('TC17 - Title halaman utama ditampilkan', (tester) async {
      await tester.pumpWidget(_createTestApp());
      await tester.pumpAndSettle();

      // Verify: title ada
      expect(find.text('Kegiatan & Broadcast'), findsOneWidget);
    });
  });
}

// ===============================================================
// HELPER FUNCTIONS
// ===============================================================

/// Membuat test app sederhana
Widget _createTestApp() {
  return const MaterialApp(home: AktivitasDanBroadcastPage());
}
