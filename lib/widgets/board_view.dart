import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/board_config.dart';
import '../models/board_tile.dart';
import '../models/game_enums.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';

class BoardView extends ConsumerWidget {
  const BoardView({super.key});

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

              // 2. Oyuncular (6 Kişi Desteği için Grid Düzeni)
              ...gameState.players.map((player) {
                // Aynı karedeki diğer oyuncuları bul
                final playersOnSameTile = gameState.players
                    .where((p) => p.position == player.position)
                    .toList();
                final indexInTile = playersOnSameTile.indexOf(player);
                return _buildPlayerPositioned(
                  player,
                  tileSize,
                  indexInTile,
                  playersOnSameTile.length,
                );
              }),

              // 3. Orta Panel
              _buildCenterPanel(gameState, tileSize, ref),

              // 4. SORU DIALOG
              if (gameState.showQuestionDialog &&
                  gameState.currentQuestion != null)
                _buildOverlay(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "SORU",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        gameState.currentQuestion!.text,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ...List.generate(
                        gameState.currentQuestion!.options.length,
                        (index) => Padding(
                          padding: EdgeInsets.all(4),
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .answerQuestion(index),
                            child: Text(
                              gameState.currentQuestion!.options[index],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 5. SATIN ALMA DIALOG
              if (gameState.showPurchaseDialog && gameState.currentTile != null)
                _buildOverlay(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, size: 50, color: Colors.green),
                      SizedBox(height: 10),
                      Text(
                        "TELİF HAKKI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        gameState.currentTile!.title,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text("Fiyat: ${gameState.currentTile!.price} Yıldız"),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .declinePurchase(),
                            child: Text("PAS GEÇ"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .purchaseProperty(),
                            child: Text("SATIN AL"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // 6. KART DIALOG (YENİ)
              if (gameState.showCardDialog && gameState.currentCard != null)
                _buildOverlay(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        gameState.currentCard!.type == CardType.sans
                            ? Icons.star
                            : Icons.bolt,
                        size: 60,
                        color: gameState.currentCard!.type == CardType.sans
                            ? Colors.pink
                            : Colors.teal,
                      ),
                      SizedBox(height: 16),
                      Text(
                        gameState.currentCard!.type == CardType.sans
                            ? "ŞANS KARTI"
                            : "KADER KARTI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        gameState.currentCard!.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(gameProvider.notifier).closeCardDialog(),
                        child: Text("TAMAM"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 45),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              // 7. Geliştirme Dialog
              if (gameState.showUpgradeDialog && gameState.currentTile != null)
                _buildOverlay(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_circle_up,
                        size: 50,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Mülk Geliştirme",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(gameState.currentTile!.title),
                      SizedBox(height: 20),
                      Text(
                        gameState.currentTile!.upgradeLevel < 3
                            ? "Baskı Yapmak İster misiniz?"
                            : "Cilt/Seri Yapmak İster misiniz?",
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Maliyet: ${gameState.currentTile!.upgradeLevel < 3 ? (gameState.currentTile!.price! * 0.5).round() : (gameState.currentTile!.price! * 2).round()} Yıldız",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .declineUpgrade(),
                            child: Text("Hayır"),
                          ),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(gameProvider.notifier)
                                .upgradeProperty(),
                            child: Text("Evet, Geliştir"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay({required Widget child}) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTilePositioned(
    BoardTile tile,
    double size,
    List<Player> players,
  ) {
    // Sahiplik Kontrolü
    Color? ownerColor;
    for (var player in players) {
      if (player.ownedTiles.contains(tile.id)) {
        ownerColor = player.color;
        break;
      }
    }

    double left = 0, top = 0;
    // (Koordinat hesaplaması önceki ile aynı)
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
              : _getTileColor(tile.type), // Sahibi varsa rengi aç
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
            // Geliştirme İkonları (Baskı Sayısı)
            if (tile.type == TileType.property &&
                tile.upgradeLevel > 0 &&
                !tile.isUtilities)
              Positioned(
                bottom: 2,
                right: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(tile.upgradeLevel, (index) {
                    if (tile.upgradeLevel == 4)
                      return Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: Colors.amber,
                      ); // Kral tacı/Kupa
                    return Icon(Icons.star, size: 10, color: Colors.amber[800]);
                  }),
                ),
              ),
            // Yayınevi İkonu
            if (tile.isUtilities)
              Positioned(
                bottom: 2,
                right: 2,
                child: Icon(Icons.business, size: 14, color: Colors.blueGrey),
              ),
          ],
        ),
      ),
    );
  }

  // Oyuncu Piyonu Çizimi (Grid / Offset Mantığı)
  Widget _buildPlayerPositioned(
    Player player,
    double size,
    int index,
    int total,
  ) {
    // Koordinat hesapla
    double left = 0, top = 0;
    int pos = player.position;

    // Temel konum (Sol üst köşe)
    if (pos == 0) {
      left = 0;
      top = 10 * size;
    } else if (pos < 10) {
      left = (pos + 0.5) * size;
      top = 10.5 * size;
    } else if (pos == 10) {
      left = 10 * size;
      top = 10 * size;
    } else if (pos < 20) {
      left = 10.5 * size;
      top = (10 - (pos - 10) - 0.5) * size;
    } else if (pos == 20) {
      left = 10 * size;
      top = 0;
    } else if (pos < 30) {
      left = (10 - (pos - 20) - 0.5) * size;
      top = 0;
    } else if (pos == 30) {
      left = 0;
      top = 0;
    } else {
      left = 0;
      top = ((pos - 30) + 0.5) * size;
    }

    // Offset hesapla (Grid 2x3 veya 3x2)
    // Kare boyutu: size (veya köşeler için size*1.5)
    // Basitçe: her oyuncu için hafif kaydırma
    double offsetX = 0;
    double offsetY = 0;

    if (total > 1) {
      // 2 satır, 3 sütun gibi düşünelim
      int row = index ~/ 3;
      int col = index % 3;
      offsetX = (col * (size / 3)) - (size / 6);
      offsetY = (row * (size / 3)) - (size / 6);
    }

    // Köşeler (Start, Jail vs) daha büyük olduğu için merkezi ortala
    bool isCorner = (pos % 10 == 0);
    double centerOffset = isCorner ? (size * 1.5) / 2 : size / 2;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 500),
      left: left + centerOffset - (size * 0.15) + offsetX,
      top: top + centerOffset - (size * 0.15) + offsetY,
      child: Tooltip(
        message: "${player.name} (${player.balance})",
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: size * 0.18, // Biraz daha küçük
          child: CircleAvatar(
            backgroundColor: player.color,
            radius: size * 0.15,
            child: Icon(player.icon, size: size * 0.2, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Orta Panel
  Widget _buildCenterPanel(GameState state, double tileSize, WidgetRef ref) {
    if (state.phase == GamePhase.gameOver) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              Text(
                "OYUN BİTTİ!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                state.lastAction,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        width: tileSize * 6, // Biraz daha geniş
        height: tileSize * 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
        ),
        child: Column(
          children: [
            // Üst: Kart Desteleri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDeck(Colors.pink[100]!, "ŞANS"),
                _buildDeck(Colors.teal[100]!, "KADER"),
              ],
            ),
            Divider(),

            // Orta: Oyuncu Bilgisi & Zar
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.currentPlayer.icon,
                        color: state.currentPlayer.color,
                      ),
                      SizedBox(width: 8),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    state.lastAction,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  if (!state.isDiceRolled &&
                      !state.showQuestionDialog &&
                      !state.showPurchaseDialog &&
                      !state.showUpgradeDialog)
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(gameProvider.notifier).rollDice(),
                      icon: Icon(Icons.casino),
                      label: Text("ZAR AT"),
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                ],
              ),
            ),

            // Alt: Oyunu Bitir
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () => ref.read(gameProvider.notifier).endGame(),
                icon: Icon(Icons.exit_to_app, size: 16),
                label: Text("Oyunu Bitir", style: TextStyle(fontSize: 12)),
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
        boxShadow: [
          BoxShadow(blurRadius: 4, offset: Offset(2, 2), color: Colors.black12),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

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
