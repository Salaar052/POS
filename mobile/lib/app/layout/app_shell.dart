import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/layout/app_header.dart';
import 'package:pos_mobile/app/layout/desktop_sidebar.dart';
import 'package:pos_mobile/app/layout/mobile_navigation.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/shared/widgets/empty_business_banner.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final title = AppHeader.titleForPath(path);
    final businessAsync = ref.watch(businessProvisionStatusProvider);
    final showEmptyBanner = businessAsync.maybeWhen(
      data: (status) => !status.isProvisioned,
      orElse: () => false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;
        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                DesktopSidebar(selectedPath: path),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppHeader(title: title),
                      if (showEmptyBanner) const EmptyBusinessBanner(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(
                            AppSpacing.lg,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppHeader(
            title: title,
            showMenuButton: true,
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          drawer: MobileNavDrawer(selectedPath: path),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showEmptyBanner) const EmptyBusinessBanner(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
