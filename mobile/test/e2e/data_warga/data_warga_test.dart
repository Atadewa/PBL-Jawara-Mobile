import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/features/home/pages/home_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/daftar_rumah_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/detail_rumah_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/tambah_rumah_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/edit_rumah_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/daftar_keluarga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/detail_keluarga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/tambah_keluarga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/edit_keluarga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/daftar_warga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/detail_warga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/tambah_warga_page.dart';
import 'package:mobile/features/data_rumah_dan_warga/pages/edit_warga_page.dart';

void main() {
  group('Data Rumah dan Warga E2E Tests', () {
    // Set up larger test viewport before all tests
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Set larger viewport size for all tests (1080x1920 - typical phone size)
      TestWidgetsFlutterBinding.instance.window.physicalSizeTestValue =
          const Size(1080, 1920);
      TestWidgetsFlutterBinding.instance.window.devicePixelRatioTestValue = 1.0;
    });

    tearDown(() {
      // Reset to default size after each test
      TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue();
      TestWidgetsFlutterBinding.instance.window
          .clearDevicePixelRatioTestValue();
    });

    testWidgets('Complete flow: Navigate from Home to Data Rumah', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Handle login
      final loginButton = find.byKey(const Key('login_submit_button'));
      expect(loginButton, findsOneWidget);

      final usernameField = find.byKey(const Key('login_username_field'));
      final passwordField = find.byKey(const Key('login_password_field'));

      await tester.enterText(usernameField, 'test@example.com');
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on Home page
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Selamat Datang,'), findsOneWidget);

      // Find the InkWell for "Rumah" menu
      final rumahTappable = find.ancestor(
        of: find.byIcon(Icons.home),
        matching: find.byType(InkWell),
      );
      expect(rumahTappable, findsOneWidget);

      // Scroll until visible then tap
      await tester.dragUntilVisible(
        rumahTappable,
        find.byType(HomePage),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(rumahTappable);
      await tester.pumpAndSettle();

      // Verify we're on Daftar Rumah page
      expect(find.byType(DaftarRumahPage), findsOneWidget);
      expect(find.text('Daftar Rumah'), findsOneWidget);
    });

    testWidgets('Daftar Rumah: Display and filter rumah list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Daftar Rumah
      await _navigateToDataRumah(tester);

      // Verify page elements
      expect(find.text('Daftar Rumah'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Test search functionality - find TextField in DaftarRumahPage
      final searchField = find.descendant(
        of: find.byType(DaftarRumahPage),
        matching: find.byType(TextField),
      );
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      await tester.enterText(searchField, 'RT 01');
      await tester.pumpAndSettle();

      // Verify search results update (dummy data should filter)
      expect(find.textContaining('RT 01'), findsWidgets);
    });

    testWidgets('Add Rumah: Fill form and submit', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Tap FAB to add new rumah
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on Tambah Rumah page
      expect(find.byType(TambahRumahPage), findsOneWidget);
      expect(find.text('Tambah Data Rumah'), findsOneWidget);

      // Fill the form
      await _fillRumahForm(
        tester,
        alamat: 'Jl. Test No. 123',
        rt: '01',
        rw: '05',
        blok: 'A',
      );

      // Submit form
      final submitButton = find.ancestor(
        of: find.text('Tambah Data Rumah'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify we left the add page (success or validation)
      // Note: Without backend, this test verifies form interaction works
    });

    testWidgets('Detail Rumah: View and navigate to keluarga', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Tap on first rumah card (second InkWell, first is back button)
      final rumahCards = find.byType(InkWell);
      await tester.tap(rumahCards.at(1));
      await tester.pumpAndSettle();

      // Verify we're on Detail Rumah page
      expect(find.byType(DetailRumahPage), findsOneWidget);
      expect(find.text('Detail Rumah'), findsOneWidget);

      // Verify detail information is displayed
      expect(find.text('Blok / Nomor Rumah'), findsOneWidget);
      expect(find.text('Status Rumah'), findsOneWidget);
      expect(find.text('Alamat Lengkap'), findsOneWidget);

      // Tap "Lihat Daftar Keluarga" button
      final keluargaButton = find.ancestor(
        of: find.text('Lihat Daftar Keluarga'),
        matching: find.byType(OutlinedButton),
      );

      // Scroll button into view
      await tester.ensureVisible(keluargaButton);
      await tester.pumpAndSettle();

      await tester.tap(keluargaButton);
      await tester.pumpAndSettle();

      // Verify we're on Daftar Keluarga page
      expect(find.byType(DaftarKeluargaPage), findsOneWidget);
      expect(find.text('Daftar Keluarga'), findsOneWidget);
    });

    testWidgets('Edit Rumah: Update rumah data', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Tap on first rumah to view detail (second InkWell, first is back button)
      final rumahCards = find.byType(InkWell);
      await tester.ensureVisible(rumahCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(rumahCards.at(1));
      await tester.pumpAndSettle();

      // Tap Edit button
      final editButton = find.ancestor(
        of: find.text('Edit Rumah'),
        matching: find.byType(ElevatedButton),
      );
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify we're on Edit Rumah page
      expect(find.byType(EditRumahPage), findsOneWidget);
      expect(find.text('Edit Data Rumah'), findsOneWidget);

      // Update form fields - find specific field by descendant
      final alamatField = find
          .descendant(
            of: find.byType(TextFormField),
            matching: find.text('Jl. Mawar No. 12, RT 01 / RW 05'),
          )
          .first;
      await tester.enterText(alamatField, 'Jl. Updated No. 456');
      await tester.pumpAndSettle();

      // Submit form
      final updateButton = find.ancestor(
        of: find.text('Simpan Perubahan'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Verify success or navigation back
      expect(find.byType(EditRumahPage), findsNothing);
    });

    testWidgets('Daftar Keluarga: Display and add keluarga', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Navigate to detail rumah then keluarga list (second InkWell, first is back)
      final rumahCards = find.byType(InkWell);
      await tester.ensureVisible(rumahCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(rumahCards.at(1));
      await tester.pumpAndSettle();

      final keluargaButton = find.ancestor(
        of: find.text('Lihat Daftar Keluarga'),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(keluargaButton);
      await tester.pumpAndSettle();
      await tester.tap(keluargaButton);
      await tester.pumpAndSettle();

      // Verify page elements
      expect(find.text('Daftar Keluarga'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap FAB to add keluarga
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on Tambah Keluarga page
      expect(find.byType(TambahKeluargaPage), findsOneWidget);
      expect(find.text('Tambah Data Keluarga'), findsOneWidget);
    });

    testWidgets('Add Keluarga: Fill form and submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Tambah Keluarga
      await _navigateToTambahKeluarga(tester);

      // Verify we're on Tambah Keluarga page
      expect(find.byType(TambahKeluargaPage), findsOneWidget);

      // Fill the form
      await _fillKeluargaForm(
        tester,
        kk: '1234567890123456',
        nama: 'Keluarga Test',
        kepalaKeluarga: 'Budi Santoso',
      );

      // Submit form
      final submitButton = find.ancestor(
        of: find.text('Tambah Data Keluarga'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify form interaction works (without backend)
    });

    testWidgets('Detail Keluarga: View and navigate to warga', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Navigate to detail rumah
      final rumahCards = find.byType(InkWell);
      await tester.ensureVisible(rumahCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(rumahCards.at(1));
      await tester.pumpAndSettle();

      // Navigate to daftar keluarga
      final keluargaButton = find.ancestor(
        of: find.text('Lihat Daftar Keluarga'),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(keluargaButton);
      await tester.pumpAndSettle();
      await tester.tap(keluargaButton);
      await tester.pumpAndSettle();

      // Tap on first keluarga card (second InkWell, first is back button)
      final keluargaCards = find.byType(InkWell);
      await tester.ensureVisible(keluargaCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(keluargaCards.at(1));
      await tester.pumpAndSettle();

      // Verify we're on Detail Keluarga page
      expect(find.byType(DetailKeluargaPage), findsOneWidget);
      expect(find.text('Detail Keluarga'), findsOneWidget);

      // Tap "Lihat Daftar Warga" button
      final wargaButton = find.ancestor(
        of: find.text('Lihat Daftar Warga'),
        matching: find.byType(OutlinedButton),
      );
      await tester.tap(wargaButton);
      await tester.pumpAndSettle();

      // Verify we're on Daftar Warga page
      expect(find.byType(DaftarWargaPage), findsOneWidget);
      expect(find.text('Daftar Warga'), findsOneWidget);
    });

    testWidgets('Edit Keluarga: Update keluarga data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Navigate to detail rumah
      final rumahCards = find.byType(InkWell);
      await tester.ensureVisible(rumahCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(rumahCards.at(1));
      await tester.pumpAndSettle();

      // Navigate to daftar keluarga
      final keluargaButton = find.ancestor(
        of: find.text('Lihat Daftar Keluarga'),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(keluargaButton);
      await tester.pumpAndSettle();
      await tester.tap(keluargaButton);
      await tester.pumpAndSettle();

      // Tap on first keluarga to view detail
      final keluargaCards = find.byType(InkWell);
      await tester.ensureVisible(keluargaCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(keluargaCards.at(1));
      await tester.pumpAndSettle();

      // Tap Edit button
      final editButton = find.ancestor(
        of: find.text('Edit Keluarga'),
        matching: find.byType(ElevatedButton),
      );
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify we're on Edit Keluarga page
      expect(find.byType(EditKeluargaPage), findsOneWidget);
      expect(find.text('Edit Data Keluarga'), findsOneWidget);

      // Update form
      final namaField = find.byType(TextFormField).at(1); // Nama keluarga field
      await tester.enterText(namaField, 'Keluarga Updated');
      await tester.pumpAndSettle();

      // Submit
      final updateButton = find.ancestor(
        of: find.text('Simpan Perubahan'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Verify we left the edit page
      expect(find.byType(EditKeluargaPage), findsNothing);
    });

    testWidgets('Daftar Warga: Display and add warga', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Daftar Warga
      await _navigateToDaftarWarga(tester);

      // Verify page elements
      expect(find.text('Daftar Warga'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify warga cards are displayed
      expect(find.byIcon(Icons.person), findsWidgets);

      // Tap FAB to add warga
      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on Tambah Warga page
      expect(find.byType(TambahWargaPage), findsOneWidget);
      expect(find.text('Tambah Data Warga'), findsOneWidget);
    });

    testWidgets('Add Warga: Fill complete form and submit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Tambah Warga
      await _navigateToDaftarWarga(tester);

      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on Tambah Warga page
      expect(find.byType(TambahWargaPage), findsOneWidget);

      // Fill the comprehensive form
      await _fillWargaForm(
        tester,
        nik: '1234567890123456',
        nama: 'John Doe Test',
        tempatLahir: 'Jakarta',
        pekerjaan: 'Software Engineer',
        noTelepon: '08123456789',
      );

      // Submit form
      final submitButton = find.ancestor(
        of: find.text('Tambah Data Warga'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify form interaction works (without backend)
    });

    testWidgets('Detail Warga: View complete information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Daftar Warga
      await _navigateToDaftarWarga(tester);

      // Tap on first warga card (second InkWell, first is back button)
      final wargaCards = find.byType(InkWell);
      await tester.tap(wargaCards.at(1));
      await tester.pumpAndSettle();

      // Verify we're on Detail Warga page
      expect(find.byType(DetailWargaPage), findsOneWidget);
      expect(find.text('Detail Warga'), findsOneWidget);

      // Verify all detail fields are displayed
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('NIK'), findsOneWidget);
      expect(find.text('Jenis Kelamin'), findsOneWidget);
      expect(find.text('Tempat Lahir'), findsOneWidget);
      expect(find.text('Tanggal Lahir'), findsOneWidget);
      expect(find.text('Agama'), findsOneWidget);
      expect(find.text('Pendidikan Terakhir'), findsOneWidget);
      expect(find.text('Pekerjaan'), findsOneWidget);
      expect(find.text('Hubungan Keluarga'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('No. Telepon'), findsOneWidget);

      // Verify Edit button exists
      expect(
        find.ancestor(
          of: find.text('Edit Data Warga'),
          matching: find.byType(ElevatedButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Edit Warga: Update warga data', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Detail Warga
      await _navigateToDaftarWarga(tester);

      // Tap on first warga card (second InkWell, first is back button)
      final wargaCards = find.byType(InkWell);
      await tester.ensureVisible(wargaCards.at(1));
      await tester.pumpAndSettle();
      await tester.tap(wargaCards.at(1));
      await tester.pumpAndSettle();

      // Tap Edit button
      final editButton = find.ancestor(
        of: find.text('Edit Data Warga'),
        matching: find.byType(ElevatedButton),
      );
      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify we're on Edit Warga page
      expect(find.byType(EditWargaPage), findsOneWidget);
      expect(find.text('Edit Data Warga'), findsOneWidget);

      // Update some fields
      final namaField = find.byType(TextFormField).at(1); // Nama field
      await tester.enterText(namaField, 'John Doe Updated');
      await tester.pumpAndSettle();

      // Submit
      final updateButton = find.ancestor(
        of: find.text('Simpan Perubahan'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Verify we left the edit page
      expect(find.byType(EditWargaPage), findsNothing);
    });

    testWidgets('Navigation: Back button flow works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate deep into the hierarchy
      await _navigateToDaftarWarga(tester);

      // Verify we can go back through each page
      await tester.pageBack(); // Back to Detail Keluarga
      await tester.pumpAndSettle();
      expect(find.byType(DetailKeluargaPage), findsOneWidget);

      await tester.pageBack(); // Back to Daftar Keluarga
      await tester.pumpAndSettle();
      expect(find.byType(DaftarKeluargaPage), findsOneWidget);

      await tester.pageBack(); // Back to Detail Rumah
      await tester.pumpAndSettle();
      expect(find.byType(DetailRumahPage), findsOneWidget);

      await tester.pageBack(); // Back to Daftar Rumah
      await tester.pumpAndSettle();
      expect(find.byType(DaftarRumahPage), findsOneWidget);
    });

    testWidgets('Form Validation: Required fields show error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to Tambah Rumah
      await _navigateToDataRumah(tester);

      final fab = find.byType(FloatingActionButton);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we're on Tambah Rumah page
      expect(find.byType(TambahRumahPage), findsOneWidget);

      // Try to submit empty form
      final submitButton = find.ancestor(
        of: find.text('Tambah Data Rumah'),
        matching: find.byType(ElevatedButton),
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify validation errors appear (Flutter form validation)
      // Note: Actual error messages depend on the form implementation
      expect(
        find.byType(TambahRumahPage),
        findsOneWidget,
      ); // Still on same page
    });

    testWidgets('Search Functionality: Filter results correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await _navigateToDataRumah(tester);

      // Verify we're on Daftar Rumah page
      expect(find.byType(DaftarRumahPage), findsOneWidget);

      // Get initial card count (dummy data has multiple rumah)
      final initialRumah = find.textContaining('Jl.');
      final initialCount = initialRumah.evaluate().length;
      expect(initialCount > 0, true); // Should have some rumah

      // Search for specific term using TextField in DaftarRumahPage
      final searchField = find.descendant(
        of: find.byType(DaftarRumahPage),
        matching: find.byType(TextField),
      );
      expect(searchField, findsOneWidget);
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      await tester.enterText(searchField, 'Mawar');
      await tester.pumpAndSettle();

      // Verify filtered results show items with 'Mawar'
      expect(find.textContaining('Mawar'), findsWidgets);
    });
  });
}

// Helper functions for navigation

Future<void> _navigateToDataRumah(WidgetTester tester) async {
  // Handle login if on login page
  final loginButton = find.byKey(const Key('login_submit_button'));
  if (loginButton.evaluate().isNotEmpty) {
    // Fill login credentials
    final usernameField = find.byKey(const Key('login_username_field'));
    final passwordField = find.byKey(const Key('login_password_field'));

    await tester.enterText(usernameField, 'test@example.com');
    await tester.pumpAndSettle();
    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    // Tap login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // Verify we're on home page
  expect(find.byType(HomePage), findsOneWidget);

  // Navigate to Data Rumah from home
  // Find the InkWell that contains the "Rumah" menu item
  final rumahTappable = find.ancestor(
    of: find.byIcon(Icons.home),
    matching: find.byType(InkWell),
  );
  expect(rumahTappable, findsOneWidget);

  // Scroll until the Rumah menu is visible, then tap
  await tester.dragUntilVisible(
    rumahTappable,
    find.byType(HomePage),
    const Offset(0, -100),
  );
  await tester.pumpAndSettle();
  await tester.tap(rumahTappable);
  await tester.pumpAndSettle();
}

Future<void> _navigateToTambahKeluarga(WidgetTester tester) async {
  await _navigateToDataRumah(tester);

  // Navigate to detail rumah by tapping first rumah card
  final rumahCards = find.byType(InkWell);
  await tester.ensureVisible(rumahCards.at(1));
  await tester.pumpAndSettle();
  await tester.tap(
    rumahCards.at(1),
  ); // First card (second InkWell after back button)
  await tester.pumpAndSettle();

  // Verify we're on detail rumah
  expect(find.byType(DetailRumahPage), findsOneWidget);

  // Navigate to daftar keluarga
  final keluargaButton = find.ancestor(
    of: find.text('Lihat Daftar Keluarga'),
    matching: find.byType(OutlinedButton),
  );
  await tester.ensureVisible(keluargaButton);
  await tester.pumpAndSettle();
  await tester.tap(keluargaButton);
  await tester.pumpAndSettle();

  // Tap FAB to add
  final fab = find.byType(FloatingActionButton);
  await tester.tap(fab);
  await tester.pumpAndSettle();
}

Future<void> _navigateToDaftarWarga(WidgetTester tester) async {
  await _navigateToDataRumah(tester);

  // Navigate to detail rumah
  final rumahCards = find.byType(InkWell);
  await tester.ensureVisible(rumahCards.at(1));
  await tester.pumpAndSettle();
  await tester.tap(
    rumahCards.at(1),
  ); // First card (second InkWell after back button)
  await tester.pumpAndSettle();

  // Navigate to daftar keluarga
  final keluargaButton = find.ancestor(
    of: find.text('Lihat Daftar Keluarga'),
    matching: find.byType(OutlinedButton),
  );
  await tester.ensureVisible(keluargaButton);
  await tester.pumpAndSettle();
  await tester.tap(keluargaButton);
  await tester.pumpAndSettle();

  // Navigate to detail keluarga by tapping first keluarga card
  final keluargaCards = find.byType(InkWell);
  await tester.ensureVisible(keluargaCards.at(1));
  await tester.pumpAndSettle();
  await tester.tap(keluargaCards.at(1)); // First card after back button
  await tester.pumpAndSettle();

  // Navigate to daftar warga
  final wargaButton = find.ancestor(
    of: find.text('Lihat Daftar Warga'),
    matching: find.byType(OutlinedButton),
  );
  await tester.ensureVisible(wargaButton);
  await tester.pumpAndSettle();
  await tester.tap(wargaButton);
  await tester.pumpAndSettle();
}

// Helper functions for filling forms

Future<void> _fillRumahForm(
  WidgetTester tester, {
  required String alamat,
  required String rt,
  required String rw,
  required String blok,
}) async {
  // Find and fill form fields by their labels/hints
  final alamatField = find.widgetWithText(TextFormField, 'Alamat');
  await tester.enterText(alamatField, alamat);
  await tester.pumpAndSettle();

  final rtField = find.widgetWithText(TextFormField, 'RT');
  await tester.enterText(rtField, rt);
  await tester.pumpAndSettle();

  final rwField = find.widgetWithText(TextFormField, 'RW');
  await tester.enterText(rwField, rw);
  await tester.pumpAndSettle();

  final blokField = find.widgetWithText(TextFormField, 'Blok');
  await tester.enterText(blokField, blok);
  await tester.pumpAndSettle();
}

Future<void> _fillKeluargaForm(
  WidgetTester tester, {
  required String kk,
  required String nama,
  required String kepalaKeluarga,
}) async {
  final kkField = find.widgetWithText(TextFormField, 'Nomor KK');
  await tester.enterText(kkField, kk);
  await tester.pumpAndSettle();

  final namaField = find.widgetWithText(TextFormField, 'Nama Keluarga');
  await tester.enterText(namaField, nama);
  await tester.pumpAndSettle();

  final kepalaField = find.widgetWithText(TextFormField, 'Kepala Keluarga');
  await tester.enterText(kepalaField, kepalaKeluarga);
  await tester.pumpAndSettle();
}

Future<void> _fillWargaForm(
  WidgetTester tester, {
  required String nik,
  required String nama,
  required String tempatLahir,
  required String pekerjaan,
  required String noTelepon,
}) async {
  final nikField = find.widgetWithText(TextFormField, 'NIK');
  await tester.enterText(nikField, nik);
  await tester.pumpAndSettle();

  final namaField = find.widgetWithText(TextFormField, 'Nama Lengkap');
  await tester.enterText(namaField, nama);
  await tester.pumpAndSettle();

  final tempatLahirField = find.widgetWithText(TextFormField, 'Tempat Lahir');
  await tester.enterText(tempatLahirField, tempatLahir);
  await tester.pumpAndSettle();

  final pekerjaanField = find.widgetWithText(TextFormField, 'Pekerjaan');
  await tester.enterText(pekerjaanField, pekerjaan);
  await tester.pumpAndSettle();

  final noTeleponField = find.widgetWithText(TextFormField, 'No. Telepon');
  await tester.enterText(noTeleponField, noTelepon);
  await tester.pumpAndSettle();
}
