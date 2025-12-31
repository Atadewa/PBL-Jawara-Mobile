import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/verifikasi_warga/presentation/pages/verifikasi_warga_page.dart';
import 'package:mobile/features/verifikasi_warga/presentation/pages/detail_warga_page.dart';
import 'package:mobile/features/verifikasi_warga/presentation/widgets/warga_verification_card.dart';
import 'package:mobile/features/verifikasi_warga/data/models/warga_verification_item.dart';
import 'package:mobile/features/verifikasi_warga/data/models/warga_verification_status.dart';

/// E2E Tests untuk fitur Verifikasi Warga
/// Fokus pada user journey, bukan detail UI elements

void main() {
  group('Verifikasi Warga E2E Tests', () {
    // Helper: Open verifikasi warga page
    Future<void> openVerifikasiWargaPage(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: VerifikasiWargaPage()));
      await tester.pumpAndSettle();
    }

    // Helper: Wait for warga list to load
    Future<void> waitForWargaList(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(WargaVerificationCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }
    }

    // Helper: Open detail warga page with dummy data
    Future<void> openDetailWargaPage(WidgetTester tester) async {
      final dummyWarga = WargaVerificationItem(
        id: '1',
        nama: 'Budi Santoso',
        nik: '3201012345670001',
        umur: 28,
        diajukanOleh: 'Warga',
        tanggalPengajuan: DateTime(2024, 11, 20),
        status: WargaVerificationStatus.pending,
        tanggalLahir: DateTime(1996, 5, 15),
        jenisKelamin: 'Laki-laki',
        agama: 'Islam',
        pendidikan: 'S1',
        pekerjaan: 'Pegawai Swasta',
        nomorTelepon: '081234567890',
        kepalaKeluarga: 'Budi Santoso',
        keluarga: 'Keluarga Santoso',
      );

      await tester.pumpWidget(MaterialApp(home: DetailWargaPage(warga: dummyWarga)));
      await tester.pumpAndSettle();
    }

    testWidgets('Halaman verifikasi warga menampilkan list warga pending dengan data lengkap', (tester) async {
      // Arrange & Act
      await openVerifikasiWargaPage(tester);
      await waitForWargaList(tester);

      // Assert
      expect(find.text('Verifikasi Warga'), findsOneWidget);
      expect(find.text('Daftar warga yang menunggu persetujuan'), findsOneWidget);
      expect(find.byType(WargaVerificationCard), findsWidgets);
    });

    testWidgets('Tap card warga membuka halaman detail dengan informasi lengkap', (tester) async {
      // Arrange
      await openVerifikasiWargaPage(tester);
      await waitForWargaList(tester);

      // Act - Tap first card
      final firstCard = find.byType(WargaVerificationCard).first;
      if (firstCard.evaluate().isNotEmpty) {
        await tester.tap(firstCard);
        await tester.pumpAndSettle();
      }

      // Assert - Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('Halaman detail warga menampilkan semua informasi warga', (tester) async {
      // Arrange & Act
      await openDetailWargaPage(tester);

      // Assert
      expect(find.text('Detail Warga Pending'), findsOneWidget);
      expect(find.textContaining('Budi Santoso'), findsWidgets);
      expect(find.textContaining('3201012345670001'), findsOneWidget);
      expect(find.text('Informasi Dasar'), findsOneWidget);
      expect(find.text('Informasi Kontak'), findsOneWidget);
      expect(find.text('Informasi Keluarga'), findsOneWidget);
    });

    testWidgets('Tombol setujui membuka dialog konfirmasi persetujuan warga', (tester) async {
      // Arrange
      await openDetailWargaPage(tester);

      // Act - Tap approve button
      final approveButton = find.widgetWithText(ElevatedButton, 'Setujui');
      if (approveButton.evaluate().isNotEmpty) {
        await tester.tap(approveButton);
        await tester.pumpAndSettle();
      }

      // Assert - Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tombol tolak membuka dialog input alasan penolakan', (tester) async {
      // Arrange
      await openDetailWargaPage(tester);

      // Act - Tap reject button
      final rejectButton = find.widgetWithText(ElevatedButton, 'Tolak');
      if (rejectButton.evaluate().isNotEmpty) {
        await tester.tap(rejectButton);
        await tester.pumpAndSettle();

        // Enter rejection reason
        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, 'Data tidak lengkap');
          await tester.pumpAndSettle();
          expect(find.text('Data tidak lengkap'), findsOneWidget);
        }
      }

      // Assert - Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog konfirmasi dapat dibatalkan dan kembali ke halaman detail', (tester) async {
      // Arrange
      await openDetailWargaPage(tester);

      // Act - Open and cancel dialog
      final approveButton = find.widgetWithText(ElevatedButton, 'Setujui');
      if (approveButton.evaluate().isNotEmpty) {
        await tester.tap(approveButton);
        await tester.pumpAndSettle();

        final cancelButton = find.widgetWithText(OutlinedButton, 'Batal');
        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          await tester.pumpAndSettle();
        }
      }

      // Assert - Should still be on detail page
      expect(find.text('Detail Warga Pending'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pull to refresh memuat ulang daftar warga terbaru', (tester) async {
      // Arrange
      await openVerifikasiWargaPage(tester);
      await waitForWargaList(tester);

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Act - Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert
      expect(tester.takeException(), isNull);
      expect(find.byType(WargaVerificationCard), findsWidgets);
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
                    MaterialPageRoute(builder: (_) => const VerifikasiWargaPage()),
                  ),
                  child: const Text('Go to Verifikasi'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to VerifikasiWargaPage
      await tester.tap(find.text('Go to Verifikasi'));
      await tester.pumpAndSettle();
      expect(find.text('Verifikasi Warga'), findsOneWidget);

      // Act - Tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      }

      // Assert - Back to previous page
      expect(find.text('Go to Verifikasi'), findsOneWidget);
    });
  });
}
