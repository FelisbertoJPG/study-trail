/// Uma questão de múltipla escolha.
class Question {
  final String id;

  /// 1 = Fácil, 2 = Médio, 3 = Difícil.
  final int difficulty;
  final String prompt;

  /// Trecho de código opcional (XML/Kotlin) exibido em destaque.
  final String? code;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const Question({
    required this.id,
    required this.difficulty,
    required this.prompt,
    required this.code,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      difficulty: json['difficulty'] as int,
      prompt: json['prompt'] as String,
      code: json['code'] as String?,
      options: (json['options'] as List).cast<String>(),
      answerIndex: json['answerIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }

  String get difficultyLabel => switch (difficulty) {
        1 => 'Fácil',
        2 => 'Médio',
        _ => 'Difícil',
      };
}
