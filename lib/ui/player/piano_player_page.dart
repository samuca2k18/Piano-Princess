import 'package:piano_princess/audio/piano_sound_engine.dart';
import 'package:piano_princess/ui/player/piano_keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PianoPlayerPage extends StatefulWidget {
  final String songId;
  final String title;
  final String subtitle;
  final double progress; // 0..1

  const PianoPlayerPage({
    super.key,
    required this.songId,
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  @override
  State<PianoPlayerPage> createState() => _PianoPlayerPageState();
}

class _PianoPlayerPageState extends State<PianoPlayerPage> {
  late final PianoSoundEngine _sound;

  static const List<String> _notesToLoad = [
    'C4','Db4','D4','Eb4','E4','F4','Gb4','G4','Ab4','A4','Bb4','B4',
    'C5','Db5','D5','Eb5','E5','F5','Gb5','G5','Ab5','A5','Bb5','B5',
  ];


  @override
  void initState() {
    super.initState();

    // força horizontal (igual você já queria)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _sound = PianoSoundEngine();
    _sound.init(_notesToLoad); // pré-carrega os WAV
  }

  @override
  void dispose() {
    _sound.dispose();

    // volta normal ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo principal: Partitura + Teclado (lado a lado)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // PARTITURA (EM CIMA)
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                            color: Colors.black.withOpacity(0.06),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.library_music_rounded, color: cs.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: cs.primary.withOpacity(0.20)),
                                ),
                                child: Text(
                                  '${(widget.progress * 100).round()}%',
                                  style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: cs.primary.withOpacity(0.10)),
                              ),
                              child: Center(
                                child: Text(
                                  'Área da Partitura (placeholder)\nDepois entra PNG/SVG com zoom/scroll',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black.withOpacity(0.55)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TECLADO (EMBAIXO)
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.primary.withOpacity(0.14),
                              cs.secondary.withOpacity(0.10),
                            ],
                          ),
                        ),
                        // Sem padding, sem título, sem config — teclado ocupa tudo
                        child: Padding(
                          padding: const EdgeInsets.all(6), // pode colocar 0 se quiser colado total
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: PianoKeyboardTwoOctaves(
                              onNoteOn: (note) => _sound.play(note),
                              onNoteOff: (note) {}, // pode deixar vazio
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),

            ),

            // Botão voltar flutuante (sem AppBar)
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
