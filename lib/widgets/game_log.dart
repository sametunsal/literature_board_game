import 'package:flutter/material.dart';

class GameLog extends StatelessWidget {
  final List<String> logs;

  const GameLog({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    // Son 5 mesajı göster
    final displayLogs = logs.length > 5 ? logs.sublist(logs.length - 5) : logs;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayLogs
            .map(
              (log) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  "> $log",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
