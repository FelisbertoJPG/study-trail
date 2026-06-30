import 'package:flutter/material.dart';

import '../models/study_module.dart';
import '../models/teaching_card.dart';

/// Mini-aula do módulo, apresentada como um popup de slides (PageView).
/// O conteúdo vem das unidades T00X e cada card aponta para as questões que
/// ajuda a responder.
///
/// Abra com [ModuleIntroScreen.show].
class ModuleIntroScreen extends StatefulWidget {
  final StudyModule module;

  const ModuleIntroScreen({super.key, required this.module});

  /// Abre a mini-aula. Retorna `true` se o usuário tocou em "Começar a lição"
  /// (sinal para seguir ao quiz) ou `null`/`false` se apenas fechou.
  static Future<bool?> show(BuildContext context, StudyModule module) {
    return Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => ModuleIntroScreen(module: module),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ModuleIntroScreen> createState() => _ModuleIntroScreenState();
}

class _ModuleIntroScreenState extends State<ModuleIntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<TeachingCard> get _cards => widget.module.teaching;
  bool get _isLast => _page == _cards.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop(true); // seguir para o quiz
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.module.color);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _TopBar(
                    module: widget.module,
                    color: color,
                    page: _page,
                    total: _cards.length,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _cards.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (_, i) =>
                          _CardView(card: _cards[i], color: color),
                    ),
                  ),
                  _BottomBar(
                    color: color,
                    isLast: _isLast,
                    onNext: _next,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final StudyModule module;
  final Color color;
  final int page;
  final int total;
  final VoidCallback onClose;

  const _TopBar({
    required this.module,
    required this.color,
    required this.page,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      color: color,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mini-aula · ${module.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(total, (i) {
              final active = i <= page;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  final TeachingCard card;
  final Color color;

  const _CardView({required this.card, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: Color(0xFF3C3C3C),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            card.body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF4B4B4B),
            ),
          ),
          if (card.code != null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  card.code!,
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
          if (card.linksTo.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.link_rounded, color: color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      card.linksTo,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Color color;
  final bool isLast;
  final VoidCallback onNext;

  const _BottomBar({
    required this.color,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onNext,
            child: Center(
              child: Text(
                isLast ? 'COMEÇAR A LIÇÃO' : 'PRÓXIMO',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
