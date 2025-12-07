import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/activity_log_item.dart';

class ActivityLogCard extends StatelessWidget {
  final ActivityLogItem activity;

  const ActivityLogCard({
    super.key,
    required this.activity,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            width: 3.74,
            color: const Color(0xFF6EE7B7),
          ),
        ),
        boxShadow: [
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
          // Role badge and date/time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x196EE7B7),
                  borderRadius: BorderRadius.circular(41877300),
                ),
                child: Text(
                  activity.role.displayName,
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 14,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ),
              // Date and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(activity.timestamp),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                  Text(
                    _formatTime(activity.timestamp),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            activity.description,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
              height: 1.62,
            ),
          ),
        ],
      ),
    );
  }
}
