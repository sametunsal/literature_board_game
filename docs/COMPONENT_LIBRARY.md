# Component Library Documentation

This document describes the reusable UI components available in the Literature Board Game project.

## Overview

The component library provides a set of consistent, reusable UI components that follow the project's design system. All components are theme-aware and support both light and dark modes.

## Component Location

All common components are located in [`lib/presentation/widgets/common/`](../lib/presentation/widgets/common/):

```
lib/presentation/widgets/common/
├── game_button.dart    # Standardized button component
├── game_card.dart      # Reusable card component
└── game_dialog.dart    # Animated dialog component
```

## GameButton

A standardized button component with multiple variants and consistent styling.

**Location**: [`lib/presentation/widgets/common/game_button.dart`](../lib/presentation/widgets/common/game_button.dart)

### Variants

| Variant | Use Case | Color |
|---------|----------|-------|
| `primary` | Main actions, CTAs | Theme primary color |
| `secondary` | Secondary actions | Theme secondary color |
| `danger` | Destructive actions | Theme danger color |
| `success` | Confirmation actions | Theme success color |

### Constructor

```dart
GameButton({
  Key? key,
  required String label,
  IconData? icon,
  required VoidCallback onPressed,
  GameButtonVariant variant = GameButtonVariant.primary,
  bool isLoading = false,
  bool isFullWidth = false,
  bool isDisabled = false,
  Color? customColor,
  Color? customTextColor,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `String` | required | Button text label |
| `icon` | `IconData?` | `null` | Optional icon to display before label |
| `onPressed` | `VoidCallback` | required | Callback when button is pressed |
| `variant` | `GameButtonVariant` | `primary` | Button variant (primary, secondary, danger, success) |
| `isLoading` | `bool` | `false` | Show loading indicator |
| `isFullWidth` | `bool` | `false` | Expand to full width |
| `isDisabled` | `bool` | `false` | Disable button interaction |
| `customColor` | `Color?` | `null` | Override background color |
| `customTextColor` | `Color?` | `null` | Override text color |

### Usage Examples

#### Basic Primary Button

```dart
GameButton(
  label: 'Roll Dice',
  onPressed: () {
    ref.read(gameProvider.notifier).rollDice();
  },
)
```

#### Button with Icon

```dart
GameButton(
  label: 'Buy Property',
  icon: Icons.shopping_cart,
  onPressed: () {
    ref.read(gameProvider.notifier).buyProperty();
  },
)
```

#### Secondary Button

```dart
GameButton(
  label: 'Cancel',
  variant: GameButtonVariant.secondary,
  onPressed: () {
    Navigator.pop(context);
  },
)
```

#### Danger Button

```dart
GameButton(
  label: 'Forfeit Game',
  variant: GameButtonVariant.danger,
  onPressed: () {
    // Handle forfeit
  },
)
```

#### Success Button

```dart
GameButton(
  label: 'Complete Turn',
  variant: GameButtonVariant.success,
  onPressed: () {
    ref.read(gameProvider.notifier).endTurn();
  },
)
```

#### Loading State

```dart
GameButton(
  label: 'Loading...',
  isLoading: true,
  onPressed: () {
    // Button is disabled while loading
  },
)
```

#### Full Width Button

```dart
GameButton(
  label: 'Start Game',
  isFullWidth: true,
  onPressed: () {
    // Start game
  },
)
```

#### Disabled Button

```dart
GameButton(
  label: 'Cannot Buy',
  isDisabled: true,
  onPressed: () {
    // Button is disabled, callback won't fire
  },
)
```

#### Custom Colors

```dart
GameButton(
  label: 'Special Action',
  customColor: Colors.purple,
  customTextColor: Colors.white,
  onPressed: () {
    // Handle special action
  },
)
```

### Design Specifications

#### Dimensions

- **Padding**: `14px` vertical, `24px` horizontal
- **Border Radius**: `12px`
- **Elevation**: `4px`
- **Icon Size**: `22px`
- **Font Size**: `15px`
- **Font Weight**: `600`

#### Colors

Colors are automatically derived from the current theme:

- **Background**: Based on variant (`tokens.primary`, `tokens.secondary`, etc.)
- **Foreground**: `tokens.textOnAccent`
- **Disabled**: Background with `0.5` alpha
- **Shadow**: Background with `0.4` alpha

#### Typography

- **Font Family**: Poppins
- **Letter Spacing**: `0.5`
- **Font Weight**: `600` (semi-bold)

### Accessibility

- **Semantic Button**: Uses `ElevatedButton` for proper screen reader support
- **Disabled State**: Visual and programmatic disabled state
- **Loading Indicator**: Accessible loading state with proper contrast

## GameCard

A reusable card component with consistent styling and shadow effects.

**Location**: [`lib/presentation/widgets/common/game_card.dart`](../lib/presentation/widgets/common/game_card.dart)

### Constructor

```dart
GameCard({
  Key? key,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double? width,
  double? height,
  Color? backgroundColor,
  VoidCallback? onTap,
  bool isInteractive = false,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | required | Card content |
| `padding` | `EdgeInsetsGeometry?` | `null` | Inner padding |
| `margin` | `EdgeInsetsGeometry?` | `null` | Outer margin |
| `width` | `double?` | `null` | Card width |
| `height` | `double?` | `null` | Card height |
| `backgroundColor` | `Color?` | `null` | Override background color |
| `onTap` | `VoidCallback?` | `null` | Callback when card is tapped |
| `isInteractive` | `bool` | `false` | Enable tap interaction |

### Usage Examples

#### Basic Card

```dart
GameCard(
  child: Text('Card Content'),
)
```

#### Card with Padding

```dart
GameCard(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      Text('Description'),
    ],
  ),
)
```

#### Card with Custom Size

```dart
GameCard(
  width: 200,
  height: 150,
  child: Center(
    child: Text('Fixed Size Card'),
  ),
)
```

#### Interactive Card

```dart
GameCard(
  onTap: () {
    // Handle card tap
    print('Card tapped!');
  },
  isInteractive: true,
  child: Text('Tap Me'),
)
```

#### Card with Custom Background

```dart
GameCard(
  backgroundColor: Colors.blue.shade100,
  child: Text('Custom Background'),
)
```

#### Card with Margin

```dart
GameCard(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Text('Card with Margin'),
)
```

### Design Specifications

#### Dimensions

- **Border Radius**: `8px`
- **Border**: `1px` solid theme border color

#### Shadows

The card uses a layered shadow system for depth:

1. **Ambient Shadow**:
   - Blur: `12px`
   - Spread: `1px`
   - Alpha: `0.3` (dark) / `0.15` (light)

2. **Direct Shadow**:
   - Blur: `8px`
   - Offset: `(2, 4)`
   - Alpha: `0.4` (dark) / `0.1` (light)

#### Colors

- **Background**: `tokens.surface` (from theme)
- **Border**: `tokens.border` (from theme)
- **Shadow**: `tokens.shadow` (from theme)

### Accessibility

- **Semantic Container**: Uses `Container` with proper semantics
- **Interactive State**: Visual feedback on tap when `isInteractive` is true
- **Contrast**: Ensures proper contrast ratio for text content

## GameDialog

An animated dialog component with accessibility support and theme-aware styling.

**Location**: [`lib/presentation/widgets/common/game_dialog.dart`](../lib/presentation/widgets/common/game_dialog.dart)

### Constructor

```dart
GameDialog({
  Key? key,
  required String title,
  required Widget content,
  List<Widget>? actions,
  bool showActions = true,
  VoidCallback? onClose,
  bool barrierDismissible = true,
})
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `String` | required | Dialog title |
| `content` | `Widget` | required | Dialog content |
| `actions` | `List<Widget>?` | `null` | Action buttons (default: OK button) |
| `showActions` | `bool` | `true` | Show action buttons |
| `onClose` | `VoidCallback?` | `null` | Callback when dialog is closed |
| `barrierDismissible` | `bool` | `true` | Allow tapping outside to close |

### Usage Examples

#### Basic Dialog

```dart
GameDialog(
  title: 'Game Over',
  content: Text('You won!'),
  actions: [
    GameButton(
      label: 'Play Again',
      onPressed: () {
        Navigator.pop(context);
        // Restart game
      },
    ),
  ],
)
```

#### Dialog with Custom Actions

```dart
GameDialog(
  title: 'Buy Property?',
  content: Text('Do you want to buy this property for $200?'),
  actions: [
    GameButton(
      label: 'No',
      variant: GameButtonVariant.secondary,
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    GameButton(
      label: 'Yes',
      variant: GameButtonVariant.primary,
      onPressed: () {
        Navigator.pop(context);
        // Buy property
      },
    ),
  ],
)
```

#### Dialog without Actions

```dart
GameDialog(
  title: 'Information',
  showActions: false,
  content: Text('This is an informational message.'),
  onClose: () {
    Navigator.pop(context);
  },
)
```

#### Non-dismissible Dialog

```dart
GameDialog(
  title: 'Important',
  barrierDismissible: false,
  content: Text('You must make a choice.'),
  actions: [
    GameButton(
      label: 'Continue',
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ],
)
```

#### Dialog with Complex Content

```dart
GameDialog(
  title: 'Question',
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('What is the capital of France?'),
      const SizedBox(height: 16),
      ...options.map((option) => ListTile(
        title: Text(option),
        onTap: () {
          Navigator.pop(context);
          // Handle answer
        },
      )),
    ],
  ),
)
```

### Design Specifications

#### Animation

The dialog uses animated entry and exit:

- **Duration**: `MotionDurations.dialog.safe` (350ms)
- **Entry Curve**: `MotionCurves.emphasized` (easeOutBack)
- **Exit Curve**: `MotionCurves.standard` (easeOutCubic)
- **Scale Animation**: `0.8` → `1.0`

#### Dimensions

- **Border Radius**: `16px`
- **Max Width**: `400px`
- **Padding**: `24px` (horizontal), `16px` (vertical)

#### Colors

- **Background**: `tokens.surface` (from theme)
- **Overlay**: `tokens.dialogOverlay` (from theme)
- **Title**: `tokens.textPrimary` (from theme)
- **Content**: `tokens.textPrimary` (from theme)

#### Typography

- **Title Font**: Playfair Display
- **Title Size**: `20px`
- **Title Weight**: `bold`
- **Content Font**: Poppins
- **Content Size**: `14px`
- **Content Weight**: `normal`

### Accessibility

- **Semantic Dialog**: Uses `Dialog` widget for proper screen reader support
- **Focus Management**: Automatic focus handling
- **Barrier**: Semantic barrier for modal behavior
- **Keyboard Support**: ESC key to dismiss when `barrierDismissible` is true

## Component Composition

### Dialog with GameButton Actions

```dart
GameDialog(
  title: 'Confirm Action',
  content: Text('Are you sure you want to proceed?'),
  actions: [
    GameButton(
      label: 'Cancel',
      variant: GameButtonVariant.secondary,
      onPressed: () => Navigator.pop(context),
    ),
    GameButton(
      label: 'Confirm',
      variant: GameButtonVariant.primary,
      onPressed: () {
        Navigator.pop(context);
        // Perform action
      },
    ),
  ],
)
```

### GameCard with GameButton

```dart
GameCard(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Player Stats'),
      const SizedBox(height: 16),
      Text('Balance: $1500'),
      const SizedBox(height: 16),
      GameButton(
        label: 'View Details',
        isFullWidth: true,
        onPressed: () {
          // Show details
        },
      ),
    ],
  ),
)
```

### Nested Components

```dart
GameCard(
  child: Column(
    children: [
      Text('Card Title'),
      const SizedBox(height: 12),
      GameButton(
        label: 'Action',
        variant: GameButtonVariant.success,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => GameDialog(
              title: 'Action Complete',
              content: Text('Your action was successful.'),
              actions: [
                GameButton(
                  label: 'OK',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    ],
  ),
)
```

## Best Practices

### 1. Use Appropriate Variants

```dart
// ✅ Good - Primary action
GameButton(
  label: 'Save',
  variant: GameButtonVariant.primary,
  onPressed: () {},
)

// ❌ Bad - Danger variant for save action
GameButton(
  label: 'Save',
  variant: GameButtonVariant.danger,
  onPressed: () {},
)
```

### 2. Provide Clear Labels

```dart
// ✅ Good - Descriptive label
GameButton(
  label: 'Buy Property for $200',
  onPressed: () {},
)

// ❌ Bad - Vague label
GameButton(
  label: 'OK',
  onPressed: () {},
)
```

### 3. Handle Loading States

```dart
// ✅ Good - Show loading state
GameButton(
  label: isLoading ? 'Processing...' : 'Submit',
  isLoading: isLoading,
  onPressed: isLoading ? null : handleSubmit,
)

// ❌ Bad - No loading feedback
GameButton(
  label: 'Submit',
  onPressed: handleSubmit,
)
```

### 4. Use Consistent Spacing

```dart
// ✅ Good - Consistent spacing
GameCard(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      const SizedBox(height: 12),
      Text('Content'),
      const SizedBox(height: 16),
      GameButton(label: 'Action', onPressed: () {}),
    ],
  ),
)

// ❌ Bad - Inconsistent spacing
GameCard(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: 8),
      Text('Content'),
      SizedBox(height: 24),
      GameButton(label: 'Action', onPressed: () {}),
    ],
  ),
)
```

### 5. Make Cards Interactive When Needed

```dart
// ✅ Good - Interactive card
GameCard(
  onTap: () => showDetails(),
  isInteractive: true,
  child: Text('Tap for details'),
)

