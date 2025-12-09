import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/aspirasi/data/services/aspirasi_service.dart';
import 'package:mobile/features/aspirasi/presentation/pages/aspirasi_page.dart';
import 'package:mobile/features/aspirasi/presentation/widgets/aspirasi_card.dart';
import 'package:flutter/material.dart';

Future<void> _openAspirasiPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: AspirasiPage(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _switchToTab(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openFirstAspirasiDetail(WidgetTester tester) async {
  final cards = find.byType(AspirasiCard);
  expect(cards, findsWidgets);
  final card = cards.first;
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

Future<void> _fillAspirasiForm(
  WidgetTester tester, {
  required String title,
  required String description,
}) async {
  await tester.enterText(find.byKey(const Key('aspirasi_form_title')), title);
  await tester.enterText(find.byKey(const Key('aspirasi_form_description')), description);
  await tester.ensureVisible(find.byKey(const Key('aspirasi_form_save')));
  await tester.tap(find.byKey(const Key('aspirasi_form_save')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AspirasiService.resetDummyData();
  });

  Future<void> _waitForAspirasiList(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pumpAndSettle();
      if (find.byType(AspirasiCard).evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(AspirasiCard), findsWidgets);
  }

  testWidgets('semua aspirasi tab shows list of aspirations', (tester) async {
    await _openAspirasiPage(tester);

    await _waitForAspirasiList(tester);
  });

  testWidgets('aspirasi saya tab shows only my aspirations', (tester) async {
    await _openAspirasiPage(tester);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_saya')));
    await _waitForAspirasiList(tester);

    expect(find.textContaining('Oleh: Budi'), findsWidgets);
    expect(find.textContaining('Oleh: Ahmad'), findsNothing);
  });

  testWidgets('creating a new aspirasi appears in both aspirasi saya and semua aspirasi', (tester) async {
    await _openAspirasiPage(tester);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_saya')));

    final title = 'Aspirasi Baru Test';
    final description = 'Deskripsi aspirasi baru untuk pengujian';
    await tester.tap(find.byKey(const Key('aspirasi_add_fab')));
    await tester.pumpAndSettle();
    await _fillAspirasiForm(tester, title: title, description: description);

    expect(find.text(title), findsOneWidget);

    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_semua')));
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('editing my aspirasi updates it in both tabs', (tester) async {
    await _openAspirasiPage(tester);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_saya')));

    await _openFirstAspirasiDetail(tester);
    await tester.tap(find.byKey(const Key('aspirasi_edit_button')));
    await tester.pumpAndSettle();

    const updatedTitle = 'Perbaikan Jalan RT 01 (Edited)';
    await _fillAspirasiForm(
      tester,
      title: updatedTitle,
      description: 'Perbaikan jalan dengan paving baru',
    );

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text(updatedTitle), findsOneWidget);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_semua')));
    expect(find.text(updatedTitle), findsOneWidget);
  });

  testWidgets('deleting my aspirasi removes it from both tabs', (tester) async {
    await _openAspirasiPage(tester);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_saya')));

    final title = 'Aspirasi Hapus Test';
    await tester.tap(find.byKey(const Key('aspirasi_add_fab')));
    await tester.pumpAndSettle();
    await _fillAspirasiForm(
      tester,
      title: title,
      description: 'Aspirasi yang akan dihapus',
    );

    final newCard = find.text(title);
    await tester.tap(newCard);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aspirasi_delete_button')));
    await tester.pumpAndSettle();

    expect(find.text(title), findsNothing);
    await _switchToTab(tester, find.byKey(const Key('aspirasi_tab_semua')));
    expect(find.text(title), findsNothing);
  });

  testWidgets('approving an aspirasi on semua aspirasi updates its status', (tester) async {
    await _openAspirasiPage(tester);

    await _openFirstAspirasiDetail(tester);
    await tester.tap(find.byKey(const Key('aspirasi_approve_button')));
    await tester.pumpAndSettle();

    expect(find.text('Diterima'), findsWidgets);
  });

  testWidgets('rejecting an aspirasi with a reason shows rejected status and reason', (tester) async {
    await _openAspirasiPage(tester);

    await _openFirstAspirasiDetail(tester);
    await tester.tap(find.byKey(const Key('aspirasi_reject_button')));
    await tester.pumpAndSettle();

    const reason = 'Tidak sesuai kriteria';
    await tester.enterText(find.byKey(const Key('aspirasi_reject_reason_field')), reason);
    await tester.tap(find.byKey(const Key('aspirasi_reject_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.text('Ditolak'), findsWidgets);
    expect(find.text(reason), findsOneWidget);
  });
}
