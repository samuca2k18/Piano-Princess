/// Model para rastrear progresso de uma música do Piano Princess
class SongProgressModel {
  final String songId;
  final double percent; // 0.0 a 1.0
  final int stars; // 0 a 3
  final int? bestScore;
  final DateTime updatedAt;

  const SongProgressModel({
    required this.songId,
    required this.percent,
    required this.stars,
    this.bestScore,
    required this.updatedAt,
  });

  /// Criar modelo vazio para testes
  factory SongProgressModel.empty(String songId) {
    return SongProgressModel(
      songId: songId,
      percent: 0.0,
      stars: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Converter de JSON (Firestore)
  factory SongProgressModel.fromJson(Map<String, dynamic> json, String songId) {
    return SongProgressModel(
      songId: songId,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      bestScore: json['bestScore'] as int?,
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Converter para JSON (para enviar ao Firestore)
  Map<String, dynamic> toJson() {
    return {
      'percent': percent,
      'stars': stars,
      if (bestScore != null) 'bestScore': bestScore,
      'updatedAt': updatedAt,
    };
  }

  /// Criar cópia com campos alterados
  SongProgressModel copyWith({
    String? songId,
    double? percent,
    int? stars,
    int? bestScore,
    DateTime? updatedAt,
  }) {
    return SongProgressModel(
      songId: songId ?? this.songId,
      percent: (percent ?? this.percent).clamp(0.0, 1.0),
      stars: (stars ?? this.stars).clamp(0, 3),
      bestScore: bestScore ?? this.bestScore,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obter percentual formatado (ex: "75%")
  String get percentFormatted {
    return '${(percent * 100).round()}%';
  }

  /// Obter estrelas formatadas (ex: "⭐⭐⭐")
  String get starsFormatted {
    return '⭐' * stars;
  }

  /// Obter descrição de status
  String get statusDescription {
    if (isCompleted) return 'Concluída';
    if (isStarted) return 'Em progresso';
    return 'Não iniciada';
  }

  /// Obter status de conclusão
  bool get isCompleted => percent >= 1.0;

  /// Obter status iniciado
  bool get isStarted => percent > 0.0;

  /// Obter status não iniciado
  bool get isNotStarted => percent == 0.0;

  /// Verificar se tem nota máxima (3 estrelas)
  bool get isPerfect => stars == 3;

  /// Obter categoria de desempenho
  String get performanceCategory {
    if (isPerfect) return '⭐⭐⭐ Perfeito!';
    if (stars == 2) return '⭐⭐ Bom!';
    if (stars == 1) return '⭐ Iniciante';
    return 'Sem pontuação';
  }

  /// Aumentar progresso em percentual (0-100)
  SongProgressModel incrementProgress(double percentagePoints) {
    final newPercent = (percent + (percentagePoints / 100)).clamp(0.0, 1.0);
    return copyWith(
      percent: newPercent,
      updatedAt: DateTime.now(),
    );
  }

  /// Definir estrelas (0-3) e atualizar
  SongProgressModel setStars(int newStars) {
    return copyWith(
      stars: newStars.clamp(0, 3),
      updatedAt: DateTime.now(),
    );
  }

  /// Completar música com pontuação
  SongProgressModel complete({
    required int finalStars,
    required int score,
  }) {
    return copyWith(
      percent: 1.0,
      stars: finalStars.clamp(0, 3),
      bestScore: score,
      updatedAt: DateTime.now(),
    );
  }

  /// Reiniciar progresso
  SongProgressModel reset() {
    return SongProgressModel.empty(songId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SongProgressModel &&
              runtimeType == other.runtimeType &&
              songId == other.songId &&
              percent == other.percent &&
              stars == other.stars;

  @override
  int get hashCode => songId.hashCode ^ percent.hashCode ^ stars.hashCode;

  @override
  String toString() =>
      'SongProgressModel(songId: $songId, progress: $percentFormatted, stars: $stars, status: $statusDescription)';
}

/// Parser auxiliar para DateTime do Firestore
DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  // Timestamp do Firestore
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}