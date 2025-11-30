import 'package:flutter/material.dart';

class ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;

  const ChartPlaceholder({Key? key, required this.title, this.height = 250})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            fontFamily: 'Arimo',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 48,
                  color: const Color(0xFF94A3B8).withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chart Placeholder',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF94A3B8).withOpacity(0.7),
                    fontFamily: 'Arimo',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ganti dengan fl_chart nantinya',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8).withOpacity(0.5),
                    fontFamily: 'Arimo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
