import 'package:flutter/material.dart';

/// Header widget untuk broadcast detail page
/// Menampilkan back button dan title dengan gradient background
class BroadcastDetailHeader extends StatelessWidget {
  final VoidCallback onBackPressed;

  const BroadcastDetailHeader({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBackPressed,
                borderRadius: BorderRadius.circular(20),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          const Expanded(
            child: Text(
              'Detail Broadcast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
