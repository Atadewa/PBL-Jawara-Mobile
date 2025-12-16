import 'package:flutter/material.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final dynamic value;
  final String borderColor;
  final IconData icon;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.borderColor,
    required this.icon,
  });

  Color _parseHexColor(String hexColor) {
    try {
      var hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
      return const Color(0xFF10B981);
    } catch (e) {
      return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(borderColor);
    final displayValue = value == null ? '' : value.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 3.26, color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: color.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            displayValue,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
