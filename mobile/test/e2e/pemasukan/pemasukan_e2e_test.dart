
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/pemasukan/pages/income_page.dart';
import 'package:mobile/features/pemasukan/widgets/income_item.dart';

/// Helper: buka halaman Pemasukan (IncomePage) tanpa login/network.
Future<void> _openIncomePage(WidgetTester tester) async {
	await tester.pumpWidget(
		MaterialApp(
			home: IncomePage(),
		),
	);
	await tester.pumpAndSettle();
}

/// Helper: dari IncomePage, buka halaman Tambah Pemasukan.
Future<void> _openAddIncomeFromIncomePage(WidgetTester tester) async {
	await tester.tap(find.text('Tambah Pemasukan'));
	await tester.pumpAndSettle();
	expect(find.text('Tambah Pemasukan'), findsWidgets);
}

/// Helper: tap back icon jika ada.
Future<void> _tapBackIfPresent(WidgetTester tester) async {
	final back = find.byIcon(Icons.arrow_back);
	if (back.evaluate().isNotEmpty) {
		await tester.tap(back.first);
		await tester.pumpAndSettle();
	}
}

/// Helper: tap tombol Simpan Pemasukan (scroll jika perlu).
Future<void> _tapSaveIncome(WidgetTester tester) async {
	final save = find.text('Simpan Pemasukan');
	expect(save, findsOneWidget);
	await tester.ensureVisible(save);
	await tester.tap(save);
	await tester.pumpAndSettle();
}

