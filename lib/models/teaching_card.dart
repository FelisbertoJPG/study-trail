/// Um card da "mini-aula" de um módulo. Conteúdo extraído das unidades T00X,
/// com um vínculo explícito às questões que ele ajuda a responder.
class TeachingCard {
  final String title;
  final String body;

  /// Trecho de código opcional (XML/Kotlin).
  final String? code;

  /// Texto curto que conecta o conceito às questões do módulo.
  final String linksTo;

  const TeachingCard({
    required this.title,
    required this.body,
    required this.code,
    required this.linksTo,
  });

  factory TeachingCard.fromJson(Map<String, dynamic> json) {
    return TeachingCard(
      title: json['title'] as String,
      body: json['body'] as String,
      code: json['code'] as String?,
      linksTo: json['linksTo'] as String? ?? '',
    );
  }
}
