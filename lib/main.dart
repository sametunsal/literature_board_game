import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/board_view.dart';
import 'widgets/setup_screen.dart'; // Yeni import
import 'models/game_enums.dart'; // Yeni import
import 'providers/game_notifier.dart'; // Yeni import

void main() {
  runApp(const ProviderScope(child: EdebiyatOyunuApp()));
}

class EdebiyatOyunuApp extends StatelessWidget {
  const EdebiyatOyunuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edebiyat Macera',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const BoardView(),
    );
  }
}
