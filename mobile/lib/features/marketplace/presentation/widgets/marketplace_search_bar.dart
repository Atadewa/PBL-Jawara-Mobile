import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Search bar untuk marketplace
class MarketplaceSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const MarketplaceSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Cari produk batik...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderMuted, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            Container(width: 1, height: 24, color: AppColors.borderMuted),
            InkWell(
              onTap: onFilterTap,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ] else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

