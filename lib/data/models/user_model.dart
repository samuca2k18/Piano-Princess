import 'package:cloud_firestore/cloud_firestore.dart';

/// Model para representar um usuário do Piano Princess
class UserModel {
  final String uid;
  final String name;
  final String email;

  // ✅ novos
  final String role; // 'student' | 'teacher'
  final String? inviteCode;

  final int level;
  final int xp;
  final int streakDays;
  final int minutesThisWeek;
  final bool soundEnabled;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.inviteCode,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.minutesThisWeek,
    required this.soundEnabled,
    this.avatarUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.updatedAt,
  });

  factory UserModel.empty() {
    final now = DateTime.now();
    return UserModel(
      uid: '',
      name: 'Princesa',
      email: '',
      role: 'student',
      inviteCode: null,
      level: 1,
      xp: 0,
      streakDays: 0,
      minutesThisWeek: 0,
      soundEnabled: true,
      createdAt: now,
      lastLoginAt: now,
      updatedAt: now,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      name: (json['name'] as String?) ?? 'Princesa',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'student',
      inviteCode: json['inviteCode'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      minutesThisWeek: (json['minutesThisWeek'] as num?)?.toInt() ?? 0,
      soundEnabled: (json['soundEnabled'] as bool?) ?? true,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'inviteCode': inviteCode,
      'level': level,
      'xp': xp,
      'streakDays': streakDays,
      'minutesThisWeek': minutesThisWeek,
      'soundEnabled': soundEnabled,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? inviteCode, // se quiser limpar, passe inviteCode: null explicitamente
    int? level,
    int? xp,
    int? streakDays,
    int? minutesThisWeek,
    bool? soundEnabled,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      inviteCode: inviteCode ?? this.inviteCode,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      minutesThisWeek: minutesThisWeek ?? this.minutesThisWeek,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isTeacher => role == 'teacher';

  int get nextLevelXp => level * 100;

  double get levelProgress => (xp % nextLevelXp) / nextLevelXp;

  bool get isNewUser {
    final now = DateTime.now();
    return now.difference(createdAt).inDays == 0;
  }

  bool get hasActiveStreak {
    final now = DateTime.now();
    final daysSinceLogin = now.difference(lastLoginAt).inDays;
    return daysSinceLogin <= 1;
  }

  String get levelDescription {
    switch (level) {
      case 1:
        return 'Iniciante';
      case 2:
        return 'Básico';
      case 3:
        return 'Intermediário';
      case 4:
        return 'Avançado';
      case 5:
        return 'Maestro';
      default:
        return 'Nível $level';
    }
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, role: $role, level: $level, xp: $xp)';
}

/// ✅ Parser auxiliar para DateTime do Firestore (agora com Timestamp)
DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}
