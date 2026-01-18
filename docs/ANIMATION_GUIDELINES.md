# Animation Guidelines

This document describes the animation standards and best practices used in the Literature Board Game project.

## Overview

The project uses centralized animation constants defined in [`lib/core/motion/motion_constants.dart`](../lib/core/motion/motion_constants.dart) to ensure consistent, accessible, and performant animations throughout the application.

## Motion Constants

### Location

[`lib/core/motion/motion_constants.dart`](../lib/core/motion/motion_constants.dart)

### Accessibility Support

The animation system includes built-in accessibility support through the `.safe` extension:

```dart
bool get reduceMotion => WidgetsBinding
    .instance
    .platformDispatcher
    .accessibilityFeatures
    .disableAnimations;
```

When reduced motion is enabled, all animations using the `.safe` extension will return `Duration.zero`, instantly completing transitions.

## Durations

### Standard Durations

| Constant | Duration | Use Case |
|----------|----------|----------|
| `MotionDurations.fast` | 150ms | Micro-interactions, hover, press feedback |
| `MotionDurations.medium` | 300ms | Standard transitions, default animations |
| `MotionDurations.slow` | 500ms | Emphasis, page/screen transitions |
| `MotionDurations.dialog` | 350ms | Dialog open/close animations |
| `MotionDurations.pawn` | 400ms | Pawn hop animation on board |
| `MotionDurations.dice` | 800ms | Dice roll and settle animation |
| `MotionDurations.confetti` | 2000ms | Confetti celebration duration |

### Ambient/Long-Running Durations

| Constant | Duration | Use Case |
|----------|----------|----------|
| `MotionDurations.ambientGradient` | 8s | Ambient gradient background breathing animation |
| `MotionDurations.shimmerLong` | 3000ms | Long shimmer effects (logo, decorative) |
| `MotionDurations.shimmerMedium` | 2500ms | Medium shimmer effects (title, highlights) |

### Computed/Derived Durations

| Constant | Duration | Use Case |
|----------|----------|----------|
| `MotionDurations.slowDouble` | 1000ms | Double slow duration for extended transitions |
| `MotionDurations.pulse` | 350ms | Tile landing pulse animation |

## Curves

### Standard Curves

| Constant | Curve | Use Case |
|----------|-------|----------|
| `MotionCurves.standard` | `Curves.easeOutCubic` | Default curve for most UI transitions |
| `MotionCurves.emphasized` | `Curves.easeOutBack` | Pop-in effect for dialogs and emphasized entrances |
| `MotionCurves.decelerate` | `Curves.decelerate` | Settling motion, dice stopping |
| `MotionCurves.spring` | `Curves.elasticOut` | Bouncy feedback, playful interactions |

## Usage Guidelines

### When to Use Each Duration

#### MotionDurations.fast (150ms)
Use for quick, responsive interactions:
- Button press feedback
- Hover effects
- Small state changes
- Toggle switches

**Example**:
```dart
AnimatedContainer(
  duration: MotionDurations.fast.safe,
  curve: MotionCurves.standard,
  decoration: BoxDecoration(
    color: isHovered ? Colors.blue : Colors.grey,
  ),
)
```

#### MotionDurations.medium (300ms)
Use for standard UI transitions:
- Card expansion/collapse
- Panel slide-in
- List item insertion/deletion
- Default animations

