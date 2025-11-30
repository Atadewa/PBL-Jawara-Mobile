import 'package:flutter/material.dart';
import '../models/finance_model.dart';

class CategoryLegend extends StatelessWidget {
  final List<CategoryBreakdown> categories;
  final String title;

  const CategoryLegend({
    Key? key,
    required this.categories,
    required this.title,
  }) : super(key: key);

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.startsWith('0xFF')) {
      return Color(int.parse(hexColor));
    }
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  String _formatCurrency(String value) {
    final amount = int.tryParse(value) ?? 0;
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return amount.toString();
  }

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(categories.length, (index) {
              final category = categories[index];
              final color = _getColorFromHex(category.color);
              final amount = _formatCurrency(category.amount.toString());

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < categories.length - 1 ? 12 : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF34D399),
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
