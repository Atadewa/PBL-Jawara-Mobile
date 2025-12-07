import 'package:flutter/material.dart';

class ActivityStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color borderColor;

  const ActivityStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available width
        final iconContainerSize = constraints.maxWidth * 0.4;
        final iconSize = iconContainerSize * 0.5;
        final fontSize = constraints.maxWidth * 0.14;
        final labelFontSize = constraints.maxWidth * 0.11;
        final padding = constraints.maxWidth * 0.12;
        final borderRadius = constraints.maxWidth * 0.15;
        final iconBorderRadius = constraints.maxWidth * 0.12;

        return Container(
          padding: EdgeInsets.all(padding.clamp(8.0, 20.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius.clamp(12.0, 16.0)),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 4),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconContainerSize.clamp(32.0, 48.0),
                height: iconContainerSize.clamp(32.0, 48.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    iconBorderRadius.clamp(8.0, 14.0),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize.clamp(16.0, 24.0),
                ),
              ),
              SizedBox(height: padding.clamp(6.0, 12.0)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize.clamp(14.0, 20.0),
                    fontWeight: FontWeight.w600,
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
                    fontSize: labelFontSize.clamp(10.0, 14.0),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                    fontFamily: 'Arimo',
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
