import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/layouts/main_layout.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state_widget.dart';
import 'my_products_page.dart';
import 'my_purchases_page.dart';

/// Halaman utama Marketplace
///
/// Menampilkan semua produk batik yang tersedia
class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage>
    with SingleTickerProviderStateMixin {
  final MarketplaceRepository _repository = MarketplaceRepository();
  late TabController _tabController;

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Semua';
  List<String> _categories = const ['Semua'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = ['Semua', ...categories];
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'Semua';
        }
      });
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await _repository.getProducts();

      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = products;
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

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Filter by category
        final matchesCategory =
            _selectedCategory == 'Semua' ||
            product.category == _selectedCategory;

        return matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 1,
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: Column(
          children: [
            // Header with gradient and tabs
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [AppColors.success, AppColors.success],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Marketplace Batik',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Jual dan beli produk batik warga',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.background,
                        indicatorWeight: 4,
                        labelColor: AppColors.background,
                        unselectedLabelColor:
                            AppColors.background.withValues(alpha: 0.6),
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(text: 'Marketplace'),
                          Tab(text: 'Batik Saya'),
                          Tab(text: 'Pembelian Saya'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMarketplaceTab(),
                  _buildMyProductsTab(),
                  _buildMyPurchasesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
          color: AppColors.cardBackground,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Categories chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return CategoryChip(
                      label: category,
                      isSelected: _selectedCategory == category,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          _filterProducts();
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Products Grid with responsive layout
              Expanded(child: _buildProductsContent(constraints)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsContent(BoxConstraints constraints) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.success),
      );
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Terjadi Kesalahan',
              message: _errorMessage!,
              actionText: 'Coba Lagi',
              onActionPressed: _loadProducts,
            ),
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: EmptyStateWidget(
              icon: Icons.search_off,
              title: 'Produk Tidak Ditemukan',
              message: 'Tidak ada produk yang sesuai dengan filter Anda',
              actionText: 'Reset Filter',
              onActionPressed: () {
                setState(() {
                  _selectedCategory = 'Semua';
                  _filterProducts();
                });
              },
            ),
          ),
        ),
      );
    }

    // Calculate responsive grid
    final screenWidth = constraints.maxWidth;
    int crossAxisCount;
    double childAspectRatio;
    double spacing;
    double padding;

    if (screenWidth >= 1200) {
      // Desktop/Large tablet landscape
      crossAxisCount = 4;
      childAspectRatio = 0.75;
      spacing = 20;
      padding = 24;
    } else if (screenWidth >= 900) {
      // Tablet landscape
      crossAxisCount = 3;
      childAspectRatio = 0.72;
      spacing = 16;
      padding = 20;
    } else if (screenWidth >= 600) {
      // Tablet portrait
      crossAxisCount = 3;
      childAspectRatio = 0.70;
      spacing = 12;
      padding = 16;
    } else if (screenWidth >= 400) {
      // Large phone
      crossAxisCount = 2;
      childAspectRatio = 0.72;
      spacing = 12;
      padding = 16;
    } else {
      // Small phone
      crossAxisCount = 2;
      childAspectRatio = 0.68;
      spacing = 8;
      padding = 12;
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.success,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return ProductCard(product: _filteredProducts[index]);
              }, childCount: _filteredProducts.length),
            ),
          ),
          // Bottom padding for better scroll experience
          SliverPadding(padding: EdgeInsets.only(bottom: padding)),
        ],
      ),
    );
  }

  Widget _buildMyProductsTab() {
    return const MyProductsPage();
  }

  Widget _buildMyPurchasesTab() {
    return const MyPurchasesPage();
  }
}
