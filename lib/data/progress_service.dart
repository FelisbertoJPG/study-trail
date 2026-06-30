import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../models/study_module.dart';

/// Guarda o progresso do usuário (lições concluídas e XP) de forma persistente.
///
/// É um singleton acessível via [ProgressService.instance] e notifica a UI
/// quando algo muda, para que as telas se reconstruam.
class ProgressService extends ChangeNotifier {
  ProgressService._();
  static final ProgressService instance = ProgressService._();

  static const _kCompleted = 'completed_lessons';
  static const _kXp = 'total_xp';
  static const _kIntroSeen = 'intro_seen_modules';

  late SharedPreferences _prefs;
  final Set<String> _completed = {};
  final Set<String> _introSeen = {};
  int _totalXp = 0;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _completed
      ..clear()
      ..addAll(_prefs.getStringList(_kCompleted) ?? const []);
    _introSeen
      ..clear()
      ..addAll(_prefs.getStringList(_kIntroSeen) ?? const []);
    _totalXp = _prefs.getInt(_kXp) ?? 0;
  }

  /// Se a mini-aula de um módulo já foi vista (para abrir automaticamente
  /// apenas na primeira visita).
  bool hasSeenIntro(String moduleId) => _introSeen.contains(moduleId);

  Future<void> markIntroSeen(String moduleId) async {
    if (_introSeen.add(moduleId)) {
      await _prefs.setStringList(_kIntroSeen, _introSeen.toList());
    }
  }

  int get totalXp => _totalXp;
  int get completedCount => _completed.length;

  bool isCompleted(String lessonId) => _completed.contains(lessonId);

  /// A primeira lição de cada módulo está sempre liberada; as demais só liberam
  /// quando a lição anterior é concluída.
  bool isUnlocked(Lesson lesson) {
    if (lesson.index == 0) return true;
    return _completed.contains('${lesson.moduleId}_l${lesson.index - 1}');
  }

  /// Quantas lições de um módulo já foram concluídas.
  int completedInModule(String moduleId) =>
      _completed.where((id) => id.startsWith('${moduleId}_l')).length;

  /// Um módulo está completo quando todas as suas lições foram concluídas.
  /// Usado para desbloquear o próximo módulo (sub-trilha) em sequência.
  bool isModuleCompleted(StudyModule module) =>
      module.lessons.isNotEmpty &&
      module.lessons.every((l) => _completed.contains(l.id));

  Future<void> completeLesson(Lesson lesson) async {
    final isNew = _completed.add(lesson.id);
    if (isNew) {
      _totalXp += lesson.xpReward;
      await _prefs.setStringList(_kCompleted, _completed.toList());
      await _prefs.setInt(_kXp, _totalXp);
    }
    notifyListeners();
  }

  Future<void> reset() async {
    _completed.clear();
    _introSeen.clear();
    _totalXp = 0;
    await _prefs.remove(_kCompleted);
    await _prefs.remove(_kIntroSeen);
    await _prefs.remove(_kXp);
    notifyListeners();
  }
}
