import 'package:flutter/material.dart';

/// Example demonstrating AnimatedPositioned usage for token movement
/// 
/// This is a standalone example showing how AnimatedPositioned works
/// for animating player tokens between tiles.
class AnimatedPositionedExample extends StatefulWidget {
  const AnimatedPositionedExample({super.key});

  @override
  State<AnimatedPositionedExample> createState() => _AnimatedPositionedExampleState();
}

class _AnimatedPositionedExampleState extends State<AnimatedPositionedExample> {
  // Current token position (0 = first tile, 9 = last tile)
  int _currentPosition = 0;
  
  // Animation duration
  static const Duration animationDuration = Duration(milliseconds: 600);
  
  // Animation curve
  static const Curve animationCurve = Curves.easeInOut;

  void _moveToken() {
    setState(() {
      // Move to next tile (wrap around after 9)
      _currentPosition = (_currentPosition + 1) % 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedPositioned Example'),
        backgroundColor: Colors.brown.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: const Text(
                'Click "Move Token" to see the animation.\n'
                'The token will smoothly move to the next tile.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            
            // Move button
            ElevatedButton(
              onPressed: _moveToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Move Token'),
            ),
            const SizedBox(height: 30),
            
            // Board with animated token
            _buildBoard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        border: Border.all(color: Colors.brown.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          children: [
            // Static tiles row
            Row(
              children: List.generate(10, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 120,
                    decoration: BoxDecoration(
                      color: index == _currentPosition 
                          ? Colors.yellow.shade200 
                          : Colors.white,
                      border: Border.all(
                        color: index == _currentPosition 
                            ? Colors.yellow.shade700 
                            : Colors.grey.shade400,
                        width: index == _currentPosition ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            // Animated token overlay
            // This is the key component - AnimatedPositioned
            _buildAnimatedToken(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedToken() {
    // Calculate the horizontal position based on current tile
    // Total width is divided among 10 tiles
    final double tileWidth = (MediaQuery.of(context).size.width - 64) / 10; // 64 = margins
    final double tokenX = _currentPosition * tileWidth + (tileWidth / 2) - 16; // -16 to center 32px token
    
    return AnimatedPositioned(
      // Animation duration - controls how fast the movement is
      duration: animationDuration,
      
      // Animation curve - controls the easing (acceleration/deceleration)
      curve: animationCurve,
      
      // Left position - animates from old X to new X
      left: tokenX + 16, // +16 for padding adjustment
      
      // Top position - animates from old Y to new Y (fixed in this example)
      top: 44, // Center vertically in 120px tile (120/2 - 32/2 + padding)
      
      // The token widget to animate
      child: _buildPlayerToken(),
    );
  }

  Widget _buildPlayerToken() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.shade600,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'P1',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Extended example with diagonal movement
class DiagonalMovementExample extends StatefulWidget {
  const DiagonalMovementExample({super.key});

  @override
  State<DiagonalMovementExample> createState() => _DiagonalMovementExampleState();
}

class _DiagonalMovementExampleState extends State<DiagonalMovementExample> {
  int _tileX = 0;
  int _tileY = 0;
  static const int gridWidth = 5;
  static const int gridHeight = 4;

  void _moveDiagonally() {
    setState(() {
      _tileX = (_tileX + 1) % gridWidth;
      _tileY = (_tileY + 1) % gridHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagonal Movement Example'),
        backgroundColor: Colors.green.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _moveDiagonally,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Move Diagonally'),
            ),
            const SizedBox(height: 20),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          children: [
            // Grid of tiles
            Column(
              children: List.generate(gridHeight, (y) {
                return Expanded(
                  child: Row(
                    children: List.generate(gridWidth, (x) {
                      final isCurrentTile = x == _tileX && y == _tileY;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isCurrentTile 
                                ? Colors.yellow.shade200 
                                : Colors.white,
                            border: Border.all(
                              color: isCurrentTile 
                                  ? Colors.yellow.shade700 
                                  : Colors.grey.shade400,
                              width: isCurrentTile ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${x + 1},${y + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            
            // Animated token with diagonal movement
            _buildDiagonalToken(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagonalToken() {
    final double tileWidth = (MediaQuery.of(context).size.width - 64) / gridWidth;
    final double tileHeight = 300 / gridHeight;
    
    final double tokenX = _tileX * tileWidth + (tileWidth / 2) - 16;
    final double tokenY = _tileY * tileHeight + (tileHeight / 2) - 16;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      left: tokenX + 16,
      top: tokenY + 16,
      child: _buildPlayerToken(),
    );
  }

  Widget _buildPlayerToken() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade600,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Example showing different animation curves
class AnimationCurveExample extends StatefulWidget {
  const AnimationCurveExample({super.key});

  @override
  State<AnimationCurveExample> createState() => _AnimationCurveExampleState();
}

class _AnimationCurveExampleState extends State<AnimationCurveExample> {
  int _position = 0;
  Curve _selectedCurve = Curves.easeInOut;

  final Map<String, Curve> _curves = {
    'Ease In Out': Curves.easeInOut,
    'Ease Out': Curves.easeOut,
    'Ease In': Curves.easeIn,
    'Linear': Curves.linear,
    'Bounce Out': Curves.bounceOut,
    'Elastic Out': Curves.elasticOut,
  };

  void _moveToken() {
    setState(() {
      _position = (_position + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Curves Example'),
        backgroundColor: Colors.purple.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Curve selector
            const Text('Select Animation Curve:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _curves.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: _selectedCurve == entry.value,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCurve = entry.value;
                    });
                  },
                  selectedColor: Colors.purple.shade200,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _moveToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Move Token'),
            ),
            const SizedBox(height: 30),
            
            // Animation demo
            _buildAnimationDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationDemo() {
    final double screenWidth = MediaQuery.of(context).size.width - 64;
    final double tileWidth = screenWidth / 3;
    final double tokenX = _position * tileWidth + (tileWidth / 2) - 16;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border.all(color: Colors.purple.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          children: [
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == _position 
                          ? Colors.yellow.shade200 
                          : Colors.white,
                      border: Border.all(
                        color: index == _position 
                            ? Colors.yellow.shade700 
                            : Colors.grey.shade400,
                        width: index == _position ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: _selectedCurve,
              left: tokenX + 16,
              top: 59,
              child: _buildPlayerToken(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerToken() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple.shade600,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

/// Main example launcher
void main() {
  runApp(const MaterialApp(
    home: AnimatedPositionedExampleLauncher(),
  ));
}

class AnimatedPositionedExampleLauncher extends StatelessWidget {
  const AnimatedPositionedExampleLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedPositioned Examples'),
        backgroundColor: Colors.brown.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select an example to view:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnimatedPositionedExample(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Basic Movement', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiagonalMovementExample(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Diagonal Movement', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnimationCurveExample(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Animation Curves', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
