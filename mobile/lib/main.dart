import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/app.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/shared/widgets/database_error_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RootBootstrapApp());
}

/// Opens the database before [runApp], then hosts [PakPosApp] or the error UI.
class RootBootstrapApp extends StatefulWidget {
  const RootBootstrapApp({super.key});

  @override
  State<RootBootstrapApp> createState() => _RootBootstrapAppState();
}

class _RootBootstrapAppState extends State<RootBootstrapApp> {
  ProviderContainer? _container;
  bool _bootstrapping = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    AppRuntime.containerRevision.addListener(_onRuntimeContainerChanged);
    _bootstrap();
  }

  void _onRuntimeContainerChanged() {
    final next = AppRuntime.container;
    if (!mounted || next == null) return;
    setState(() => _container = next);
  }

  @override
  void dispose() {
    AppRuntime.containerRevision.removeListener(_onRuntimeContainerChanged);
    unawaited(AppRuntime.shutdown());
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _bootstrapping = true;
      _failed = false;
      _container = null;
    });

    await AppRuntime.shutdown();

    try {
      final container = await AppRuntime.start();
      if (!mounted) {
        await AppRuntime.shutdown();
        return;
      }
      setState(() {
        _container = container;
        _bootstrapping = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bootstrapping = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_failed || _container == null) {
      return MaterialApp(home: DatabaseErrorPage(onRetry: _bootstrap));
    }

    return UncontrolledProviderScope(
      container: _container!,
      child: const PakPosApp(),
    );
  }
}
