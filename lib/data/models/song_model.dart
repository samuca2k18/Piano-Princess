/// Model para representar uma música do Piano Princess
class SongModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int minutes;
  final int difficulty; // 1-5
  final bool isActive;
  final int order;
  final List<dynamic> score; // Lista de notas
  final String? description;
  final DateTime createdAt;

  const SongModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.minutes,
    required this.difficulty,
    required this.isActive,
    required this.order,
    required this.score,
    this.description,
    required this.createdAt,
  });

  /// Criar modelo vazio para testes
  factory SongModel.empty() {
    return SongModel(
      id: '',
      title: 'Sem título',
      subtitle: '',
      category: 'Outros',
      minutes: 0,
      difficulty: 1,
      isActive: false,
      order: 0,
      score: [],
      createdAt: DateTime.now(),
    );
  }

  /// Converter de JSON (Firestore)
  factory SongModel.fromJson(Map<String, dynamic> json, String id) {
    return SongModel(
      id: id,
      title: (json['title'] as String?) ?? 'Sem título',
      subtitle: (json['subtitle'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Outros',
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      isActive: (json['isActive'] as bool?) ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
      score: (json['score'] as List?) ?? [],
      description: json['description'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  /// Converter para JSON (para enviar ao Firestore)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'minutes': minutes,
      'difficulty': difficulty,
      'isActive': isActive,
      'order': order,
      'score': score,
      'description': description,
      'createdAt': createdAt,
    };
  }

  /// Criar cópia com campos alterados
  SongModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    int? minutes,
    int? difficulty,
    bool? isActive,
    int? order,
    List<dynamic>? score,
    String? description,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      minutes: minutes ?? this.minutes,
      difficulty: difficulty ?? this.difficulty,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      score: score ?? this.score,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obter descrição de dificuldade
  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Muito Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Médio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muito Difícil';
      default:
        return 'Desconhecido';
    }
  }

  /// Obter ícone de dificuldade (estrelas)
  String get difficultyStars {
    return '⭐' * difficulty;
  }

  /// Obter cor de dificuldade
  int get difficultyColor {
    switch (difficulty) {
      case 1:
        return 0xFF4CAF50; // Verde
      case 2:
        return 0xFF8BC34A; // Verde claro
      case 3:
        return 0xFFFFC107; // Amarelo
      case 4:
        return 0xFFFF9800; // Laranja
      case 5:
        return 0xFFF44336; // Vermelho
      default:
        return 0xFF9E9E9E; // Cinza
    }
  }

  /// Obter número total de notas
  int get totalNotes => score.length;

  /// Obter duração formatada
  String get durationFormatted {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours h ${mins}min';
  }

  /// Obter nome do arquivo de capa (mock)
  String get coverAsset {
    return 'assets/songs/${id}_cover.png';
  }

  /// Verificar se tem partitura válida
  bool get hasValidScore {
    return score.isNotEmpty && score.length > 0;
  }

  /// Validar se a música é válida
  bool get isValid {
    return id.isNotEmpty &&
        title.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        difficulty >= 1 &&
        difficulty <= 5;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SongModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              category == other.category &&
              difficulty == other.difficulty;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ category.hashCode ^ difficulty.hashCode;

  @override
  String toString() =>
      'SongModel(id: $id, title: $title, difficulty: $difficulty, notes: $totalNotes)';
}

/// Model para rastrear progresso de uma música
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

  /// Criar modelo vazio
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

  /// Converter para JSON
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

  /// Obter percentual formatado
  String get percentFormatted {
    return '${(percent * 100).round()}%';
  }

  /// Obter estrelas formatadas
  String get starsFormatted {
    return '⭐' * stars;
  }

  /// Obter status de conclusão
  bool get isCompleted => percent >= 1.0;

  /// Obter status iniciado
  bool get isStarted => percent > 0.0;

  /// Obter status não iniciado
  bool get isNotStarted => percent == 0.0;

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
      'SongProgressModel(songId: $songId, progress: $percentFormatted, stars: $stars)';
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