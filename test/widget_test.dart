import 'package:flutter_test/flutter_test.dart';

import 'package:trilha_estudos/models/study_module.dart';
import 'package:trilha_estudos/models/question.dart';

void main() {
  test('StudyModule organiza as questões em lições por dificuldade', () {
    final module = StudyModule.fromJson({
      'id': 't999',
      'title': 'Teste',
      'subtitle': 'sub',
      'icon': 'code',
      'color': '0xFF000000',
      'questions': [
        for (var i = 0; i < 4; i++)
          {
            'id': 'q$i',
            'difficulty': i.isEven ? 1 : 3,
            'prompt': 'p$i',
            'code': null,
            'options': ['a', 'b'],
            'answerIndex': 0,
            'explanation': 'e$i',
          },
      ],
    });

    // 4 questões em chunks de 3 => 2 lições.
    expect(module.lessons.length, 2);
    // A primeira lição deve conter as questões mais fáceis primeiro.
    final firstDiffs =
        module.lessons.first.questions.map((Question q) => q.difficulty).toList();
    expect(firstDiffs.first, 1);
  });
}
