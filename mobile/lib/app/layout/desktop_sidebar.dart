import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/app/theme/app_colors.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.selectedPath,
  });

  final String selectedPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.slate900 : AppColors.slate50;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Material(
      color: bg,
      child: Container(
        width: AppSpacing.sidebarWidth,
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Text(
                'Pak POS',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                children: [
                  for (final dest in appNavDestinations)
                    _SidebarTile(
                      destination: dest,
                      selected: _isSelected(selectedPath, dest.path),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSelected(String current, String destPath) {
    if (destPath == AppRoutes.dashboard) {
      return current == '/' || current.isEmpty;
    }
    return current == destPath || current.startsWith('$destPath/');
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.destination,
    required this.selected,
  });

  final AppNavDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      child: ListTile(
        leading: Icon(
          selected ? destination.selectedIcon : destination.icon,
          size: 22,
        ),
        title: Text(destination.label),
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.12),
        selectedColor: colorScheme.primary,
        iconColor: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        onTap: () => context.go(destination.path),
      ),
    );
  }
}
