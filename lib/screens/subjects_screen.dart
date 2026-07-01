import 'package:flutter/material.dart';

import '../data/progress_service.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'subject_trail_screen.dart';

/// Tela inicial do "Aplicativo de Estudos": lista as matérias (blocos).
/// Hoje há uma (Tecnologias Móveis); novas matérias entram aqui no futuro.
class SubjectsScreen extends StatelessWidget {
  final Curriculum curriculum;

  const SubjectsScreen({super.key, required this.curriculum});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const _Header(),
                ..._buildTrackSections(),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Agrupa as matérias por [Subject.track], preservando a ordem em que
  /// aparecem no JSON, e renderiza cada grupo com um cabeçalho próprio
  /// (ex.: "FACULDADE" e "CONCURSO — ANALISTA DE SISTEMAS...").
  List<Widget> _buildTrackSections() {
    final order = <String>[];
    final grouped = <String, List<Subject>>{};
    for (final s in curriculum.subjects) {
      if (!grouped.containsKey(s.track)) {
        order.add(s.track);
        grouped[s.track] = [];
      }
      grouped[s.track]!.add(s);
    }

    final widgets = <Widget>[];
    for (final track in order) {
      widgets.add(_TrackHeader(label: track));
      for (final s in grouped[track]!) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _SubjectCard(subject: s),
          ),
        );
      }
    }
    return widgets;
  }
}

class _TrackHeader extends StatelessWidget {
  final String label;
  const _TrackHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.8,
          height: 1.2,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final progress = ProgressService.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aplicativo de Estudos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Escolha uma matéria para começar',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.bolt, color: AppTheme.gold, size: 22),
              const SizedBox(width: 6),
              Text(
                '${progress.totalXp}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Text('XP', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 24),
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                '${progress.completedCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Text('lições', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = Color(subject.color);
    final progress = ProgressService.instance;
    final done = subject.modules
        .fold(0, (sum, m) => sum + progress.completedInModule(m.id));
    final total = subject.totalLessons;
    final ratio = total == 0 ? 0.0 : done / total;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SubjectTrailScreen(subject: subject)),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(AppTheme.iconFor(subject.icon), color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subject.modules.length} módulos · ${subject.subtitle}',
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFEDEDED),
                              valueColor: AlwaysStoppedAnimation(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$done/$total',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
            ],
          ),
        ),
      ),
    );
  }
}
