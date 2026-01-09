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
  int playerCount = 4;
  final List<TextEditingController> _controllers = [];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];
  final List<int> _selectedIcons = [];

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  void _updateControllers() {
    _controllers.clear();
    _selectedIcons.clear();
    for (int i = 0; i < playerCount; i++) {
      _controllers.add(TextEditingController(text: "Oyuncu ${i + 1}"));
      _selectedIcons.add(i);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(title: const Text("OYUN KURULUMU")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: playerCount,
              items: [2, 3, 4, 5, 6]
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text("$e Kişilik")),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    playerCount = val;
                    _updateControllers();
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: playerCount,
                itemBuilder: (ctx, i) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _colors[i],
                      child: Icon(
                        IconData(
                          0xe000 + _selectedIcons[i],
                          fontFamily: 'MaterialIcons',
                        ),
                      ),
                    ),
                    title: TextField(
                      controller: _controllers[i],
                      decoration: const InputDecoration(labelText: "İsim"),
                    ),
                    trailing: DropdownButton<int>(
                      value: _selectedIcons[i],
                      items: List.generate(
                        10,
                        (idx) => DropdownMenuItem(
                          value: idx,
                          child: Icon(
                            IconData(0xe000 + idx, fontFamily: 'MaterialIcons'),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedIcons[i] = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                List<Player> players = [];
                for (int i = 0; i < playerCount; i++) {
                  players.add(
                    Player(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          "$i",
                      name: _controllers[i].text,
                      color: _colors[i],
                      iconIndex: _selectedIcons[i],
                    ),
                  );
                }
                // Using initializeGame which adheres to our provider
                ref.read(gameProvider.notifier).initializeGame(players);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
              ),
              child: const Text("OYUNA BAŞLA", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
