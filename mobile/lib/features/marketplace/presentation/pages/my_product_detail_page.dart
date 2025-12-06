import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'edit_product_page.dart';

/// Halaman detail produk milik user (seller view)
class MyProductDetailPage extends StatefulWidget {
  final String productId;

  const MyProductDetailPage({super.key, required this.productId});

  @override
  State<MyProductDetailPage> createState() => _MyProductDetailPageState();
}

class _MyProductDetailPageState extends State<MyProductDetailPage> {
  final MarketplaceRepository _repository = MarketplaceRepository();

  ProductModel? _product;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final product = await _repository.getProductById(widget.productId);

      if (!mounted) return;

      setState(() {
        _product = product;
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
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.success),
            )
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _product == null
          ? const Center(child: Text('Produk tidak ditemukan'))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(),
                      const SizedBox(height: 16),
                      _buildDescription(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.success,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.background, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          _product!.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.borderMuted,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tidak ada gambar',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _product!.category,
              style: const TextStyle(
                color: AppColors.successDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Product Name
          Text(
            _product!.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Price
          Text(
            _formatCurrency(_product!.price),
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Stock Info
          Row(
            children: [
              Icon(
                _product!.stock > 0 ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: _product!.stock > 0
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                _product!.stock > 0
                    ? 'Stok tersedia: ${_product!.stock} pcs'
                    : 'Stok habis',
                style: TextStyle(
                  color: _product!.stock > 0
                      ? AppColors.successDark
                      : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _product!.description,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Edit Button
          InkWell(
            onTap: _handleEdit,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.edit, color: AppColors.info, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Produk',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.borderMuted),

          // Delete Button
          InkWell(
            onTap: _handleDelete,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.delete, color: AppColors.error, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hapus Produk',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(product: _product!),
      ),
    );
    if (result == true) {
      _loadProduct();
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${_product!.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _repository.deleteProduct(_product!.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Pop twice: dialog and detail page
                  Navigator.pop(context, true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus produk: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.background,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
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

