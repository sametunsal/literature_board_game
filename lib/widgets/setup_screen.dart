import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_notifier.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int playerCount =
      2; // Varsayılan 2 ama 4-6 istenmiş, kullanıcı min 2 max 6 yapabilir
  List<Player> tempPlayers = [];

  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  final List<IconData> availableIcons = [
    Icons.person,
    Icons.face,
    Icons.pets,
    Icons.emoji_emotions,
    Icons.star,
    Icons.android,
  ];

  @override
  void initState() {
    super.initState();
    _resetPlayers();
  }

  void _resetPlayers() {
    tempPlayers = List.generate(
      playerCount,
      (index) => Player(
        id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
        name: 'Oyuncu ${index + 1}',
        color: availableColors[index % availableColors.length],
        icon: availableIcons[index % availableIcons.length],
      ),
    );
  }

  void _updatePlayerCount(int count) {
    setState(() {
      playerCount = count;
      _resetPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Kurulumu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Oyuncu Sayısı Seçimi
            const Text(
              "Oyuncu Sayısı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4, 5, 6].map((count) {
                // 4, 5, 6 istenmiş
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text("$count"),
                    selected: playerCount == count,
                    onSelected: (selected) {
                      if (selected) _updatePlayerCount(count);
                    },
                  ),
                );
              }).toList(),
            ),
            const Divider(),

            // Oyuncu Ayarları
            ...List.generate(playerCount, (index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "${index + 1}. Oyuncu İsmi",
                        ),
                        controller:
                            TextEditingController(text: tempPlayers[index].name)
                              ..selection = TextSelection.fromPosition(
                                TextPosition(
                                  offset: tempPlayers[index].name.length,
                                ),
                              ),
                        onChanged: (val) {
                          tempPlayers[index] = tempPlayers[index].copyWith(
                            name: val,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Renk Seçimi
                          DropdownButton<Color>(
                            value: tempPlayers[index].color,
                            items: availableColors
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      color: c,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  tempPlayers[index] = tempPlayers[index]
                                      .copyWith(color: val);
                                });
                              }
                            },
                          ),
                          // İkon Seçimi
                          DropdownButton<IconData>(
                            value: tempPlayers[index].icon,
                            items: availableIcons
                                .map(
                                  (i) => DropdownMenuItem(
                                    value: i,
                                    child: Icon(i),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  tempPlayers[index] = tempPlayers[index]
                                      .copyWith(icon: val);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                ref.read(gameProvider.notifier).initializeGame(tempPlayers);
              },
              child: const Text("OYUNA BAŞLA"),
            ),
          ],
        ),
      ),
    );
  }
}
