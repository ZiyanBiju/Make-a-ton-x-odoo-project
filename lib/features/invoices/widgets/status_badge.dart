import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case 'posted':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        icon = Icons.send_outlined;
        break;
      case 'cancelled':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        icon = Icons.cancel_outlined;
        break;
      case 'draft':
      default:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        icon = Icons.edit_note_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
