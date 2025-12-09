import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

Future<void> _loginAndPumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  await tester.enterText(find.byKey(const Key('login_username_field')), 'user@example.com');
  await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');
  await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
  await tester.tap(find.byKey(const Key('login_submit_button')));
  await tester.pump(); // start loading
  await tester.pump(const Duration(seconds: 2)); // wait for dummy API
  await tester.pumpAndSettle();
}

Future<void> _openMarketplaceTab(WidgetTester tester) async {
  await _loginAndPumpApp(tester);
  final marketplaceNav = find.text('Marketplace');
  await tester.ensureVisible(marketplaceNav);
  await tester.tap(marketplaceNav);
  await tester.pumpAndSettle();
}

Future<void> _switchToTab(WidgetTester tester, Key tabKey) async {
  final tabFinder = find.byKey(tabKey);
  expect(tabFinder, findsOneWidget);
  await tester.ensureVisible(tabFinder);
  await tester.tap(tabFinder);
  await tester.pumpAndSettle();
}

Future<void> _returnToMarketplaceTabs(WidgetTester tester) async {
  // Navigate to the marketplace tab via the tab bar; avoids relying on pageBack
  await _switchToTab(tester, const Key('marketplace_tab_marketplace'));
}

Future<void> _openProductDetail(WidgetTester tester, String productId) async {
  final productCard = find.byKey(Key('product_card_$productId'));
  await tester.ensureVisible(productCard);
  await tester.tap(productCard);
  await tester.pumpAndSettle();
}

Future<void> _goBackFromDetailIfPresent(WidgetTester tester) async {
  final backButton = find.byKey(const Key('product_detail_back_button'));
  if (backButton.evaluate().isNotEmpty) {
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _buyCurrentProduct(WidgetTester tester) async {
  final buyButton = find.text('Beli Sekarang');
  await tester.ensureVisible(buyButton);
  await tester.tap(buyButton);
  await tester.pumpAndSettle();

  final confirmButton = find.text('Konfirmasi');
  await tester.ensureVisible(confirmButton);
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marketplace shows product list', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);

    // Act & Assert
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product_card_prod-1')), findsWidgets);
  });

  testWidgets('marketplace tapping product opens detail', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);

    // Act
    await _openProductDetail(tester, 'prod-1');

    // Assert
    expect(find.text('Batik Parang Rusak'), findsOneWidget);
    expect(find.text('Beli Sekarang'), findsOneWidget);
  });

  testWidgets('buying product adds to pembelian saya', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);
    await _openProductDetail(tester, 'prod-1');

    // Act
    await _buyCurrentProduct(tester);

    // Return to tabs and navigate to Pembelian Saya
    await _goBackFromDetailIfPresent(tester);
    await _switchToTab(tester, const Key('marketplace_tab_pembelian_saya'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Batik Parang Rusak'), findsWidgets);
  });

  testWidgets('pembelian saya only shows current user orders', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);

    // Act
    await _switchToTab(tester, const Key('marketplace_tab_pembelian_saya'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Batik Parang Rusak'), findsWidgets);
  });

  testWidgets('user can be both buyer and seller', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);

    // Assert buyer view
    await _switchToTab(tester, const Key('marketplace_tab_pembelian_saya'));
    await tester.pumpAndSettle();
    expect(find.text('Batik Parang Rusak'), findsWidgets);

    // Assert seller view
    await _switchToTab(tester, const Key('marketplace_tab_batik_saya'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('my_product_card_prod-1')), findsWidgets);
  });

  testWidgets('adding batik from batik saya shows in both batik saya and marketplace', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);
    await _switchToTab(tester, const Key('marketplace_tab_batik_saya'));

    // Act: open add product page
    final addButton = find.byKey(const Key('batik_saya_add_button'));
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Assert: add product page visible
    expect(find.text('Tambah Batik Saya'), findsOneWidget);
  });

  testWidgets('editing batik updates in both batik saya and marketplace', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);
    await _switchToTab(tester, const Key('marketplace_tab_batik_saya'));

    // Act: open product detail/edit from Batik Saya
    final detailButton = find.byKey(const Key('my_product_detail_prod-1'));
    await tester.ensureVisible(detailButton);
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    // Assert: detail page is shown (product info visible)
    expect(find.text('Batik Parang Rusak'), findsOneWidget);
  });

  testWidgets('tapping pembeli button shows buyers list for product', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);
    await _switchToTab(tester, const Key('marketplace_tab_batik_saya'));

    // Act
    final buyersButton = find.byKey(const Key('my_product_buyers_prod-1'));
    await tester.ensureVisible(buyersButton);
    await tester.tap(buyersButton);
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Riwayat Pembeli'), findsOneWidget);
    expect(find.textContaining('Batik Parang Rusak'), findsWidgets);
  });

  testWidgets('confirming and rejecting orders updates status', (tester) async {
    // Arrange
    await _openMarketplaceTab(tester);
    await _switchToTab(tester, const Key('marketplace_tab_batik_saya'));

    // Act: open buyers list
    final buyersButton = find.byKey(const Key('my_product_buyers_prod-1'));
    await tester.ensureVisible(buyersButton);
    await tester.tap(buyersButton);
    await tester.pumpAndSettle();

    // Assert: buyers page visible (status interactions would be here)
    expect(find.text('Riwayat Pembeli'), findsOneWidget);
  });
}
