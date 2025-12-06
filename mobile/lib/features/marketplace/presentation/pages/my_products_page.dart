import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../widgets/empty_state_widget.dart';
import 'add_product_page.dart';
import 'product_buyers_page.dart';
import 'my_product_detail_page.dart';
import 'package:intl/intl.dart';

/// Halaman produk milik user (seller view)
class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final MarketplaceRepository _repository = MarketplaceRepository();

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // TODO: Ganti dengan user ID yang sebenarnya dari auth
  final String _currentUserId = 'user-1';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await _repository.getMyProducts(_currentUserId);

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Tambah Batik Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductPage(),
                  ),
                );
                if (result == true) {
                  _loadProducts();
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: AppColors.background, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Batik Saya',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Products List
          Expanded(child: _buildProductsTab()),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.success),
      );
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Terjadi Kesalahan',
        message: _errorMessage!,
        actionText: 'Coba Lagi',
        onActionPressed: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'Belum Ada Produk',
        message: 'Mulai jual produk batik Anda sekarang!',
        actionText: 'Tambah Produk',
        onActionPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
          if (result == true) {
            _loadProducts();
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.success,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildProductCard(_products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(width: 1, color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Product Image and Info Row
          InkWell(
            onTap: () => _handleViewDetail(product),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: AppColors.successDark,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price
                        Text(
                          _formatCurrency(product.price),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Stock
                        Row(
                          children: [
                            Icon(
                              product.stock > 0
                                  ? Icons.inventory_2
                                  : Icons.warning_amber,
                              size: 14,
                              color: product.stock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Stok: ${product.stock}',
                              style: TextStyle(
                                color: product.stock > 0
                                    ? AppColors.textTertiary
                                    : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderMuted, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _handleViewDetail(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.info,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Detail',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.borderMuted),
                Expanded(
                  child: InkWell(
                    onTap: () => _handleViewBuyers(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 18,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Pembeli',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleViewDetail(ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyProductDetailPage(productId: product.id),
      ),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _handleViewBuyers(ProductModel product) {
    // Navigate to product buyers page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductBuyersPage(product: product),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

