import 'package:flutter/material.dart';

import '../data/progress_service.dart';
import '../models/lesson.dart';
import '../models/study_module.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'hardcore_screen.dart';
import 'module_intro_screen.dart';
import 'quiz_screen.dart';

/// A trilha de uma matéria: os módulos aparecem como sub-trilhas em sequência,
/// onde um módulo só é liberado quando o anterior é concluído. Tocar em uma
/// lição abre a mini-aula e, em seguida, o quiz.
class SubjectTrailScreen extends StatelessWidget {
  final Subject subject;

  const SubjectTrailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.color);
    final progress = ProgressService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Modo Hardcore',
            icon: const Icon(Icons.local_fire_department_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HardcoreScreen(subject: subject),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') _confirmReset(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppTheme.wrong),
                    SizedBox(width: 10),
                    Text('Apagar progresso'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 48),
            child: Column(
              children: [
                for (var i = 0; i < subject.modules.length; i++)
                  _ModuleSection(
                    module: subject.modules[i],
                    unlocked: _moduleUnlocked(i),
                    isLastModule: i == subject.modules.length - 1,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// O 1º módulo está sempre liberado; os demais liberam quando o módulo
  /// anterior é totalmente concluído.
  bool _moduleUnlocked(int index) {
    if (index == 0) return true;
    return ProgressService.instance.isModuleCompleted(subject.modules[index - 1]);
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar progresso?'),
        content: const Text(
          'Isso vai zerar o XP e bloquear novamente todas as lições e módulos. '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.wrong),
            onPressed: () async {
              await ProgressService.instance.reset();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  final StudyModule module;
  final bool unlocked;
  final bool isLastModule;

  const _ModuleSection({
    required this.module,
    required this.unlocked,
    required this.isLastModule,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(module.color);
    final progress = ProgressService.instance;
    final completed = progress.isModuleCompleted(module);

    return Column(
      children: [
        _ModuleHeader(
          module: module,
          color: color,
          locked: !unlocked,
          completed: completed,
        ),
        for (var j = 0; j < module.lessons.length; j++)
          _TrailNode(
            module: module,
            lesson: module.lessons[j],
            color: color,
            enabled: unlocked,
            align: _alignFor(module.lessons[j].index),
          ),
        if (!isLastModule)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 2,
            width: 60,
            color: const Color(0xFFEDEDED),
          ),
      ],
    );
  }

  _NodeAlign _alignFor(int index) {
    return switch (index % 4) {
      0 => _NodeAlign.center,
      1 => _NodeAlign.right,
      2 => _NodeAlign.center,
      _ => _NodeAlign.left,
    };
  }
}

class _ModuleHeader extends StatelessWidget {
  final StudyModule module;
  final Color color;
  final bool locked;
  final bool completed;

  const _ModuleHeader({
    required this.module,
    required this.color,
    required this.locked,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF2F2F2) : color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            locked
                ? Icons.lock
                : (completed ? Icons.verified_rounded : AppTheme.iconFor(module.icon)),
            color: locked ? AppTheme.lockedDark : Colors.white,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    color: locked ? AppTheme.lockedDark : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                Text(
                  locked ? 'Conclua o módulo anterior para liberar' : module.subtitle,
                  style: TextStyle(
                    color: locked ? AppTheme.lockedDark : Colors.white70,
                    fontSize: 12.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NodeAlign { left, center, right }

class _TrailNode extends StatelessWidget {
  final StudyModule module;
  final Lesson lesson;
  final Color color;
  final bool enabled;
  final _NodeAlign align;

  const _TrailNode({
    required this.module,
    required this.lesson,
    required this.color,
    required this.enabled,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    final completed = progress.isCompleted(lesson.id);
    final unlocked = enabled && progress.isUnlocked(lesson);

    final alignment = switch (align) {
      _NodeAlign.left => const Alignment(-0.55, 0),
      _NodeAlign.center => Alignment.center,
      _NodeAlign.right => const Alignment(0.55, 0),
    };

    final nodeColor =
        completed ? AppTheme.gold : (unlocked ? color : AppTheme.locked);
    final shadow = completed
        ? const Color(0xFFE0A800)
        : (unlocked ? Color.lerp(color, Colors.black, 0.25)! : AppTheme.lockedDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: alignment,
        child: Column(
          children: [
            _NodeButton(
              color: nodeColor,
              shadow: shadow,
              completed: completed,
              locked: !unlocked,
              onTap: unlocked
                  ? () => _openLesson(context)
                  : () => _showLocked(context),
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: unlocked ? AppTheme.ink : AppTheme.lockedDark,
              ),
            ),
            Text(
              '${lesson.difficultyLabel} · ${lesson.questions.length} questões',
              style: TextStyle(
                fontSize: 12,
                color: unlocked ? const Color(0xFF888888) : AppTheme.lockedDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(BuildContext context) async {
    // 1) Mostra a mini-aula do módulo.
    if (module.hasTeaching) {
      final start = await ModuleIntroScreen.show(context, module);
      if (start != true) return; // usuário fechou sem começar
    }
    if (!context.mounted) return;

    // 2) Em seguida, o quiz da lição.
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(lesson: lesson, accent: color),
      ),
    );
    if (done == true) {
      await ProgressService.instance.completeLesson(lesson);
    }
  }

  void _showLocked(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conclua a lição anterior para liberar esta.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _NodeButton extends StatelessWidget {
  final Color color;
  final Color shadow;
  final bool completed;
  final bool locked;
  final VoidCallback onTap;

  const _NodeButton({
    required this.color,
    required this.shadow,
    required this.completed,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 66,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border(bottom: BorderSide(color: shadow, width: 6)),
        ),
        child: Icon(
          completed
              ? Icons.check_rounded
              : (locked ? Icons.lock : Icons.star_rounded),
          color: locked ? AppTheme.lockedDark : Colors.white,
          size: 34,
        ),
      ),
    );
  }
}
