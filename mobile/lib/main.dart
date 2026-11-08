import 'package:flutter/material.dart';

void main() {
  runApp(const PosApp());
}

/// Phase 1 placeholder shell — no business logic.
class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pak POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Pak POS — offline-first billing (Phase 1)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
