import 'package:flutter/material.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<ProfileInfoItem> items;

  const ProfileInfoSection({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE1E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x19000000),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE1E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0E162B),
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Info Items
          ...List.generate(
            items.length,
            (index) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: items[index].iconBackgroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            items[index].icon,
                            color: items[index].iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[index].label,
                              style: const TextStyle(
                                color: Color(0xFF61738D),
                                fontSize: 12,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              items[index].value,
                              style: const TextStyle(
                                color: Color(0xFF0E162B),
                                fontSize: 14,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
                if (index < items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      height: 1,
                      color: Color(0xFFE1E8F0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String value;

  ProfileInfoItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    required this.value,
  });
}