**Example**:
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: MotionDurations.medium.safe,
  curve: MotionCurves.standard,
  child: content,
)
```

#### MotionDurations.slow (500ms)
Use for emphasis and major transitions:
- Screen transitions
- Major state changes
- Emphasis animations

**Example**:
```dart
AnimatedSwitcher(
  duration: MotionDurations.slow.safe,
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  child: currentPage,
)
```

#### MotionDurations.dialog (350ms)
Use for dialog animations:
- Dialog open/close
- Modal presentations
- Bottom sheet animations

**Example**:
```dart
AnimatedScale(
  scale: isOpen ? 1.0 : 0.8,
  duration: MotionDurations.dialog.safe,
  curve: MotionCurves.emphasized,
  child: dialogContent,
)
```

#### MotionDurations.pawn (400ms)
Use for pawn movement on the board:
- Single tile hop animation
- Player movement between tiles

**Example**:
```dart
AnimatedPositioned(
  duration: MotionDurations.pawn.safe,
  curve: MotionCurves.spring,
  left: newPosition.dx,
  top: newPosition.dy,
  child: pawnWidget,
)
```

#### MotionDurations.dice (800ms)
Use for dice rolling:
- Dice roll animation
- Dice settling

**Example**:
```dart
AnimatedRotation(
  turns: diceRotation,
  duration: MotionDurations.dice.safe,
  curve: MotionCurves.decelerate,
  child: diceWidget,
)
```

#### MotionDurations.confetti (2000ms)
Use for celebration effects:
- Victory confetti
- Achievement celebrations

**Example**:
```dart
ConfettiWidget(
  duration: MotionDurations.confetti.safe,
  particleCount: 100,
)
```

### When to Use Each Curve

#### MotionCurves.standard (easeOutCubic)
Use for most UI transitions:
- Default animations
- Smooth transitions
- General movement

**Characteristics**:
- Starts fast, slows down at end
- Natural feel
- Good for most cases

#### MotionCurves.emphasized (easeOutBack)
Use for emphasized entrances:
- Dialog pop-in
- Important elements appearing
- Call-to-action buttons

**Characteristics**:
- Overshoots slightly at end
- Playful, attention-grabbing
- Good for emphasis

**Example**:
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: Curves.easeOutBack.transform(_controller.value),
      child: child,
    );
  },
  child: dialogContent,
)
```

#### MotionCurves.decelerate (decelerate)
Use for settling motion:
- Dice stopping
- Objects coming to rest
- Landing effects

**Characteristics**:
- Starts fast, slows down gradually
- Natural deceleration
- Good for physics-like motion

**Example**:
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: Curves.decelerate.transform(_controller.value) * pi * 2,
      child: child,
    );
  },
  child: diceWidget,
)
```

#### MotionCurves.spring (elasticOut)
Use for bouncy feedback:
- Pawn hopping
- Playful interactions
- Success indicators

**Characteristics**:
- Bouncy, elastic
- Playful feel
- Good for game elements

**Example**:
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(
        0,
        -Curves.elasticOut.transform(_controller.value) * 20,
      ),
      child: child,
    );
  },
  child: pawnWidget,
)
```

## Accessibility Considerations

### Using the .safe Extension

Always use the `.safe` extension for animations to respect user accessibility preferences:

```dart
// ✅ Good - Respects reduced motion setting
AnimatedContainer(
  duration: MotionDurations.medium.safe,
  // ...
)

// ❌ Bad - Ignores reduced motion setting
AnimatedContainer(
  duration: MotionDurations.medium,
  // ...
)
```

### When Reduced Motion is Enabled

When a user has enabled "Reduce Motion" in their system settings:
- All animations using `.safe` will complete instantly
- UI will still function correctly, just without animations
- No visual disruption for users who prefer reduced motion

## Code Examples

### Basic Animation

```dart
class FadeInWidget extends StatefulWidget {
  final Widget child;
  
  const FadeInWidget({super.key, required this.child});
  
  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionDurations.medium.safe,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: MotionCurves.standard,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
```

### Dialog Animation

```dart
class AnimatedDialog extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  
  const AnimatedDialog({
    super.key,
    required this.child,
    required this.isVisible,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.8,
      duration: MotionDurations.dialog.safe,
      curve: MotionCurves.emphasized,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: MotionDurations.dialog.safe,
        curve: MotionCurves.standard,
        child: child,
      ),
    );
  }
}
```

### Pawn Movement Animation

```dart
class PawnAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback? onComplete;
  
  const PawnAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    this.onComplete,
  });
  
  @override
  State<PawnAnimation> createState() => _PawnAnimationState();
}

class _PawnAnimationState extends State<PawnAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionDurations.pawn.safe,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MotionCurves.spring,
    ));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _animation.value,
          child: child,
        );
      },
      child: const Icon(Icons.circle, size: 24),
    );
  }
}
```

### Dice Roll Animation

```dart
class DiceRollAnimation extends StatefulWidget {
  final int finalValue;
  final VoidCallback? onComplete;
  
  const DiceRollAnimation({
    super.key,
    required this.finalValue,
    this.onComplete,
  });
  
  @override
  State<DiceRollAnimation> createState() => _DiceRollAnimationState();
}

class _DiceRollAnimationState extends State<DiceRollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionDurations.dice.safe,
      vsync: this,
    );
    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: MotionCurves.decelerate,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * pi * 4,
          child: child,
        );
      },
      child: Text(
        widget.finalValue.toString(),
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}
```

