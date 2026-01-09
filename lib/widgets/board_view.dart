import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/board_config.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart'; // GamePhase, CardType
import '../models/player.dart';
import '../providers/game_notifier.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  static const List<IconData> playerIcons = [
    Icons.person,
    Icons.face,
    Icons.pets,
    Icons.emoji_emotions,
    Icons.rocket_launch,
    Icons.star,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final tileSize = MediaQuery.of(context).size.shortestSide / 13;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: SizedBox(
          width: tileSize * 12,
          height: tileSize * 12,
          child: Stack(
            children: [
              // 1. Kutucuklar
              ...BoardConfig.tiles.map(
                (tile) =>
                    _buildTilePositioned(tile, tileSize, gameState.players),
              ),

              // 2. Oyuncular (Wrap ile Gruplanmis)
              ..._buildGroupedPlayers(gameState.players, tileSize),

              // 3. Orta Panel
              _buildCenterPanel(gameState, tileSize, ref),

              // 4. DIALOGLAR
              if (gameState.showQuestionDialog &&
                  gameState.currentQuestion != null)
                _buildOverlay(child: _buildQuestionDialog(ref, gameState)),

              if (gameState.showPurchaseDialog && gameState.currentTile != null)
                _buildOverlay(child: _buildPurchaseDialog(ref, gameState)),

              if (gameState.showCardDialog && gameState.currentCard != null)
                _buildOverlay(child: _buildCardDialog(ref, gameState)),

              if (gameState.showUpgradeDialog && gameState.currentTile != null)
                _buildOverlay(child: _buildUpgradeDialog(ref, gameState)),
            ],
          ),
        ),
      ),
    );
  }

  // --- OYUNCU GRUPLAMA MANTIĞI (Wrap Kullanımı) ---
  List<Widget> _buildGroupedPlayers(List<Player> players, double size) {
    Map<int, List<Player>> groups = {};
    for (var p in players) {
      if (!groups.containsKey(p.position)) groups[p.position] = [];
      groups[p.position]!.add(p);
    }

    List<Widget> widgets = [];
    groups.forEach((pos, group) {
      Offset tileCenter = _getTileCenter(pos, size);

      widgets.add(
        Positioned(
          left: tileCenter.dx - (size / 2),
          top: tileCenter.dy - (size / 2),
          width: size,
          height: size,
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 2,
              children: group
                  .map((p) => _buildPlayerIcon(p, size, group.length))
                  .toList(),
            ),
          ),
        ),
      );
    });
    return widgets;
  }

  Offset _getTileCenter(int id, double size) {
    double x = 0;
    double y = 0;

    // 0 (Start) -> Sol Alt
    if (id == 0) {
      x = size / 2;
      y = 10.5 * size;
    }
    // 1-9 (Alt Kenar, Soldan Sağa)
    else if (id < 10) {
      x = (id + 0.5) * size;
      y = 10.5 * size;
    }
    // 10 (Sağ Alt)
    else if (id == 10) {
      x = 10.5 * size;
      y = 10.5 * size;
    }
    // 11-19 (Sağ Kenar, Aşağıdan Yukarı)
    else if (id < 20) {
      x = 10.5 * size;
      y = (10 - (id - 10) + 0.5) * size;
    }
    // 20 (Sağ Üst)
    else if (id == 20) {
      x = 10.5 * size;
      y = 0.5 * size;
    }
    // 21-29 (Üst Kenar, Sağdan Sola)
    else if (id < 30) {
      x = (10 - (id - 20) + 0.5) * size;
      y = 0.5 * size;
    }
    // 30 (Sol Üst)
    else if (id == 30) {
      x = 0.5 * size;
      y = 0.5 * size;
    }
    // 31-39 (Sol Kenar, Yukarıdan Aşağı)
    else {
      x = 0.5 * size;
      y = ((id - 30) + 0.5) * size;
    }

    return Offset(x, y);
  }

  Widget _buildPlayerIcon(Player player, double tileSize, int groupSize) {
    double iconSize = tileSize * 0.35;
    if (groupSize > 1) iconSize = tileSize * 0.25;
    if (groupSize > 4) iconSize = tileSize * 0.20;

    final currentIcon =
        (player.iconIndex >= 0 && player.iconIndex < playerIcons.length)
        ? playerIcons[player.iconIndex]
        : Icons.person;

    return Tooltip(
      message: "${player.name} (${player.balance})",
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12, width: 1),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: player.color,
          radius: iconSize / 2,
          child: Icon(currentIcon, size: iconSize * 0.7, color: Colors.white),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildOverlay({required Widget child}) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildCenterPanel(GameState state, double tileSize, WidgetRef ref) {
    if (state.phase == GamePhase.gameOver) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const Text(
                "OYUN BİTTİ!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                state.lastAction,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final currentIcon =
        (state.currentPlayer.iconIndex >= 0 &&
            state.currentPlayer.iconIndex < playerIcons.length)
        ? playerIcons[state.currentPlayer.iconIndex]
        : Icons.person;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: tileSize * 6,
        height: tileSize * 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(Colors.pink[100]!, "ŞANS"),
                _buildDeck(Colors.teal[100]!, "KADER"),
              ],
            ),
            const Divider(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(currentIcon, color: state.currentPlayer.color),
                      const SizedBox(width: 8),
                      Text(
                        state.currentPlayer.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: state.currentPlayer.color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${state.currentPlayer.balance} Yıldız",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.lastAction,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  if (!state.isDiceRolled &&
                      !state.showQuestionDialog &&
                      !state.showPurchaseDialog &&
                      !state.showUpgradeDialog)
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(gameProvider.notifier).rollDice(),
                      icon: const Icon(Icons.casino),
                      label: const Text("ZAR AT"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (state.isDiceRolled &&
                      !state.showQuestionDialog &&
                      !state.showPurchaseDialog)
                    Text(
                      "${state.diceTotal}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () => ref.read(gameProvider.notifier).endGame(),
                icon: const Icon(Icons.exit_to_app, size: 16),
                label: const Text(
                  "Oyunu Bitir",
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeck(Color color, String title) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(blurRadius: 4, offset: Offset(2, 2), color: Colors.black12),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildTilePositioned(
    BoardTile tile,
    double size,
    List<Player> players,
  ) {
    Color? ownerColor;
    for (var player in players) {
      if (player.ownedTiles.contains(tile.id)) {
        ownerColor = player.color;
        break;
      }
    }

    double left = 0, top = 0;
    if (tile.id == 0) {
      left = 0;
      top = 10 * size;
    } else if (tile.id < 10) {
      left = (tile.id + 0.5) * size;
      top = 10.5 * size;
    } else if (tile.id == 10) {
      left = 10 * size;
      top = 10 * size;
    } else if (tile.id < 20) {
      left = 10.5 * size;
      top = (10 - (tile.id - 10) - 0.5) * size;
    } else if (tile.id == 20) {
      left = 10 * size;
      top = 0;
    } else if (tile.id < 30) {
      left = (10 - (tile.id - 20) - 0.5) * size;
      top = 0;
    } else if (tile.id == 30) {
      left = 0;
      top = 0;
    } else {
      left = 0;
      top = ((tile.id - 30) + 0.5) * size;
    }

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: (tile.id % 10 == 0) ? size * 1.5 : size,
        height: (tile.id % 10 == 0) ? size * 1.5 : size,
        decoration: BoxDecoration(
          color: ownerColor != null
              ? ownerColor.withOpacity(0.3)
              : _getTileColor(tile.type),
          border: Border.all(
            color: ownerColor ?? Colors.black54,
            width: ownerColor != null ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  tile.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (tile.id % 10 == 0) ? 10 : 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (tile.type == TileType.property &&
                tile.upgradeLevel > 0 &&
                !tile.isUtility)
              Positioned(
                bottom: 2,
                right: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tile.upgradeLevel, (index) {
                    if (tile.upgradeLevel == 4)
                      return const Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: Colors.amber,
                      );
                    return Icon(Icons.star, size: 10, color: Colors.amber[800]);
                  }),
                ),
              ),
            if (tile.isUtility)
              const Positioned(
                bottom: 2,
                right: 2,
                child: Icon(Icons.business, size: 14, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG WIDGETS ---

  Widget _buildQuestionDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        "SORU",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      const SizedBox(height: 10),
      Text(state.currentQuestion!.text, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ...List.generate(
        state.currentQuestion!.options.length,
        (index) => Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () =>
                ref.read(gameProvider.notifier).answerQuestion(index),
            child: Text(state.currentQuestion!.options[index]),
          ),
        ),
      ),
    ],
  );

  Widget _buildPurchaseDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.shopping_cart, size: 50, color: Colors.green),
      const SizedBox(height: 10),
      const Text("TELİF HAKKI", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(state.currentTile!.title, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text("Fiyat: ${state.currentTile!.price} Yıldız"),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.read(gameProvider.notifier).declinePurchase(),
            child: const Text("PAS GEÇ"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ref.read(gameProvider.notifier).purchaseProperty(),
            child: const Text("SATIN AL"),
          ),
        ],
      ),
    ],
  );

  Widget _buildCardDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        state.currentCard!.type == CardType.sans ? Icons.star : Icons.bolt,
        size: 60,
        color: state.currentCard!.type == CardType.sans
            ? Colors.pink
            : Colors.teal,
      ),
      const SizedBox(height: 16),
      Text(
        state.currentCard!.type == CardType.sans ? "ŞANS KARTI" : "KADER KARTI",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      const SizedBox(height: 16),
      Text(
        state.currentCard!.description,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => ref.read(gameProvider.notifier).closeCardDialog(),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 45),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        child: const Text("TAMAM"),
      ),
    ],
  );

  Widget _buildUpgradeDialog(WidgetRef ref, GameState state) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.arrow_circle_up, size: 50, color: Colors.orange),
      const SizedBox(height: 10),
      const Text(
        "Mülk Geliştirme",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Text(state.currentTile!.title),
      const SizedBox(height: 20),
      Text(
        state.currentTile!.upgradeLevel < 3
            ? "Baskı Yapmak İster misiniz?"
            : "Cilt/Seri Yapmak İster misiniz?",
        textAlign: TextAlign.center,
      ),
      Text(
        "Maliyet: ${state.currentTile!.upgradeLevel < 3 ? (state.currentTile!.price! * 0.5).round() : (state.currentTile!.price! * 2).round()} Yıldız",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => ref.read(gameProvider.notifier).declineUpgrade(),
            child: const Text("Hayır"),
          ),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).upgradeProperty(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Evet, Geliştir"),
          ),
        ],
      ),
    ],
  );

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.start:
        return Colors.greenAccent;
      case TileType.property:
        return Colors.white;
      case TileType.publisher:
        return Colors.yellow[200]!;
      case TileType.chance:
        return Colors.pink[100]!;
      case TileType.fate:
        return Colors.teal[100]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
