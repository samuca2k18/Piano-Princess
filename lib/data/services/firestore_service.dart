import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== REFERENCIAS ====================
  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _songsRef() =>
      _db.collection('songs');

  CollectionReference<Map<String, dynamic>> _progressRef(String uid) =>
      _userRef(uid).collection('progress');

  // (opção 2) coleção de códigos “secretos” (para ativar modo professora)
  DocumentReference<Map<String, dynamic>> _teacherCodeRef(String code) =>
      _db.collection('teacherCodes').doc(code);

  // professores (cada professora tem um doc com o uid dela)
  DocumentReference<Map<String, dynamic>> _teacherRef(String teacherUid) =>
      _db.collection('teachers').doc(teacherUid);

  // ==================== USUARIOS ====================
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _userRef(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'role': 'student',          // ✅ default
      'inviteCode': null,         // ✅ código de ativação (se professora)
      'teacherId': null,          // ✅ uid da professora (se aluna)
      'level': 1,
      'xp': 0,
      'streakDays': 0,
      'minutesThisWeek': 0,
      'soundEnabled': true,
      'avatarUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _userRef(uid).set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _userRef(uid).snapshots().map((doc) => doc.data());
  }

  Future<Map<String, dynamic>?> getUserProfileOnce(String uid) async {
    final doc = await _userRef(uid).get();
    return doc.data();
  }

  Future<void> updateUserName({
    required String uid,
    required String name,
  }) async {
    await updateUserProfile(uid: uid, data: {'name': name.trim()});
  }

  Future<void> updateLastLogin(String uid) async {
    await _userRef(uid).set(
      {
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ==================== HELPER USUARIOS ====================
  Future<bool> userProfileExists(String uid) async {
    final doc = await _userRef(uid).get();
    return doc.exists;
  }

  Future<void> ensureUserProfileFromAuth({
    required String uid,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    final ref = _userRef(uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'name': name.trim().isEmpty ? 'Princesa' : name.trim(),
        'email': email.trim(),
        'role': 'student',
        'inviteCode': null,
        'teacherId': null,
        'level': 1,
        'xp': 0,
        'streakDays': 0,
        'minutesThisWeek': 0,
        'soundEnabled': true,
        'avatarUrl': avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await ref.set({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ==================== ROLE / PROFESSORA / ALUNA ====================

  /// ✅ Opção 2:
  /// 1) valida se existe teacherCodes/{code} com active=true
  /// 2) vira professora no users/{uid}
  /// 3) cria/atualiza teachers/{uid} com esse code
  Future<void> activateTeacherByCode({
    required String uid,
    required String code,
  }) async {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-argument',
        message: 'Código vazio.',
      );
    }

    // 1) validar código secreto no Firestore
    final codeDoc = await _teacherCodeRef(c).get();
    final data = codeDoc.data();
    final active = (data?['active'] as bool?) ?? false;

    if (!codeDoc.exists || !active) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Código inválido ou inativo.',
      );
    }

    // 2 + 3) transação para manter consistência
    await _db.runTransaction((tx) async {
      final userDocRef = _userRef(uid);
      final userSnap = await tx.get(userDocRef);

      final name = (userSnap.data()?['name'] as String?) ?? 'Professora';
      final email = (userSnap.data()?['email'] as String?) ?? '';

      // users/{uid}
      tx.set(userDocRef, {
        'role': 'teacher',
        'inviteCode': c,
        'teacherId': null, // professora não precisa disso
        'roleUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // teachers/{uid}
      tx.set(_teacherRef(uid), {
        'ownerUid': uid,
        'code': c,
        'name': name,
        'email': email,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  /// ✅ Aluna digita o código da professora (teachers.code)
  /// - encontra a professora
  /// - grava teacherId no users/{uid} e role student
  Future<void> connectStudentToTeacher({
    required String uid,
    required String teacherCode,
  }) async {
    final c = teacherCode.trim().toUpperCase();
    if (c.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-argument',
        message: 'Código vazio.',
      );
    }

    final q = await _db
        .collection('teachers')
        .where('code', isEqualTo: c)
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Professora não encontrada para esse código.',
      );
    }

    final teacherId = q.docs.first.id; // uid da professora

    await _userRef(uid).set({
      'role': 'student',
      'teacherId': teacherId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ desconectar a aluna da professora
  Future<void> disconnectFromTeacher({required String uid}) async {
    await _userRef(uid).set({
      'teacherId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // (opcional) ouvir só o role
  Stream<String> watchUserRole(String uid) {
    return _userRef(uid).snapshots().map((d) {
      final data = d.data();
      return (data?['role'] as String?) ?? 'student';
    });
  }

  // (opcional) ouvir teacherId
  Stream<String?> watchTeacherId(String uid) {
    return _userRef(uid).snapshots().map((d) {
      final data = d.data();
      return data?['teacherId'] as String?;
    });
  }

  // ==================== MUSICAS ====================
  Stream<List<Map<String, dynamic>>> watchSongs() {
    return _songsRef()
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<Map<String, dynamic>?> watchSong(String songId) {
    return _songsRef().doc(songId).snapshots().map((d) => d.data());
  }

  Future<Map<String, dynamic>?> getSongOnce(String songId) async {
    final doc = await _songsRef().doc(songId).get();
    return doc.data();
  }

  // ==================== PROGRESSO ====================
  Future<void> setSongProgress({
    required String uid,
    required String songId,
    required double percent,
    required int stars,
    int? bestScore,
  }) async {
    final p = percent.clamp(0.0, 1.0);
    final s = stars.clamp(0, 3);

    await _progressRef(uid).doc(songId).set({
      'percent': p,
      'stars': s,
      if (bestScore != null) 'bestScore': bestScore,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchSongProgress({
    required String uid,
    required String songId,
  }) {
    return _progressRef(uid).doc(songId).snapshots().map((doc) => doc.data());
  }

  Stream<List<Map<String, dynamic>>> watchUserProgressList(String uid) {
    return _progressRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
  
  // ==================== ALIASES (compat com TeacherCodePage) ====================

  /// TeacherCodePage usa esse nome: activateAsTeacher()
  Future<void> activateAsTeacher({
    required String uid,
    required String code, required String activationCode, required String name,
  }) {
    return activateTeacherByCode(uid: uid, code: code);
  }

  /// TeacherCodePage usa esse nome: connectStudentToTeacherByCode()
  Future<void> connectStudentToTeacherByCode({
    required String uid,
    required String code, required String teacherCode,
  }) {
    return connectStudentToTeacher(uid: uid, teacherCode: code);
  }

  /// TeacherCodePage usa esse nome: getMyTeacherCode()
  /// Retorna o código da professora (se for teacher), senão null
  Future<String?> getMyTeacherCode(String uid) async {
    // tenta pegar do doc teachers/{uid}
    final t = await _teacherRef(uid).get();
    final code = t.data()?['code'] as String?;
    if (code != null && code.trim().isNotEmpty) return code.trim();

    // fallback: pega do users/{uid}.inviteCode (caso ainda não tenha teachers/{uid})
    final u = await _userRef(uid).get();
    final invite = u.data()?['inviteCode'] as String?;
    if (invite != null && invite.trim().isNotEmpty) return invite.trim();

    return null;
  }

}
