import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/app_colors.dart';

import '../../data/models/aspirasi_model.dart';
import 'aspirasi_status_chip.dart';

class AspirasiCard extends StatelessWidget {
  const AspirasiCard({
    super.key,
    required this.aspirasi,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  final Aspirasi aspirasi;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');
    return InkWell(
      key: Key('aspirasi_card_${aspirasi.id}'),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderMuted, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(width: 4, color: Color(0xFF6EE7B7)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    aspirasi.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                AspirasiStatusChip(status: aspirasi.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aspirasi.description,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Oleh: ${aspirasi.creatorName ?? 'Warga'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '|',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        formatter.format(aspirasi.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  IconButton(
                    key: Key('aspirasi_card_edit_${aspirasi.id}'),
                    icon: const Icon(Icons.edit, size: 20),
                    color:
                        aspirasi.status == AspirationStatus.inProgress ||
                            aspirasi.status == AspirationStatus.resolved
                        ? AppColors.iconMuted
                        : AppColors.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed:
                        aspirasi.status == AspirationStatus.inProgress ||
                            aspirasi.status == AspirationStatus.resolved
                        ? null
                        : onEdit,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: Key('aspirasi_card_delete_${aspirasi.id}'),
                    icon: const Icon(Icons.delete, size: 20),
                    color:
                        aspirasi.status == AspirationStatus.inProgress ||
                            aspirasi.status == AspirationStatus.resolved
                        ? AppColors.iconMuted
                        : AppColors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed:
                        aspirasi.status == AspirationStatus.inProgress ||
                            aspirasi.status == AspirationStatus.resolved
                        ? null
                        : onDelete,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
