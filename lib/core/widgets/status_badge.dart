import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Colored status badge/chip.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bgColor;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.bgColor,
    this.fontSize = 11,
  });

  /// Factory constructors for common statuses.
  factory StatusBadge.active() => const StatusBadge(
        label: 'Active',
        color: AppColors.success,
        bgColor: AppColors.successLight,
      );

  factory StatusBadge.inactive() => StatusBadge(
        label: 'Inactive',
        color: AppColors.textTertiary,
        bgColor: AppColors.surfaceAlt,
      );

  factory StatusBadge.pending() => const StatusBadge(
        label: 'Pending',
        color: AppColors.warning,
        bgColor: AppColors.warningLight,
      );

  factory StatusBadge.completed() => const StatusBadge(
        label: 'Completed',
        color: AppColors.success,
        bgColor: AppColors.successLight,
      );

  factory StatusBadge.cancelled() => const StatusBadge(
        label: 'Cancelled',
        color: AppColors.error,
        bgColor: AppColors.errorLight,
      );

  factory StatusBadge.scheduled() => const StatusBadge(
        label: 'Scheduled',
        color: AppColors.info,
        bgColor: AppColors.infoLight,
      );

  factory StatusBadge.custom(String label, Color color, Color bg) =>
      StatusBadge(label: label, color: color, bgColor: bg);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final bg = bgColor ?? AppColors.primarySurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: c,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
