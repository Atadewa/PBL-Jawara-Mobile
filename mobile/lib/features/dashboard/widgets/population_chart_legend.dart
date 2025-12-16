import 'package:flutter/material.dart';
import '../models/population_model.dart';

class PopulationChartLegend extends StatelessWidget {
  final List<PopulationCategory> categories;

  const PopulationChartLegend({super.key, required this.categories});

  Color _parseColor(String colorString) {
    try {
      return Color(
        int.parse(colorString.replaceFirst('0xFF', '0xFF'), radix: 16),
      );
    } catch (e) {
      return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split categories into 2 columns for better layout
    final midpoint = (categories.length + 1) ~/ 2;
    final col1 = categories.take(midpoint).toList();
    final col2 = categories.skip(midpoint).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col1.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: ShapeDecoration(
                        color: _parseColor(category.color),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${category.name}: ${category.count}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        // Column 2
        if (col2.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: col2.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: ShapeDecoration(
                          color: _parseColor(category.color),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${category.name}: ${category.count}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
