import 'question.dart';
import 'study_module.dart';

/// Uma matéria (ex.: "Tecnologias Móveis"). Agrupa os módulos, que na trilha
/// funcionam como sub-trilhas que se desbloqueiam em sequência.
class Subject {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final int color;
  final List<StudyModule> modules;

  const Subject({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.modules,
  });

  /// Todas as questões da matéria (usado, por exemplo, no Modo Hardcore).
  List<Question> get allQuestions =>
      modules.expand((m) => m.questions).toList();

  int get totalLessons =>
      modules.fold(0, (sum, m) => sum + m.lessons.length);

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? 'school',
      color: int.parse(json['color'] as String? ?? '0xFF58CC02'),
      modules: (json['modules'] as List)
          .map((m) => StudyModule.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// O currículo completo do app: o conjunto de matérias.
class Curriculum {
  final String title;
  final String source;
  final List<Subject> subjects;

  const Curriculum({
    required this.title,
    required this.source,
    required this.subjects,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      title: json['title'] as String? ?? 'Aplicativo de Estudos',
      source: json['source'] as String? ?? '',
      subjects: (json['subjects'] as List)
          .map((s) => Subject.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
