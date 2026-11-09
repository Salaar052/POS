import 'package:flutter/material.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/app/theme/app_colors.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  final String title;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  static String titleForPath(String path) {
    if (path == '/' || path.isEmpty) {
      return 'Dashboard';
    }
    for (final dest in appNavDestinations) {
      if (path == dest.path || path.startsWith('${dest.path}/')) {
        return dest.label;
      }
    }
    return 'Pak POS';
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Material(
      color: theme.appBarTheme.backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Row(
              children: [
                if (showMenuButton) ...[
                  IconButton(
                    tooltip: 'Open navigation',
                    onPressed: onMenuPressed,
                    icon: const Icon(Icons.menu),
                  ),
                ] else
                  const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: theme.appBarTheme.titleTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
