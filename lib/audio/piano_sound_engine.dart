import 'package:flutter_soloud/flutter_soloud.dart';

class PianoSoundEngine {
  final SoLoud _so = SoLoud.instance;

  final Map<String, AudioSource> _srcByNote = {};
  bool _ready = false;

  bool get isReady => _ready;

  String _normalizeToFlat(String note) {
    return note
        .replaceAll('C#', 'Db')
        .replaceAll('D#', 'Eb')
        .replaceAll('F#', 'Gb')
        .replaceAll('G#', 'Ab')
        .replaceAll('A#', 'Bb');
  }

  Future<void> init(List<String> notes) async {
    await _so.init();

    // limite de vozes simultâneas (evita “fila”)
    _so.setMaxActiveVoiceCount(12);

    for (final raw in notes) {
      final note = _normalizeToFlat(raw);
      final src = await _so.loadAsset('assets/audio/piano/$note.wav');
      _srcByNote[note] = src;
    }

    _ready = true;
  }


  void play(String rawNote, {double volume = 1.0}) {
    if (!_ready) return;

    final note = _normalizeToFlat(rawNote);
    final src = _srcByNote[note];
    if (src == null) return;

    _so.play(src, volume: volume);
  }


  void dispose() {
    _so.deinit();
  }
}
