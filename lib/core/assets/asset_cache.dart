import 'package:flutter/material.dart';

/// Asset cache for preloading and caching frequently used assets.
/// Prevents repeated asset loading and improves performance.
class AssetCache {
  AssetCache._();

  static final AssetCache _instance = AssetCache._();
  static AssetCache get instance => _instance;

  // Cached image providers
  ImageProvider? _paperNoiseImage;

  /// Get the paper noise texture image provider.
  /// Loads from asset on first access, returns cached instance on subsequent calls.
  ImageProvider get paperNoiseImage {
    _paperNoiseImage ??= const AssetImage('assets/images/paper_noise.png');
    return _paperNoiseImage!;
  }

  /// Preload all cached assets.
  /// Call this during app initialization to improve startup performance.
  static Future<void> preload(BuildContext context) async {
    await precacheImage(instance.paperNoiseImage, context);
  }

  /// Clear all cached assets.
  /// Use this when you need to free memory or reload assets.
  static void clear() {
    instance._paperNoiseImage = null;
  }
}
