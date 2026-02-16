import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:piano_princess/audio/piano_sound_engine.dart';
import 'package:piano_princess/ui/player/piano_keyboard.dart';
import 'package:piano_princess/data/services/firestore_service.dart';

class PianoPlayerPage extends StatefulWidget {
  final String songId;
  const PianoPlayerPage({super.key, required this.songId});

  @override
  State<PianoPlayerPage> createState() => _PianoPlayerPageState();
}

class _PianoPlayerPageState extends State<PianoPlayerPage> {
  late final PianoSoundEngine _sound;
  DateTime _lastAccept = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastPlayed;
  DateTime _lastPlayedAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const Duration _acceptCooldown = Duration(milliseconds: 220);
  static const Duration _sameNoteDebounce = Duration(milliseconds: 120);

  static const List<String> _notesToLoad = [
    'C4','Db4','D4','Eb4','E4','F4','Gb4','G4','Ab4','A4','Bb4','B4',
    'C5','Db5','D5','Eb5','E5','F5','Gb5','G5','Ab5','A5','Bb5','B5',
  ];

  int _index = 0;
  int _errors = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _sound = PianoSoundEngine();
    _sound.init(_notesToLoad);
  }

  @override
  void dispose() {
    _sound.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  /// 🔁 Normaliza o que vem do teclado (C#) para o formato que você usa no banco/assets (Db)
  String _normalizeNote(String n) {
    const map = {
      'C#4': 'Db4', 'D#4': 'Eb4', 'F#4': 'Gb4', 'G#4': 'Ab4', 'A#4': 'Bb4',
      'C#5': 'Db5', 'D#5': 'Eb5', 'F#5': 'Gb5', 'G#5': 'Ab5', 'A#5': 'Bb5',
    };
    return map[n] ?? n;
  }

  String _assetForNote(String note) => 'assets/notes/${_normalizeNote(note)}.png';

  /// ✅ Lê do Firestore no formato correto:
  /// score: [ {duration: 0, notes: ["C4"]}, {duration: 500, notes:["D4"]} ... ]
  String? _expectedNoteFromScore(List<dynamic> score, int idx) {
    if (idx < 0 || idx >= score.length) return null;

    final item = score[idx];

    if (item is Map) {
      final notes = item['notes'];

      // ✅ Caso correto: notes: ["C4"]
      if (notes is List && notes.isNotEmpty) {
        final first = notes.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }

      // ✅ Caso "bugado" no banco: notes: "D4"
      if (notes is String && notes.trim().isNotEmpty) {
        return notes.trim();
      }

      // compat: note: "C4"
      final n = item['note'];
      if (n is String && n.trim().isNotEmpty) return n.trim();
    }

    if (item is String && item.trim().isNotEmpty) return item.trim();
    return null;
  }


  void _handleNoteOn({
    required String played,
    required List<dynamic> score,
  }) {
    final now = DateTime.now();

    // ✅ Sempre toca o som (independente de cooldown/score)
    final playedN = _normalizeNote(played.trim());
    _sound.play(playedN);

    // Se terminou, pode tocar livre, mas não pontua
    if (_finished) return;

    // ✅ Debounce: evita repetir a MESMA nota 2x muito rápido (mas som já tocou)
    if (_lastPlayed == playedN && now.difference(_lastPlayedAt) < _sameNoteDebounce) {
      debugPrint('IGNORED score (same-note debounce) played=$playedN');
      return;
    }
    _lastPlayed = playedN;
    _lastPlayedAt = now;

    // ✅ Cooldown após acerto: evita que o “mesmo toque” avance e já erre na próxima
    if (now.difference(_lastAccept) < _acceptCooldown) {
      debugPrint('IGNORED score (cooldown) played=$playedN');
      return;
    }

    final expected = _expectedNoteFromScore(score, _index);
    if (expected == null) return;

    final expectedN = _normalizeNote(expected.trim());

    debugPrint('COMPARE played=$playedN expected=$expectedN index=$_index');

    if (playedN == expectedN) {
      _lastAccept = now;

      setState(() {
        _index++;
        if (_index >= score.length) _finished = true;
      });

      if (_finished && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Parabéns! Você concluiu!')),
        );
      }
    } else {
      setState(() => _errors++);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ops! Era $expectedN 😅 (você tocou $playedN)')),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.watchSong(widget.songId),
      builder: (context, songSnap) {
        if (songSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!songSnap.hasData || songSnap.data == null) {
          return const Scaffold(body: Center(child: Text('Música não encontrada.')));
        }

        final song = songSnap.data!;
        final title = (song['title'] as String?)?.trim().isNotEmpty == true
            ? song['title'] as String
            : 'Música';

        final subtitle = (song['subtitle'] as String?) ?? '';
        final List<dynamic> score = (song['score'] as List?) ?? const [];

        final expected = _expectedNoteFromScore(score, _index);

        debugPrint(
          'SCORE len=${score.length} index=$_index expected=$expected rawItem=${score.isNotEmpty && _index < score.length ? score[_index] : null}',
        );

        final pct = score.isEmpty ? 0 : ((_index / score.length) * 100).round();

        return Scaffold(
          backgroundColor: const Color(0xFFF9F6FF),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
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
                                      title,
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
                                      '$pct%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (subtitle.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black.withOpacity(0.62)),
                                ),
                              ],

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
                                    child: score.isEmpty
                                        ? Text(
                                      'Essa música ainda não tem score no banco.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black.withOpacity(0.55)),
                                    )
                                        : _finished
                                        ? const Text('Concluída 🎉')
                                        : SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Toque a nota:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black.withOpacity(0.75),
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          if (expected != null)
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxHeight: 140),
                                              child: Image.asset(
                                                _assetForNote(expected),
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => Text(
                                                  'Imagem não encontrada:\n${_assetForNote(expected)}',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                          const SizedBox(height: 8),
                                          if (expected != null)
                                            Text(
                                              _normalizeNote(expected),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: cs.primary,
                                              ),
                                            ),

                                          const SizedBox(height: 10),
                                          Text('Erros: $_errors', style: const TextStyle(color: Colors.black54)),
                                        ],
                                      ),
                                    )

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

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
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: PianoKeyboardTwoOctaves(
                                  onNoteOn: (played) => _handleNoteOn(
                                    played: played,
                                    score: score,
                                  ),
                                  onNoteOff: (_) {},
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
      },
    );
  }
}
