import 'package:flutter/material.dart';

/// Temporary placeholder for the app's theme setup.
///
/// In Phase 2 this will be replaced by a proper theme configuration
/// (light/dark themes, custom typography, colors, etc.).
class AppThemePlaceholder {
  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      );
}

