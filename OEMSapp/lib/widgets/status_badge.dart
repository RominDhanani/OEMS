import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = status.trim().isEmpty ? 'PROCESSING' : status;
    final statusInfo = _getStatusInfo(effectiveStatus, context);
    final effectiveFontSize = fontSize ?? 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo.color.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(statusInfo.icon, size: effectiveFontSize + 2, color: statusInfo.color),
            const SizedBox(width: 4),
          ],
          Text(
            statusInfo.label,
            style: GoogleFonts.outfit(
              color: statusInfo.color,
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static _StatusInfo _getStatusInfo(String status, BuildContext context) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'PENDING_APPROVAL':
      case 'CREATED':
        return _StatusInfo(
          color: const Color(0xFFF59E0B),
          icon: Icons.schedule,
          label: 'PENDING',
        );
      case 'PROCESSING':
        return _StatusInfo(
          color: const Color(0xFF8B5CF6), // Purple
          icon: Icons.sync,
          label: 'PROCESSING',
        );
      case 'EXPANSION_REQUESTED':
        return _StatusInfo(
          color: const Color(0xFF8B5CF6), // Purple
          icon: Icons.expand_circle_down,
          label: 'EXPANSION',
        );
      case 'APPROVED':
      case 'RECEIPT_APPROVED':
      case 'ACTIVE':
        return _StatusInfo(
          color: const Color(0xFF10B981), // Emerald
          icon: Icons.check_circle,
          label: status.replaceAll('_', ' '),
        );
      case 'COMPLETED':
        return _StatusInfo(
          color: const Color(0xFF0D9488), // Teal
          icon: Icons.verified,
          label: 'COMPLETED',
        );
      case 'FUND_ALLOCATED':
      case 'EXPANSION_ALLOCATED':
      case 'ALLOCATED':
      case 'ASSIGNED':
        return _StatusInfo(
          color: const Color(0xFF6366F1), // Indigo
          icon: Icons.account_balance_wallet,
          label: status.replaceAll('_', ' '),
        );
      case 'RECEIVED':
        return _StatusInfo(
          color: const Color(0xFF06B6D4), // Cyan
          icon: Icons.receipt_long,
          label: 'RECEIVED',
        );
      case 'REJECTED':
        return _StatusInfo(
          color: const Color(0xFFEF4444),
          icon: Icons.cancel,
          label: 'REJECTED',
        );
      case 'DEACTIVATED':
      case 'DEACTIVATE':
      case 'INACTIVE':
        return _StatusInfo(
          color: const Color(0xFF6B7280), // Gray
          icon: Icons.block,
          label: status.replaceAll('_', ' '),
        );
      case 'UNASSIGNED':
        return _StatusInfo(
          color: const Color(0xFF9CA3AF), // Light gray
          icon: Icons.person_off,
          label: 'UNASSIGNED',
        );
      default:
        return _StatusInfo(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
          icon: Icons.info_outline,
          label: status.replaceAll('_', ' ').toUpperCase(),
        );
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  _StatusInfo({required this.color, required this.icon, required this.label});
}

