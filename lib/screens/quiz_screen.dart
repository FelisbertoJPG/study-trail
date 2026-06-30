import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/duo_button.dart';

/// Executa uma lição: apresenta as questões uma a uma, valida a resposta,
/// mostra a explicação e, ao final, exibe o resultado.
///
/// Retorna `true` via Navigator.pop quando a lição é concluída.
class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  final Color accent;

  const QuizScreen({super.key, required this.lesson, required this.accent});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;

  List<Question> get _questions => widget.lesson.questions;
  Question get _question => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  void _check() {
    if (_selected == null) return;
    setState(() {
      _checked = true;
      if (_selected == _question.answerIndex) _correct++;
    });
  }

  void _next() {
    if (_isLast) {
      _showResult();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _checked = false;
    });
  }

  void _showResult() {
    final total = _questions.length;
    final accuracy = (_correct / total * 100).round();
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ResultSheet(
        correct: _correct,
        total: total,
        accuracy: accuracy,
        xp: widget.lesson.xpReward,
        accent: widget.accent,
        onFinish: () {
          Navigator.of(context).pop(); // fecha a sheet
          Navigator.of(context).pop(true); // volta à trilha sinalizando conclusão
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + (_checked ? 1 : 0)) / _questions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(progress: progress, accent: widget.accent),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DifficultyChip(question: _question),
                    const SizedBox(height: 12),
                    Text(
                      _question.prompt,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    if (_question.code != null) ...[
                      const SizedBox(height: 14),
                      _CodeBlock(code: _question.code!),
                    ],
                    const SizedBox(height: 20),
                    for (var i = 0; i < _question.options.length; i++)
                      _OptionTile(
                        text: _question.options[i],
                        state: _stateFor(i),
                        onTap: _checked
                            ? null
                            : () => setState(() => _selected = i),
                      ),
                    if (_checked) ...[
                      const SizedBox(height: 8),
                      _Explanation(
                        correct: _selected == _question.answerIndex,
                        text: _question.explanation,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _BottomBar(
              checked: _checked,
              canCheck: _selected != null,
              isLast: _isLast,
              accent: widget.accent,
              onCheck: _check,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }

  _OptionState _stateFor(int i) {
    if (!_checked) {
      return _selected == i ? _OptionState.selected : _OptionState.idle;
    }
    if (i == _question.answerIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

class _TopBar extends StatelessWidget {
  final double progress;
  final Color accent;
  const _TopBar({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF999999)),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: const Color(0xFFEDEDED),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final Question question;
  const _DifficultyChip({required this.question});

  @override
  Widget build(BuildContext context) {
    final color = switch (question.difficulty) {
      1 => AppTheme.primary,
      2 => AppTheme.gold,
      _ => AppTheme.wrong,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        question.difficultyLabel.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFD6E5C8),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  const _OptionTile({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (border, fill, fg) = switch (state) {
      _OptionState.idle => (const Color(0xFFE0E0E0), Colors.white, AppTheme.ink),
      _OptionState.selected => (AppTheme.primary, const Color(0xFFF1FBE8), AppTheme.primaryDark),
      _OptionState.correct => (AppTheme.primary, const Color(0xFFE8FAD8), AppTheme.primaryDark),
      _OptionState.wrong => (AppTheme.wrong, const Color(0xFFFDE7E7), AppTheme.wrong),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                if (state == _OptionState.correct)
                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
                if (state == _OptionState.wrong)
                  const Icon(Icons.cancel, color: AppTheme.wrong, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  final bool correct;
  final String text;
  const _Explanation({required this.correct, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppTheme.primary : AppTheme.wrong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.info, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                correct ? 'Correto!' : 'Resposta correta destacada',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(height: 1.35, color: AppTheme.ink)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool checked;
  final bool canCheck;
  final bool isLast;
  final Color accent;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const _BottomBar({
    required this.checked,
    required this.canCheck,
    required this.isLast,
    required this.accent,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: checked
          ? DuoButton(
              label: isLast ? 'Finalizar' : 'Continuar',
              color: accent,
              onPressed: onNext,
            )
          : DuoButton(
              label: 'Verificar',
              color: accent,
              onPressed: canCheck ? onCheck : null,
            ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final int correct;
  final int total;
  final int accuracy;
  final int xp;
  final Color accent;
  final VoidCallback onFinish;

  const _ResultSheet({
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.xp,
    required this.accent,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: AppTheme.gold, size: 64),
          const SizedBox(height: 12),
          const Text(
            'Lição concluída!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Você acertou $correct de $total ($accuracy%)',
            style: const TextStyle(color: Color(0xFF777777), fontSize: 15),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: AppTheme.gold),
                const SizedBox(width: 6),
                Text(
                  '+$xp XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB8860B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          DuoButton(label: 'Continuar', color: accent, onPressed: onFinish),
        ],
      ),
    );
  }
}
