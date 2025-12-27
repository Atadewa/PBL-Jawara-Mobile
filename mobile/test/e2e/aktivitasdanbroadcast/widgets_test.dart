import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/widgets/kegiatan_card.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/widgets/broadcast_card.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/models/kegiatan.dart';
import 'package:mobile/features/aktivitas_dan_broadcast/models/broadcast.dart';

/// E2E Test Suite untuk Widget Components Aktivitas & Broadcast
///
/// Test untuk KegiatanCard dan BroadcastCard widgets
void main() {
  // Disable Google Fonts untuk testing
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('KegiatanCard Widget Tests', () {
    /// =========================================
    /// TC01: KegiatanCard Render
    /// =========================================
    testWidgets('TC01 - KegiatanCard berhasil di-render', (tester) async {
      final kegiatan = _createMockKegiatan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify card rendered
      expect(find.byType(KegiatanCard), findsOneWidget);
    });

    /// =========================================
    /// TC02: KegiatanCard Title
    /// =========================================
    testWidgets('TC02 - KegiatanCard menampilkan title', (tester) async {
      final kegiatan = _createMockKegiatan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title displayed
      expect(find.text(kegiatan.title), findsOneWidget);
    });

    /// =========================================
    /// TC03: KegiatanCard Category Badge
    /// =========================================
    testWidgets('TC03 - KegiatanCard menampilkan category badge', (
      tester,
    ) async {
      final kegiatan = _createMockKegiatan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify category displayed
      expect(find.text(kegiatan.category), findsOneWidget);
    });

    /// =========================================
    /// TC04: KegiatanCard Date
    /// =========================================
    testWidgets('TC04 - KegiatanCard menampilkan date', (tester) async {
      final kegiatan = _createMockKegiatan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify date displayed
      expect(find.text(kegiatan.date), findsOneWidget);
    });

    /// =========================================
    /// TC05: KegiatanCard Organizer
    /// =========================================
    testWidgets('TC05 - KegiatanCard menampilkan organizer', (tester) async {
      final kegiatan = _createMockKegiatan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify organizer displayed
      expect(find.text(kegiatan.organizer), findsOneWidget);
    });

    /// =========================================
    /// TC06: KegiatanCard OnTap Callback
    /// =========================================
    testWidgets('TC06 - KegiatanCard onTap callback dipanggil', (tester) async {
      final kegiatan = _createMockKegiatan();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KegiatanCard(kegiatan: kegiatan, onTap: () => tapped = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(KegiatanCard));
      await tester.pumpAndSettle();

      // Verify callback called
      expect(tapped, isTrue);
    });

    /// =========================================
    /// TC07: KegiatanCard More Options
    /// =========================================
    testWidgets('TC07 - KegiatanCard more options icon', (tester) async {
      final kegiatan = _createMockKegiatan();
      bool morePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KegiatanCard(
              kegiatan: kegiatan,
              onMoreTap: () => morePressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap more icon
      final moreIcon = find.byIcon(Icons.more_vert);
      if (moreIcon.evaluate().isNotEmpty) {
        await tester.tap(moreIcon);
        await tester.pumpAndSettle();
        expect(morePressed, isTrue);
      }
    });

    /// =========================================
    /// TC08: KegiatanCard Different Categories
    /// =========================================
    testWidgets('TC08 - KegiatanCard dengan berbagai kategori', (tester) async {
      final categories = ['Kebersihan', 'Perayaan', 'Rapat', 'Kesehatan'];

      for (final category in categories) {
        final kegiatan = Kegiatan(
          id: 'test_$category',
          title: 'Test $category',
          category: category,
          categoryColor: '#DBEAFE',
          categoryTextColor: '#1347E5',
          date: '1 Januari 2026',
          organizer: 'Tester',
          categoryIcon: 'test',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: KegiatanCard(kegiatan: kegiatan)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(category), findsOneWidget);
      }
    });
  });

  group('BroadcastCard Widget Tests', () {
    /// =========================================
    /// TC09: BroadcastCard Render
    /// =========================================
    testWidgets('TC09 - BroadcastCard berhasil di-render', (tester) async {
      final broadcast = _createMockBroadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify card rendered
      expect(find.byType(BroadcastCard), findsOneWidget);
    });

    /// =========================================
    /// TC10: BroadcastCard Title
    /// =========================================
    testWidgets('TC10 - BroadcastCard menampilkan title', (tester) async {
      final broadcast = _createMockBroadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title displayed
      expect(find.text(broadcast.title), findsOneWidget);
    });

    /// =========================================
    /// TC11: BroadcastCard Description
    /// =========================================
    testWidgets('TC11 - BroadcastCard menampilkan description', (tester) async {
      final broadcast = _createMockBroadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify description displayed (may be truncated)
      expect(
        find.textContaining(broadcast.description.substring(0, 10)),
        findsOneWidget,
      );
    });

    /// =========================================
    /// TC12: BroadcastCard Time Icon
    /// =========================================
    testWidgets('TC12 - BroadcastCard menampilkan time icon', (tester) async {
      final broadcast = _createMockBroadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify time icon displayed
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    /// =========================================
    /// TC13: BroadcastCard OnTap Callback
    /// =========================================
    testWidgets('TC13 - BroadcastCard onTap callback dipanggil', (
      tester,
    ) async {
      final broadcast = _createMockBroadcast();
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BroadcastCard(
              broadcast: broadcast,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(BroadcastCard));
      await tester.pumpAndSettle();

      // Verify callback called
      expect(tapped, isTrue);
    });

    /// =========================================
    /// TC14: BroadcastCard with CreatedBy
    /// =========================================
    testWidgets('TC14 - BroadcastCard menampilkan createdBy', (tester) async {
      final broadcast = Broadcast(
        id: 'test_001',
        title: 'Test Broadcast',
        description: 'Test description',
        createdAt: DateTime.now(),
        createdBy: 'Ketua RT',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify createdBy displayed
      expect(find.text('Ketua RT'), findsOneWidget);
    });

    /// =========================================
    /// TC15: BroadcastCard without CreatedBy
    /// =========================================
    testWidgets('TC15 - BroadcastCard tanpa createdBy', (tester) async {
      final broadcast = Broadcast(
        id: 'test_001',
        title: 'Test Broadcast',
        description: 'Test description',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BroadcastCard(broadcast: broadcast)),
        ),
      );
      await tester.pumpAndSettle();

      // Card should still render without createdBy
      expect(find.byType(BroadcastCard), findsOneWidget);
    });
  });

  group('Card List Integration Tests', () {
    /// =========================================
    /// TC16: Multiple KegiatanCards in ListView
    /// =========================================
    testWidgets('TC16 - Multiple KegiatanCards dalam ListView', (tester) async {
      final kegiatanList = [
        _createMockKegiatan(id: '1', title: 'Kegiatan 1'),
        _createMockKegiatan(id: '2', title: 'Kegiatan 2'),
        _createMockKegiatan(id: '3', title: 'Kegiatan 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: kegiatanList.length,
              itemBuilder: (context, index) {
                return KegiatanCard(kegiatan: kegiatanList[index]);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all cards rendered
      expect(find.byType(KegiatanCard), findsNWidgets(3));
    });

    /// =========================================
    /// TC17: Multiple BroadcastCards in ListView
    /// =========================================
    testWidgets('TC17 - Multiple BroadcastCards dalam ListView', (
      tester,
    ) async {
      final broadcastList = [
        _createMockBroadcast(id: '1', title: 'Broadcast 1'),
        _createMockBroadcast(id: '2', title: 'Broadcast 2'),
        _createMockBroadcast(id: '3', title: 'Broadcast 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: broadcastList.length,
              itemBuilder: (context, index) {
                return BroadcastCard(broadcast: broadcastList[index]);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all cards rendered
      expect(find.byType(BroadcastCard), findsNWidgets(3));
    });

    /// =========================================
    /// TC18: Scroll Through Cards
    /// =========================================
    testWidgets('TC18 - Scroll melalui list cards', (tester) async {
      final kegiatanList = List.generate(
        10,
        (index) => _createMockKegiatan(id: '$index', title: 'Kegiatan $index'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: kegiatanList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: KegiatanCard(kegiatan: kegiatanList[index]),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Cards should still be visible after scroll
      expect(find.byType(KegiatanCard), findsWidgets);
    });
  });
}

// ==================== MOCK DATA HELPERS ====================

Kegiatan _createMockKegiatan({
  String id = 'kegiatan_001',
  String title = 'Gotong Royong Bulanan',
}) {
  return Kegiatan(
    id: id,
    title: title,
    category: 'Kebersihan',
    categoryColor: '#DBEAFE',
    categoryTextColor: '#1347E5',
    date: '28 November 2025',
    organizer: 'Bapak Ahmad',
    categoryIcon: 'cleaning',
  );
}

Broadcast _createMockBroadcast({
  String id = 'broadcast_001',
  String title = 'Pengumuman Iuran Bulanan',
}) {
  return Broadcast(
    id: id,
    title: title,
    description:
        'Kepada seluruh warga RT 01/RW 05, dimohon untuk membayar iuran bulanan.',
    createdAt: DateTime(2025, 11, 20),
    createdBy: 'Ketua RT',
  );
}
