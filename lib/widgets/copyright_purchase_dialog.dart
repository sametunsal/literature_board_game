import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_tile.dart';
import '../providers/game_notifier.dart';

class CopyrightPurchaseDialog extends ConsumerWidget {
  final BoardTile tile;
  const CopyrightPurchaseDialog({super.key, required this.tile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart, size: 50, color: Colors.green),
          SizedBox(height: 10),
          Text("TELİF HAKKI", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(tile.title, style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text("Fiyat: ${tile.price} Yıldız"),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    ref.read(gameProvider.notifier).declinePurchase(),
                child: const Text("PAS GEÇ"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    ref.read(gameProvider.notifier).purchaseProperty(),
                child: const Text("SATIN AL"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
