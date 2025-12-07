import 'package:flutter/material.dart';
import '../models/population_model.dart';
import 'population_chart_legend.dart';

class PopulationChartCard extends StatelessWidget {
  final PopulationAnalysis analysis;
  final bool showPieChart;

  const PopulationChartCard({
    super.key,
    required this.analysis,
    this.showPieChart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            analysis.categoryTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // Chart placeholder (for actual chart implementation)
          if (showPieChart)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Chart visualization would go here\n(Use fl_chart or syncfusion_flutter_charts)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Legend
          PopulationChartLegend(categories: analysis.data),
        ],
      ),
    );
  }
}
