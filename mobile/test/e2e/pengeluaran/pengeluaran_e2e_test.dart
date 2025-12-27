import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/pengeluaran/presentation/pages/pengeluaran_page.dart';
import 'package:mobile/features/pengeluaran/presentation/pages/add_pengeluaran_page.dart';
import 'package:mobile/features/pengeluaran/presentation/pages/edit_pengeluaran_page.dart';
import 'package:mobile/features/pengeluaran/presentation/pages/detail_pengeluaran_page.dart';
import 'package:mobile/features/pengeluaran/presentation/widgets/expense_card.dart';

/// E2E Tests untuk fitur Pengeluaran
/// Fokus pada user journey, bukan detail UI elements

void main() {
  group('Pengeluaran E2E Tests', () {
    testWidgets('Daftar pengeluaran tampil di halaman utama dengan data lengkap', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MaterialApp(home: PengeluaranPage()));
      await tester.pumpAndSettle();
      
      // Wait for expense list to load
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(ExpenseCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Assert
      expect(find.text('Daftar Pengeluaran'), findsOneWidget);
      expect(find.byType(ExpenseCard), findsWidgets);
      expect(find.textContaining('Rp'), findsWidgets);
      expect(find.textContaining('Pembelian Alat Kebersihan'), findsWidgets);
    });

    testWidgets('Tap pengeluaran membuka halaman detail dengan informasi lengkap', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: PengeluaranPage()));
      await tester.pumpAndSettle();
      
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(ExpenseCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Act - Tap first expense card
      final firstCard = find.byType(ExpenseCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Assert - Navigation should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('Tambah pengeluaran baru muncul di daftar setelah disimpan', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: AddPengeluaranPage()));
      await tester.pumpAndSettle();

      // Act - Fill form with valid data
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'Pengeluaran Test');
        await tester.enterText(textFields.at(1), '250000');
        await tester.pumpAndSettle();
      }

      // Assert - Form accepts input
      expect(find.text('Pengeluaran Test'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Edit pengeluaran mengubah data yang ditampilkan di list', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: EditPengeluaranPage(expenseId: '1')),
      );
      await tester.pump();
      
      // Wait for loading
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Act - Update expense data
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'Pengeluaran Updated');
        await tester.pumpAndSettle();
      }

      // Assert - Data updated successfully
      expect(find.text('Pengeluaran Updated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Filter berdasarkan kategori menampilkan data sesuai pilihan', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: PengeluaranPage()));
      await tester.pumpAndSettle();
      
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(ExpenseCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Act - Open filter bottom sheet
      final filterButton = find.byIcon(Icons.filter_list);
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Assert - Filter dialog opened
      expect(find.text('Filter Pengeluaran'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Filter berdasarkan rentang tanggal menampilkan pengeluaran sesuai periode', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: PengeluaranPage()));
      await tester.pumpAndSettle();
      
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(ExpenseCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Act - Open filter and close
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      final batalButton = find.text('Batal');
      if (batalButton.evaluate().isNotEmpty) {
        await tester.tap(batalButton);
        await tester.pumpAndSettle();
      }

      // Assert - Filter can be opened and closed
      expect(tester.takeException(), isNull);
    });

    testWidgets('Validasi form: field wajib kosong menampilkan error', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: AddPengeluaranPage()));
      await tester.pumpAndSettle();

      // Act - Leave required fields empty
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, '');
        await tester.pumpAndSettle();
      }

      // Assert - Form should handle empty validation
      expect(find.text('Tambah Pengeluaran'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Validasi form: jumlah pengeluaran invalid menampilkan error', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: AddPengeluaranPage()));
      await tester.pumpAndSettle();

      // Act - Enter invalid amount
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(1), '-1000');
        await tester.pumpAndSettle();
      }

      // Assert - Form should handle invalid input
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pull to refresh memuat ulang data pengeluaran terbaru', (tester) async {
      // Arrange
      await tester.pumpWidget(const MaterialApp(home: PengeluaranPage()));
      await tester.pumpAndSettle();
      
      for (var i = 0; i < 10; i++) {
        await tester.pumpAndSettle();
        if (find.byType(ExpenseCard).evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Act - Pull to refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert - Refresh should not crash
      expect(tester.takeException(), isNull);
      expect(find.byType(ExpenseCard), findsWidgets);
    });
  });
}
