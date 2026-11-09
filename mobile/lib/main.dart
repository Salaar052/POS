import 'package:flutter/material.dart';
import 'package:pos_mobile/app/app_database_scope.dart';
import 'package:pos_mobile/data/services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? databaseInitError;
  try {
    AppDatabaseScope.service = await DatabaseService.open();
  } catch (error) {
    databaseInitError = error.toString();
  }

  runApp(PosApp(databaseInitError: databaseInitError));
}

/// Phase 1 shell with Phase 2.1 local database bootstrap (no auto-provision).
class PosApp extends StatefulWidget {
  const PosApp({super.key, this.databaseInitError});

  final String? databaseInitError;

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  @override
  void dispose() {
    AppDatabaseScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbReady = widget.databaseInitError == null &&
        AppDatabaseScope.service != null;
    return MaterialApp(
      title: 'Pak POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              widget.databaseInitError != null
                  ? 'Local database failed to open.\n${widget.databaseInitError}'
                  : dbReady
                      ? 'Pak POS — offline-first billing (Phase 2)\n'
                          'Local database ready. Business not provisioned yet.'
                      : 'Pak POS — database unavailable.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
