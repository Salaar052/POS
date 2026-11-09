import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/router/app_routes.dart';

class MobileNavDrawer extends StatelessWidget {
  const MobileNavDrawer({super.key, required this.selectedPath});

  final String selectedPath;

  bool _selected(String path, String dest) {
    if (dest == AppRoutes.dashboard) {
      return path == '/' || path.isEmpty;
    }
    return path == dest;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 12),
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                children: [
                  for (final dest in appNavDestinations)
                    ListTile(
                      leading: Icon(
                        _selected(selectedPath, dest.path)
                            ? dest.selectedIcon
                            : dest.icon,
                      ),
                      title: Text(dest.label),
                      selected: _selected(selectedPath, dest.path),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(dest.path);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
