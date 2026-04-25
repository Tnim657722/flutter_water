import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        bg = AppColors.warning.withValues(alpha: 0.12);
        icon = Icons.schedule;
        break;
      case 'assigned':
        color = AppColors.primary;
        bg = AppColors.primary.withValues(alpha: 0.1);
        icon = Icons.assignment_turned_in;
        break;
      case 'delivering':
        color = AppColors.accent;
        bg = AppColors.accent.withValues(alpha: 0.12);
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.12);
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        color = AppColors.danger;
        bg = AppColors.danger.withValues(alpha: 0.12);
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textSecondary;
        bg = Colors.grey.withValues(alpha: 0.1);
        icon = Icons.help_outline;
    }

    final dummy = OrderModel(
      id: '',
      orderNumber: '',
      customerId: '',
      customerName: '',
      status: status,
      totalAmount: 0,
      deliveryAddress: '',
      deliveryDate: DateTime.now(),
      items: const [],
      createdAt: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            dummy.statusLabel,
            style: GoogleFonts.kanit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
