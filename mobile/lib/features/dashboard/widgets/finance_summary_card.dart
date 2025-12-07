import 'package:flutter/material.dart';

class FinanceSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const FinanceSummaryCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconContainerSize = constraints.maxWidth * 0.4;
        final iconSize = iconContainerSize * 0.5;
        final valueFontSize = constraints.maxWidth * 0.18;
        final labelFontSize = constraints.maxWidth * 0.12;
        final padding = constraints.maxWidth * 0.12;

        return Container(
          padding: EdgeInsets.all(padding.clamp(10.0, 16.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(top: BorderSide(color: color, width: 3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconContainerSize.clamp(36.0, 48.0),
                height: iconContainerSize.clamp(36.0, 48.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize.clamp(18.0, 24.0),
                ),
              ),
              SizedBox(height: padding.clamp(8.0, 12.0)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize.clamp(16.0, 22.0),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Arimo',
                  ),
                ),
              ),
              SizedBox(height: (padding * 0.3).clamp(2.0, 4.0)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize.clamp(10.0, 13.0),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
