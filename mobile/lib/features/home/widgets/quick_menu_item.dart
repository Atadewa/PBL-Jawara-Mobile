import 'package:flutter/material.dart';

/// Menu item untuk quick access grid
class QuickMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const QuickMenuItem({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