void main() {
	group('Pemasukan E2E Tests', () {
		testWidgets('renders IncomePage with list items and add button', (tester) async {
			// Skenario: User membuka halaman Pemasukan dan memastikan elemen utama tampil
			// (judul, tombol tambah, dan list pemasukan).
			await _openIncomePage(tester);

			expect(find.text('Pemasukan'), findsOneWidget);
			expect(find.text('Tambah Pemasukan'), findsOneWidget);
			expect(find.byType(IncomeItem), findsWidgets);
			expect(tester.takeException(), isNull);
		});

		testWidgets('tap income item navigates to IncomeDetailsPage', (tester) async {
			// Skenario: User menekan salah satu item pemasukan pada list, lalu diarahkan
			// ke halaman Detail Pemasukan dan informasi penting tampil.
			await _openIncomePage(tester);

			// Tap item pertama (dari dummy list di IncomePage).
			final firstItem = find.byType(IncomeItem).first;
			await tester.ensureVisible(firstItem);
			await tester.tap(firstItem);
			await tester.pumpAndSettle();

			// Assert halaman detail terbuka.
			expect(find.text('Detail Pemasukan'), findsOneWidget);
			expect(find.text('Nama Pemasukan'), findsOneWidget);
			expect(find.text('Kategori'), findsOneWidget);
			expect(find.text('Nominal'), findsOneWidget);
			expect(find.text('Tanggal'), findsOneWidget);
			expect(find.text('Bukti Pemasukan'), findsOneWidget);
			expect(find.text('Edit Pemasukan'), findsOneWidget);

			// Data dari item dummy pertama.
			expect(find.text('Donasi HUT RI dari Pemda'), findsOneWidget);
			expect(find.text('Rp 5.000.000'), findsOneWidget);

			// Kembali tidak crash.
			await _tapBackIfPresent(tester);
			expect(find.text('Pemasukan'), findsOneWidget);
			expect(tester.takeException(), isNull);
		});

		testWidgets('add income flow: add -> saved -> appears in list -> detail shows description',
				(tester) async {
			// Skenario: User menambahkan pemasukan baru via form Tambah Pemasukan,
			// menekan Simpan, item baru muncul di list, lalu dibuka detailnya dan
			// field Deskripsi tampil sesuai input.
			await _openIncomePage(tester);

			// Buka halaman tambah pemasukan.
			await _openAddIncomeFromIncomePage(tester);

			// Isi form. Karena tidak ada Key, gunakan urutan TextFormField.
			// Urutan di AddIncomePage:
			// 0 = Nama Pemasukan, 1 = Tanggal (readOnly), 2 = Nominal, 3 = Deskripsi
			final fields = find.byType(TextFormField);
			expect(fields, findsNWidgets(4));

			const newTitle = 'Pemasukan Test E2E';
			const newAmount = '12345';
			const newDescription = 'Deskripsi pemasukan untuk pengujian E2E.';

			await tester.enterText(fields.at(0), newTitle);
			await tester.enterText(fields.at(2), newAmount);
			await tester.enterText(fields.at(3), newDescription);
			await tester.pumpAndSettle();

			// Simpan.
			await _tapSaveIncome(tester);

			// Kembali ke IncomePage dan item baru muncul.
			expect(find.text('Pemasukan'), findsOneWidget);
			expect(find.text(newTitle), findsOneWidget);

			// Buka detail item baru.
			await tester.ensureVisible(find.text(newTitle));
			await tester.tap(find.text(newTitle));
			await tester.pumpAndSettle();

			expect(find.text('Detail Pemasukan'), findsOneWidget);
			expect(find.text(newTitle), findsOneWidget);
			expect(find.text('Rp $newAmount'), findsOneWidget);
			expect(find.text('Deskripsi'), findsOneWidget);
			expect(find.text(newDescription), findsOneWidget);
			expect(tester.takeException(), isNull);
		});

		testWidgets('add income form shows validation errors when required fields empty',
				(tester) async {
			// Skenario: User membuka form tambah pemasukan lalu langsung menekan Simpan
			// tanpa mengisi field wajib -> muncul pesan validasi "Wajib diisi".
			await _openIncomePage(tester);
			await _openAddIncomeFromIncomePage(tester);

			await _tapSaveIncome(tester);

			// Validator untuk Nama Pemasukan dan Nominal.
			expect(find.text('Wajib diisi'), findsNWidgets(2));
			expect(tester.takeException(), isNull);
		});

		testWidgets('description is optional: when empty, detail page hides Deskripsi section',
				(tester) async {
			// Skenario: User menambahkan pemasukan tanpa mengisi Deskripsi.
			// Setelah membuka detail, section "Deskripsi" tidak ditampilkan.
			await _openIncomePage(tester);
			await _openAddIncomeFromIncomePage(tester);

			final fields = find.byType(TextFormField);
			expect(fields, findsNWidgets(4));

			const newTitle = 'Pemasukan Tanpa Deskripsi';
			const newAmount = '999';

			await tester.enterText(fields.at(0), newTitle);
			await tester.enterText(fields.at(2), newAmount);
			// Deskripsi (fields.at(3)) sengaja dibiarkan kosong.

			await _tapSaveIncome(tester);

			// Item baru muncul di list.
			expect(find.text(newTitle), findsOneWidget);

			// Masuk ke detail item tsb.
			await tester.ensureVisible(find.text(newTitle));
			await tester.tap(find.text(newTitle));
			await tester.pumpAndSettle();

			expect(find.text('Detail Pemasukan'), findsOneWidget);
			expect(find.text(newTitle), findsOneWidget);
			expect(find.text('Rp $newAmount'), findsOneWidget);

			// Karena description null/empty, label "Deskripsi" tidak ditampilkan.
			expect(find.text('Deskripsi'), findsNothing);
			expect(tester.takeException(), isNull);
		});

		testWidgets('selecting a different category is reflected on details page',
				(tester) async {
			// Skenario: User memilih kategori berbeda saat menambah pemasukan.
			// Setelah disimpan dan dibuka detail, kategori yang dipilih tampil.
			await _openIncomePage(tester);
			await _openAddIncomeFromIncomePage(tester);

			// Pilih kategori via dropdown.
			await tester.tap(find.byType(DropdownButtonFormField<String>));
			await tester.pumpAndSettle();
			await tester.tap(find.text('Hasil Usaha Kampung').last);
			await tester.pumpAndSettle();

			final fields = find.byType(TextFormField);
			expect(fields, findsNWidgets(4));

			const newTitle = 'Pemasukan Kategori Test';
			const newAmount = '5000';
			await tester.enterText(fields.at(0), newTitle);
			await tester.enterText(fields.at(2), newAmount);

			await _tapSaveIncome(tester);

			// Buka detail item baru dan cek kategori.
			await tester.ensureVisible(find.text(newTitle));
			await tester.tap(find.text(newTitle));
			await tester.pumpAndSettle();

			expect(find.text('Hasil Usaha Kampung'), findsOneWidget);
			expect(tester.takeException(), isNull);
		});

		testWidgets('newly added income appears at the top of the list', (tester) async {
			// Skenario: Setelah user menambahkan pemasukan baru, item tersebut masuk
			// ke urutan paling atas list (insert(0, newIncome)).
			await _openIncomePage(tester);

			// Tambah pemasukan pertama.
			await _openAddIncomeFromIncomePage(tester);
			var fields = find.byType(TextFormField);
			expect(fields, findsNWidgets(4));
			const firstTitle = 'Pemasukan Pertama';
			await tester.enterText(fields.at(0), firstTitle);
			await tester.enterText(fields.at(2), '1');
			await _tapSaveIncome(tester);

			// Tambah pemasukan kedua.
			await _openAddIncomeFromIncomePage(tester);
			fields = find.byType(TextFormField);
			const secondTitle = 'Pemasukan Kedua';
			await tester.enterText(fields.at(0), secondTitle);
			await tester.enterText(fields.at(2), '2');
			await _tapSaveIncome(tester);

			// Keduanya tampil.
			await tester.ensureVisible(find.text(secondTitle));
			await tester.ensureVisible(find.text(firstTitle));
			expect(find.text(firstTitle), findsOneWidget);
			expect(find.text(secondTitle), findsOneWidget);

			// Secara visual, item kedua harus lebih atas (posisi y lebih kecil).
			final firstPos = tester.getTopLeft(find.text(firstTitle));
			final secondPos = tester.getTopLeft(find.text(secondTitle));
			expect(secondPos.dy, lessThan(firstPos.dy));
			expect(tester.takeException(), isNull);
		});
	});
}

