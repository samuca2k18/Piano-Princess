import 'package:flutter/material.dart';

class PianoKeyboardTwoOctaves extends StatefulWidget {
  final void Function(String note)? onNoteOn;
  final void Function(String note)? onNoteOff;

  const PianoKeyboardTwoOctaves({
    super.key,
    this.onNoteOn,
    this.onNoteOff,
  });

  @override
  State<PianoKeyboardTwoOctaves> createState() => _PianoKeyboardTwoOctavesState();
}

class _PianoKeyboardTwoOctavesState extends State<PianoKeyboardTwoOctaves> {
  // pointerId -> note
  final Map<int, String> _activePointers = {};
  final Set<String> _pressedNotes = {};

  List<_KeyRect> _whiteKeys = [];
  List<_KeyRect> _blackKeys = [];
  Size _lastSize = Size.zero;

  // 2 oitavas (C4..B5) = 14 brancas
  static const List<String> _whiteNotes = [
    'C4','D4','E4','F4','G4','A4','B4',
    'C5','D5','E5','F5','G5','A5','B5',
  ];

  // Pretas: C#, D#, F#, G#, A# por oitava
  static const List<String> _blackNotes = [
    'C#4','D#4','F#4','G#4','A#4',
    'C#5','D#5','F#5','G#5','A#5',
  ];

  // Índices das brancas dentro da oitava: C=0 D=1 E=2 F=3 G=4 A=5 B=6
  // Pretas posicionadas "entre" brancas:
  // C# entre C(0) e D(1)
  // D# entre D(1) e E(2)
  // F# entre F(3) e G(4)
  // G# entre G(4) e A(5)
  // A# entre A(5) e B(6)
  static const List<int> _blackAnchorsWithinOctave = [0, 1, 3, 4, 5];

  void _buildKeyRects(Size size) {
    if (size == _lastSize && _whiteKeys.isNotEmpty) return;
    _lastSize = size;

    final w = size.width;
    final h = size.height;

    final whiteKeyCount = _whiteNotes.length; // 14
    final whiteW = w / whiteKeyCount;

    final blackW = whiteW * 0.62;
    final blackH = h * 0.62;

    // White rects
    _whiteKeys = [];
    for (int i = 0; i < whiteKeyCount; i++) {
      final left = i * whiteW;
      _whiteKeys.add(_KeyRect(
        note: _whiteNotes[i],
        rect: Rect.fromLTWH(left, 0, whiteW, h),
        isBlack: false,
      ));
    }

    // Black rects
    _blackKeys = [];
    // Duas oitavas -> para cada oitava, desloca 7 brancas
    for (int octave = 0; octave < 2; octave++) {
      for (int k = 0; k < 5; k++) {
        final anchor = _blackAnchorsWithinOctave[k]; // white index within octave
        final whiteIndexGlobal = octave * 7 + anchor;

        // centro entre a white[anchor] e white[anchor+1]
        final leftWhite = whiteIndexGlobal * whiteW;
        final blackLeft = leftWhite + whiteW - (blackW / 2);

        final note = _blackNotes[octave * 5 + k];
        _blackKeys.add(_KeyRect(
          note: note,
          rect: Rect.fromLTWH(blackLeft, 0, blackW, blackH),
          isBlack: true,
        ));
      }
    }
  }

  String? _hitTest(Offset p) {
    // primeiro preta (está por cima)
    for (final k in _blackKeys) {
      if (k.rect.contains(p)) return k.note;
    }
    for (final k in _whiteKeys) {
      if (k.rect.contains(p)) return k.note;
    }
    return null;
  }

  void _noteOn(int pointerId, String note) {
    _activePointers[pointerId] = note;
    if (_pressedNotes.add(note)) {
      widget.onNoteOn?.call(note);
    }
    setState(() {});
  }

  void _noteOff(int pointerId) {
    final note = _activePointers.remove(pointerId);
    if (note == null) return;

    // remove apenas se nenhum outro dedo estiver segurando a mesma nota
    if (!_activePointers.values.contains(note)) {
      _pressedNotes.remove(note);
      widget.onNoteOff?.call(note);
    }
    setState(() {});
  }

  void _movePointer(int pointerId, Offset pos) {
    final current = _activePointers[pointerId];
    final hit = _hitTest(pos);

    if (hit == null) {
      // saiu do teclado
      if (current != null) _noteOff(pointerId);
      return;
    }

    if (current == null) {
      _noteOn(pointerId, hit);
      return;
    }

    if (current != hit) {
      _noteOff(pointerId);
      _noteOn(pointerId, hit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _buildKeyRects(size);

        return Listener(
          onPointerDown: (e) {
            final hit = _hitTest(e.localPosition);
            if (hit != null) _noteOn(e.pointer, hit);
          },
          onPointerMove: (e) => _movePointer(e.pointer, e.localPosition),
          onPointerUp: (e) => _noteOff(e.pointer),
          onPointerCancel: (e) => _noteOff(e.pointer),
          child: Stack(
            children: [
              // White keys (base)
              Positioned.fill(
                child: Row(
                  children: _whiteKeys.map((k) {
                    final pressed = _pressedNotes.contains(k.note);
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          color: pressed ? cs.primary.withOpacity(0.18) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black.withOpacity(0.12)),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              k.note.replaceAll(RegExp(r'\d'), ''), // mostra C D E...
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black.withOpacity(0.45),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Black keys (overlay)
              ..._blackKeys.map((k) {
                final pressed = _pressedNotes.contains(k.note);
                return Positioned(
                  left: k.rect.left,
                  top: 0,
                  width: k.rect.width,
                  height: k.rect.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pressed ? cs.primary.withOpacity(0.85) : Colors.black.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                          color: Colors.black.withOpacity(0.22),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _KeyRect {
  final String note;
  final Rect rect;
  final bool isBlack;

  _KeyRect({
    required this.note,
    required this.rect,
    required this.isBlack,
  });
}
