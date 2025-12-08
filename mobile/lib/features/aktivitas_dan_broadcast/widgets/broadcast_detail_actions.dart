import 'package:flutter/material.dart';
import '../models/broadcast.dart';

/// Widget untuk menampilkan action buttons (Edit dan Delete)
class BroadcastDetailActions extends StatelessWidget {
  final Broadcast broadcast;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const BroadcastDetailActions({
    Key? key,
    required this.broadcast,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Edit button
        ElevatedButton(
          onPressed: onEditPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EE7B7),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Edit Broadcast',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Delete button
        OutlinedButton(
          onPressed: onDeletePressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFFC9C9), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete, size: 20, color: Color(0xFFFA2B36)),
              const SizedBox(width: 8),
              Text(
                'Hapus Broadcast',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFFA2B36),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
