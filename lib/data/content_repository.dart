import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/subject.dart';

/// Carrega o currículo (matérias → módulos → questões) a partir do asset JSON.
class ContentRepository {
  static const _assetPath = 'assets/content/questions.json';

  Future<Curriculum> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Curriculum.fromJson(json);
  }
}
