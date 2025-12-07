import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

import '../../data/models/aspirasi_model.dart';

class AspirasiStatusChip extends StatelessWidget {
  const AspirasiStatusChip({
    super.key,
    required this.status,
    this.compact = true,
  });

  final AspirasiStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final background = _backgroundColor(status);
    final textColor = _textColor(status);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 8);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: compact ? 12 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _backgroundColor(AspirasiStatus status) => switch (status) {
        AspirasiStatus.pending => AppColors.warningSurface,
        AspirasiStatus.diterima => AppColors.successSurface,
        AspirasiStatus.ditolak => AppColors.errorSurface,
      };

  Color _textColor(AspirasiStatus status) => switch (status) {
        AspirasiStatus.pending => AppColors.warningDark,
        AspirasiStatus.diterima => AppColors.successDark,
        AspirasiStatus.ditolak => AppColors.errorDark,
      };
}