### Ambient Background Animation

```dart
class AmbientBackground extends StatefulWidget {
  final Widget child;
  
  const AmbientBackground({super.key, required this.child});
  
  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MotionDurations.ambientGradient.safe,
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0 + _animation.value * 0.2,
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade800,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
```

## Best Practices

### 1. Always Use Motion Constants

```dart
// ✅ Good
duration: MotionDurations.medium.safe,

// ❌ Bad
duration: const Duration(milliseconds: 300),
```

### 2. Use Appropriate Curves

```dart
// ✅ Good - Dialog with emphasized curve
AnimatedScale(
  scale: isOpen ? 1.0 : 0.8,
  duration: MotionDurations.dialog.safe,
  curve: MotionCurves.emphasized,
  child: dialog,
)

// ❌ Bad - Dialog with standard curve (less emphasis)
AnimatedScale(
  scale: isOpen ? 1.0 : 0.8,
  duration: MotionDurations.dialog.safe,
  curve: MotionCurves.standard,
  child: dialog,
)
```

### 3. Always Use .safe Extension

```dart
// ✅ Good - Respects accessibility
duration: MotionDurations.medium.safe,

// ❌ Bad - Ignores accessibility
duration: MotionDurations.medium,
```

### 4. Match Duration to Action

```dart
// ✅ Good - Quick feedback for button press
AnimatedContainer(
  duration: MotionDurations.fast.safe,
  // ...
)

// ❌ Bad - Slow feedback for button press
AnimatedContainer(
  duration: MotionDurations.slow.safe,
  // ...
)
```

### 5. Dispose Animation Controllers

```dart
// ✅ Good - Proper cleanup
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ❌ Bad - Memory leak
@override
void dispose() {
  // Missing _controller.dispose()
  super.dispose();
}
```

### 6. Use vsync for Performance

```dart
// ✅ Good - Uses vsync
_controller = AnimationController(
  duration: MotionDurations.medium.safe,
  vsync: this,
);

// ❌ Bad - No vsync (may cause jank)
_controller = AnimationController(
  duration: MotionDurations.medium.safe,
);
```

## Performance Considerations

### 1. Avoid Unnecessary Animations

```dart
// ✅ Good - Only animate when needed
if (shouldAnimate) {
  return AnimatedContainer(
    duration: MotionDurations.medium.safe,
    // ...
  );
}
return Container(/* ... */);
```

### 2. Use AnimatedBuilder for Complex Animations

```dart
// ✅ Good - Efficient rebuild
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(
      angle: _controller.value * pi * 2,
      child: child, // This child won't rebuild
    );
  },
  child: expensiveWidget,
)
```

### 3. Avoid Nested Animations

```dart
// ✅ Good - Single animation controller
_controller = AnimationController(
  duration: MotionDurations.medium.safe,
  vsync: this,
);
_animation = Tween<double>(begin: 0, end: 1).animate(_controller);

// ❌ Bad - Multiple controllers for same animation
_controller1 = AnimationController(duration: MotionDurations.fast.safe, vsync: this);
_controller2 = AnimationController(duration: MotionDurations.fast.safe, vsync: this);
```

## Testing Animations

### Testing Animation Duration

```dart
test('animation should complete in expected time', () async {
  final controller = AnimationController(
    duration: MotionDurations.medium.safe,
    vsync: const TestVSync(),
  );
  
  final stopwatch = Stopwatch()..start();
  controller.forward();
  await controller.orCancel;
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, MotionDurations.medium.inMilliseconds);
});
```

### Testing Animation Curve

```dart
test('animation should follow expected curve', () {
  final animation = CurvedAnimation(
    parent: AnimationController(vsync: const TestVSync()),
    curve: MotionCurves.standard,
  );
  
  expect(animation.value, 0.0);
  
  // Advance to 50%
  animation.parent.value = 0.5;
  
  // easeOutCubic at 50% should be > 0.5
  expect(animation.value, greaterThan(0.5));
});
```

## Related Documentation

- [`../README.md`](../README.md) - Project overview
- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Architecture documentation
- [`STATE_MANAGEMENT.md`](STATE_MANAGEMENT.md) - State management guide
- [`COMPONENT_LIBRARY.md`](COMPONENT_LIBRARY.md) - UI component documentation
