// widgets/income_item.dart
import 'package:flutter/material.dart';
import '../models/income_model.dart';

class IncomeItem extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;

  const IncomeItem({required this.income, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 271.60,
        height: 180.44,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 23.40,
              top: 19.99,
              child: Row(
                children: [
                  Container(
                    width: 47.99,
                    height: 47.99,
                    decoration: ShapeDecoration(
                      color: const Color(0x196EE7B7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.monetization_on, size: 23.98),
                    ),
                  ),
                  SizedBox(width: 15.98),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          income.title,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 16,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: ShapeDecoration(
                          color: income.categoryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(57092600),
                          ),
                        ),
                        child: Text(
                          income.category,
                          style: TextStyle(
                            color: income.categoryTextColor,
                            fontSize: 11,
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        income.amount,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        income.date,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 16,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 78,
              child: Icon(Icons.arrow_forward, size: 23.98),
            ),
          ],
        ),
      ),
    );
  }
}
