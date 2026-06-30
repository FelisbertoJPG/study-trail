import 'package:flutter/material.dart';

/// Tema visual inspirado no Duolingo: cores vivas, cantos arredondados e
/// botões com "profundidade" (sombra inferior).
class AppTheme {
  static const Color primary = Color(0xFF58CC02); // verde
  static const Color primaryDark = Color(0xFF46A302);
  static const Color locked = Color(0xFFE5E5E5);
  static const Color lockedDark = Color(0xFFBDBDBD);
  static const Color ink = Color(0xFF3C3C3C);
  static const Color wrong = Color(0xFFFF4B4B);
  static const Color gold = Color(0xFFFFC800);

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
      ),
      scaffoldBackgroundColor: Colors.white,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// Mapeia o nome do ícone (vindo do JSON) para um IconData do Material.
  static IconData iconFor(String name) => switch (name) {
        'smartphone' => Icons.smartphone,
        'code' => Icons.code,
        'widgets' => Icons.widgets,
        'sync_alt' => Icons.sync_alt,
        'storage' => Icons.storage,
        'cloud' => Icons.cloud,
        // Modelagem de Software
        'design_services' => Icons.design_services,
        'insights' => Icons.insights,
        'account_tree' => Icons.account_tree,
        'schema' => Icons.schema,
        'person' => Icons.person,
        'timeline' => Icons.timeline,
        'extension' => Icons.extension,
        _ => Icons.school,
      };
}
