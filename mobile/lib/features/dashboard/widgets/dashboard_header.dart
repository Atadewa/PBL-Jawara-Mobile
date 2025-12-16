import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with back button and trailing
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Trailing widget (optional)
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            // Subtitle with padding to align with title
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xE5FFFEFE),
                  fontSize: 14,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
