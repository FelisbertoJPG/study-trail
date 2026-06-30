import 'dart:math';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';

/// Modo Hardcore: até 20 questões aleatórias da matéria. Um único erro encerra
/// a partida — é preciso recomeçar do zero.
class HardcoreScreen extends StatefulWidget {
  final Subject subject;
  static const int maxQuestions = 20;

  const HardcoreScreen({super.key, required this.subject});

  @override
  State<HardcoreScreen> createState() => _HardcoreScreenState();
}

class _HardcoreScreenState extends State<HardcoreScreen> {
  late List<Question> _questions;
  int _index = 0;
  int? _selected;
  bool _checked = false;
  bool _dead = false;

  @override
  void initState() {
    super.initState();
    _newRun();
  }

  void _newRun() {
    final pool = [...widget.subject.allQuestions]..shuffle(Random());
    final count = min(HardcoreScreen.maxQuestions, pool.length);
    setState(() {
      _questions = pool.take(count).toList();
      _index = 0;
      _selected = null;
      _checked = false;
      _dead = false;
    });
  }

  Question get _q => _questions[_index];
  bool get _isLast => _index == _questions.length - 1;

  void _pick(int i) {
    if (_checked) return;
    final correct = i == _q.answerIndex;
    setState(() {
      _selected = i;
      _checked = true;
      _dead = !correct;
    });
    if (!correct) {
      _showGameOver();
    }
  }

  void _next() {
    if (_isLast) {
      _showVictory();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _checked = false;
    });
  }

  void _showGameOver() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _EndSheet(
        win: false,
        reached: _index + 1,
        total: _questions.length,
        onRetry: () {
          Navigator.of(context).pop();
          _newRun();
        },
        onExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showVictory() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _EndSheet(
        win: true,
        reached: _questions.length,
        total: _questions.length,
        onRetry: () {
          Navigator.of(context).pop();
          _newRun();
        },
        onExit: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14131C),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(index: _index, total: _questions.length, dead: _dead),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _q.prompt,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: Colors.white,
                      ),
                    ),
                    if (_q.code != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _q.code!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Color(0xFFD6E5C8),
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    for (var i = 0; i < _q.options.length; i++)
                      _OptionTile(
                        text: _q.options[i],
                        state: _stateFor(i),
                        onTap: () => _pick(i),
                      ),
                  ],
                ),
              ),
            ),
            if (_checked && !_dead)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: const Color(0xFF14131C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _next,
                    child: Text(
                      _isLast ? 'VENCER' : 'CONTINUAR',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _OptState _stateFor(int i) {
    if (!_checked) return _OptState.idle;
    if (i == _q.answerIndex) return _OptState.correct;
    if (i == _selected) return _OptState.wrong;
    return _OptState.idle;
  }
}

class _TopBar extends StatelessWidget {
  final int index;
  final int total;
  final bool dead;

  const _TopBar({required this.index, required this.total, required this.dead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : index / total,
                minHeight: 12,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Icon(
                dead ? Icons.heart_broken : Icons.favorite,
                color: dead ? Colors.white24 : AppTheme.wrong,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${index + 1}/$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _OptState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptState state;
  final VoidCallback onTap;

  const _OptionTile({required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (border, fill, fg) = switch (state) {
      _OptState.idle => (Colors.white24, const Color(0xFF1F1E2B), Colors.white),
      _OptState.correct => (AppTheme.primary, const Color(0xFF1E3320), Colors.white),
      _OptState.wrong => (AppTheme.wrong, const Color(0xFF3A1E22), Colors.white),
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
                    style: TextStyle(color: fg, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
                if (state == _OptState.correct)
                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 22),
                if (state == _OptState.wrong)
                  const Icon(Icons.cancel, color: AppTheme.wrong, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EndSheet extends StatelessWidget {
  final bool win;
  final int reached;
  final int total;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _EndSheet({
    required this.win,
    required this.reached,
    required this.total,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final color = win ? AppTheme.primary : AppTheme.wrong;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            win ? Icons.emoji_events : Icons.heart_broken,
            color: win ? AppTheme.gold : AppTheme.wrong,
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            win ? 'Você venceu o Hardcore!' : 'Game Over',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            win
                ? 'Acertou todas as $total questões seguidas. Lendário!'
                : 'Você chegou à questão $reached de $total. Um erro e acabou — bora de novo!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF777777), fontSize: 15),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onRetry,
              child: const Text(
                'JOGAR DE NOVO',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onExit,
            child: const Text('Sair', style: TextStyle(color: Color(0xFF777777))),
          ),
        ],
      ),
    );
  }
}
