import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PaintDetailPage extends StatefulWidget {
  final String title;
  const PaintDetailPage({super.key, required this.title});

  @override
  State<PaintDetailPage> createState() => _PaintDetailPageState();
}

class _PaintDetailPageState extends State<PaintDetailPage> {
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redo = [];

  Color _color = const Color(0xFFB455FF);
  double _size = 10;
  bool _eraser = false;

  _Stroke? _current;

  // Fundo “papel”
  final Color _paper = const Color(0xFFFFFFFF);

  void _start(Offset p) {
    _redo.clear();
    _current = _Stroke(
      points: [p],
      color: _color,
      width: _size,
      eraser: _eraser,
    );
    setState(() {});
  }

  void _move(Offset p) {
    if (_current == null) return;
    _current!.points.add(p);
    setState(() {});
  }

  void _end() {
    if (_current == null) return;
    _strokes.add(_current!);
    _current = null;
    setState(() {});
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    _redo.add(_strokes.removeLast());
    setState(() {});
  }

  void _redoAction() {
    if (_redo.isEmpty) return;
    _strokes.add(_redo.removeLast());
    setState(() {});
  }

  void _clear() {
    _strokes.clear();
    _redo.clear();
    _current = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Paleta infantil
    final palette = <Color>[
      const Color(0xFFB455FF),
      const Color(0xFFff4d6d),
      const Color(0xFFffb703),
      const Color(0xFF2a9d8f),
      const Color(0xFF3a86ff),
      const Color(0xFF000000),
      const Color(0xFFFFFFFF),
    ];

    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Column(
          children: [
            // Topo minimalista (não é AppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: _undo,
                    icon: const Icon(Icons.undo_rounded),
                  ),
                  IconButton(
                    onPressed: _redoAction,
                    icon: const Icon(Icons.redo_rounded),
                  ),
                  IconButton(
                    onPressed: _clear,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),

            // Área do desenho (canvas)
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  return GestureDetector(
                    onPanStart: (d) => _start(d.localPosition),
                    onPanUpdate: (d) => _move(d.localPosition),
                    onPanEnd: (_) => _end(),
                    child: Stack(
                      children: [
                        // “Desenho” por enquanto: linhas fake (mock).
                        // Depois você troca por uma imagem (line art) em PNG.
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LineArtMockPainter(),
                          ),
                        ),

                        // Pintura por cima
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StrokesPainter(
                              strokes: _strokes,
                              current: _current,
                              paper: _paper,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Barra de ferramentas
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 22,
                    offset: const Offset(0, -10),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ToolButton(
                        selected: !_eraser,
                        label: 'Lápis',
                        icon: Icons.edit_rounded,
                        onTap: () => setState(() => _eraser = false),
                        colorScheme: cs,
                      ),
                      _ToolButton(
                        selected: _eraser,
                        label: 'Borracha',
                        icon: Icons.auto_fix_high_rounded,
                        onTap: () => setState(() => _eraser = true),
                        colorScheme: cs,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tamanho',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 140,
                            child: Slider(
                              value: _size,
                              min: 4,
                              max: 28,
                              onChanged: (v) => setState(() => _size = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Paleta de cores
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: palette.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final c = palette[i];
                        final selected = !_eraser && c.value == _color.value;
                        return _ColorDot(
                          color: c,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              _color = c;
                              _eraser = false; // trocar cor volta pro lápis
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dica/CTA
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dica: use a borracha para apagar e o desfazer para voltar.',
                          style: TextStyle(color: Colors.black.withOpacity(0.55)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Salvar desenho (próximo passo)')),
                          );
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Salvar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ToolButton({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary.withOpacity(0.16) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary.withOpacity(0.22) : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? colorScheme.primary : Colors.black.withOpacity(0.65)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w900, color: selected ? colorScheme.primary : Colors.black.withOpacity(0.75)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWhite = color.value == 0xFFFFFFFF;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: selected ? 3 : 1.5,
            color: selected
                ? Colors.black.withOpacity(0.75)
                : (isWhite ? Colors.black.withOpacity(0.20) : Colors.black.withOpacity(0.08)),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.08),
            )
          ],
        ),
        child: selected
            ? const Center(child: Icon(Icons.check_rounded, size: 18))
            : null,
      ),
    );
  }
}

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final bool eraser;

  _Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.eraser,
  });
}

class _StrokesPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? current;
  final Color paper;

  _StrokesPainter({required this.strokes, required this.current, required this.paper});

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo
    final bg = Paint()..color = paper;
    canvas.drawRect(Offset.zero & size, bg);

    void drawStroke(_Stroke s) {
      if (s.points.length < 2) return;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      if (s.eraser) {
        // “Borracha”: desenha com a cor do papel
        paint.color = paper;
      } else {
        paint.color = s.color;
      }

      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (int i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].dx, s.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final s in strokes) {
      drawStroke(s);
    }
    if (current != null) drawStroke(current!);
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) => true;
}

// “Desenho de contorno” fake só pra testar.
// Depois trocamos por imagem (line art) em PNG por cima/baixo.
class _LineArtMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black.withOpacity(0.70);

    final center = Offset(size.width * 0.5, size.height * 0.45);

    // Círculo “cabeça”
    canvas.drawCircle(Offset(center.dx, center.dy - 120), 55, p);

    // Corpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 200, height: 220),
        const Radius.circular(20),
      ),
      p,
    );

    // Estrelinhas (tema musical)
    for (final o in [
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.8, size.height * 0.28),
      Offset(size.width * 0.25, size.height * 0.68),
      Offset(size.width * 0.78, size.height * 0.70),
    ]) {
      canvas.drawCircle(o, 10, p);
    }

    // Nota musical
    final note = Path()
      ..moveTo(size.width * 0.62, size.height * 0.62)
      ..lineTo(size.width * 0.62, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.70, size.height * 0.46, size.width * 0.70, size.height * 0.53)
      ..quadraticBezierTo(size.width * 0.70, size.height * 0.60, size.width * 0.62, size.height * 0.62);
    canvas.drawPath(note, p);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.64), 18, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
