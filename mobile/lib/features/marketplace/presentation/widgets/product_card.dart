import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../pages/product_detail_page.dart';
import 'package:intl/intl.dart';

/// Card untuk menampilkan produk di list/grid
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing
        final isSmallCard = constraints.maxWidth < 150;
        final cardPadding = isSmallCard ? 8.0 : 12.0;
        final categoryFontSize = isSmallCard ? 9.0 : 10.0;
        final titleFontSize = isSmallCard ? 13.0 : 15.0;
        final sellerFontSize = isSmallCard ? 10.0 : 11.0;
        final priceFontSize = isSmallCard ? 12.0 : 14.0;
        final stockFontSize = isSmallCard ? 8.0 : 9.0;

        return GestureDetector(
          onTap:
              onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(productId: product.id),
                  ),
                );
              },
          child: Container(
            key: Key('product_card_${product.id}'),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image - memenuhi area dengan BoxFit.cover
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.borderMuted,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: isSmallCard ? 32 : 48,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: isSmallCard ? 4 : 8),
                                Text(
                                  'Tidak ada gambar',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: isSmallCard ? 9 : 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: AppColors.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.success,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallCard ? 6 : 8,
                          vertical: isSmallCard ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.successDark,
                            fontSize: categoryFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallCard ? 4 : 6),

                      // Product Title/Name
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isSmallCard ? 4 : 6),

                      // Seller Name - format: "Penjual: {sellerName}"
                      if (product.sellerName.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: isSmallCard ? 10 : 12,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Penjual: ${product.sellerName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: sellerFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (product.sellerName.isNotEmpty)
                        SizedBox(height: isSmallCard ? 4 : 8),

                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              _formatCurrency(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallCard ? 4 : 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: product.stock > 0
                                    ? AppColors.successSurfaceAlt
                                    : AppColors.errorSurface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Stok: ${product.stock}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: product.stock > 0
                                      ? AppColors.successDark
                                      : AppColors.errorDark,
                                  fontSize: stockFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

