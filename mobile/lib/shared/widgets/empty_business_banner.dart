import 'package:flutter/material.dart';
import 'package:pos_mobile/app/theme/app_colors.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

/// Shown when SQLite is ready but no business has been provisioned yet.
class EmptyBusinessBanner extends StatelessWidget {
  const EmptyBusinessBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.slate800.withValues(alpha: 0.9)
        : AppColors.warning.withValues(alpha: 0.12);
    final border = isDark
        ? AppColors.borderDark
        : AppColors.warning.withValues(alpha: 0.35);

    return Material(
      color: bg,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: isDark ? AppColors.warning : AppColors.slate700,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'No business is set up on this device yet. '
                'Complete onboarding to register your business.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.slate100 : AppColors.slate700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
