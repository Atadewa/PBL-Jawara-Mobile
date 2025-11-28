import 'package:flutter/material.dart';

class KategoriCard extends StatelessWidget {
  final String title;
  final String tag;
  final String price;

  const KategoriCard({
    super.key,
    required this.title,
    required this.tag,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),

                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const Icon(Icons.edit, color: Colors.teal)
        ],
      ),
    );
  }
}
