import 'question.dart';

/// Um nó da trilha (estilo Duolingo). Reúne algumas questões de uma mesma
/// faixa de dificuldade dentro de um módulo.
class Lesson {
  final String id;
  final String moduleId;

  /// Posição na trilha (0-based).
  final int index;
  final String title;

  /// Dificuldade representativa do nó (a maior entre suas questões).
  final int difficulty;
  final List<Question> questions;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.index,
    required this.title,
    required this.difficulty,
    required this.questions,
  });

  /// XP concedido ao concluir a lição.
  int get xpReward => questions.length * 10 * difficulty;

  String get difficultyLabel => switch (difficulty) {
        1 => 'Fácil',
        2 => 'Médio',
        _ => 'Difícil',
      };
}
