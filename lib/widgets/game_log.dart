import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';

class GameLogWidget extends ConsumerStatefulWidget {
  const GameLogWidget({super.key});

  @override
  ConsumerState<GameLogWidget> createState() => _GameLogWidgetState();
}

class _GameLogWidgetState extends ConsumerState<GameLogWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logMessages = ref.watch(logMessagesProvider);

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Container(
      height: 120, // Fixed height as requested (100-150px range)
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light gray background
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Header
          Row(
            children: [
              Icon(Icons.history, color: Colors.brown.shade700, size: 14),
              const SizedBox(width: 6),
              Text(
                'Oyun Geçmişi',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Log messages with auto-scroll
          Expanded(
            child: logMessages.isEmpty
                ? Center(
                    child: Text(
                      'Henüz işlem yok',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: logMessages.length,
                    itemBuilder: (context, index) {
                      final message = logMessages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $message',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.brown.shade900,
                            height: 1.3,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