// ❌ Bad - Non-interactive card that should be interactive
GameCard(
  child: Text('Tap for details'),
)
```

### 6. Use Dialogs for Important Actions

```dart
// ✅ Good - Confirmation dialog
GameButton(
  label: 'Delete',
  variant: GameButtonVariant.danger,
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => GameDialog(
        title: 'Confirm Delete',
        content: Text('This action cannot be undone.'),
        actions: [
          GameButton(
            label: 'Cancel',
            variant: GameButtonVariant.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          GameButton(
            label: 'Delete',
            variant: GameButtonVariant.danger,
            onPressed: () {
              Navigator.pop(context);
              // Perform delete
            },
          ),
        ],
      ),
    );
  },
)

// ❌ Bad - No confirmation for destructive action
GameButton(
  label: 'Delete',
  variant: GameButtonVariant.danger,
  onPressed: () {
    // Delete immediately
  },
)
```

## Theme Integration

All components automatically adapt to the current theme:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return Column(
      children: [
        // Components automatically use theme colors
        GameButton(
          label: 'Primary Action',
          onPressed: () {},
        ),
        GameCard(
          child: Text('Card content'),
        ),
      ],
    );
  }
}
```

## Testing Components

### Testing GameButton

```dart
testWidgets('GameButton should call onPressed', (tester) async {
  var pressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GameButton(
          label: 'Test',
          onPressed: () => pressed = true,
        ),
      ),
    ),
  );
  
  await tester.tap(find.text('Test'));
  expect(pressed, true);
});
```

### Testing GameCard

```dart
testWidgets('GameCard should display child', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GameCard(
          child: Text('Card Content'),
        ),
      ),
    ),
  );
  
  expect(find.text('Card Content'), findsOneWidget);
});
```

### Testing GameDialog

```dart
testWidgets('GameDialog should show title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () {
            showDialog(
              context: tester.element(find.byType(ElevatedButton)),
              builder: (context) => GameDialog(
                title: 'Test Dialog',
                content: Text('Content'),
              ),
            );
          },
          child: Text('Show Dialog'),
        ),
      ),
    ),
  );
  
  await tester.tap(find.text('Show Dialog'));
  await tester.pumpAndSettle();
  
  expect(find.text('Test Dialog'), findsOneWidget);
});
```

## Related Documentation

- [`../README.md`](../README.md) - Project overview
- [`ARCHITECTURE.md`](ARCHITECTURE.md) - Architecture documentation
- [`STATE_MANAGEMENT.md`](STATE_MANAGEMENT.md) - State management guide
- [`ANIMATION_GUIDELINES.md`](ANIMATION_GUIDELINES.md) - Animation standards
