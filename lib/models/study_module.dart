import 'lesson.dart';
import 'question.dart';
import 'teaching_card.dart';

/// Um módulo (unidade temática) da matéria. Contém um conjunto de questões
/// que são organizadas em lições (nós da trilha) por ordem de dificuldade.
class StudyModule {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final int color;
  final List<Question> questions;
  final List<Lesson> lessons;
  final List<TeachingCard> teaching;

  const StudyModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.questions,
    required this.lessons,
    required this.teaching,
  });

  bool get isAvailable => lessons.isNotEmpty;
  bool get hasTeaching => teaching.isNotEmpty;

  factory StudyModule.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    final teaching = ((json['teaching'] as List?) ?? const [])
        .map((t) => TeachingCard.fromJson(t as Map<String, dynamic>))
        .toList();

    return StudyModule(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
      color: int.parse(json['color'] as String),
      questions: questions,
      lessons: _buildLessons(json['id'] as String, questions),
      teaching: teaching,
    );
  }

  /// Monta a "trilha de dificuldade": ordena as questões da mais fácil para a
  /// mais difícil e as agrupa em lições de no máximo [chunkSize] questões.
  static List<Lesson> _buildLessons(
    String moduleId,
    List<Question> questions, {
    int chunkSize = 3,
  }) {
    if (questions.isEmpty) return const [];

    final ordered = [...questions]
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));

    final lessons = <Lesson>[];
    for (var i = 0; i < ordered.length; i += chunkSize) {
      final slice = ordered.sublist(
        i,
        (i + chunkSize).clamp(0, ordered.length),
      );
      final index = lessons.length;
      final difficulty =
          slice.map((q) => q.difficulty).reduce((a, b) => a > b ? a : b);
      lessons.add(
        Lesson(
          id: '${moduleId}_l$index',
          moduleId: moduleId,
          index: index,
          title: 'Lição ${index + 1}',
          difficulty: difficulty,
          questions: slice,
        ),
      );
    }
    return lessons;
  }
}
