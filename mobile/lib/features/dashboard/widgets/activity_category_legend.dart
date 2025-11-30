import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivityCategoryLegend extends StatelessWidget {
  final List<ActivityCategory> categories;

  const ActivityCategoryLegend({Key? key, required this.categories})
    : super(key: key);

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.startsWith('0xFF')) {
      return Color(int.parse(hexColor));
    }
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(categories.length, (index) {
        final category = categories[index];
        final color = _getColorFromHex(category.color);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
                fontFamily: 'Arimo',
              ),
            ),
          ],
        );
      }),
    );
  }
}
