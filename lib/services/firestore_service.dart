import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Refs
  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> songsRef() => _db.collection('songs');

  CollectionReference<Map<String, dynamic>> progressRef(String uid) =>
      userRef(uid).collection('progress');

  // USERS
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await userRef(uid).set({
      'name': name.trim(),
      'email': email.trim(),
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
    await userRef(uid).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ✅ atalhos (pra bater com o Profile)
  Stream<Map<String, dynamic>?> watchUser(String uid) => watchUserProfile(uid);

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return userRef(uid).snapshots().map((doc) => doc.data());
  }

  Future<void> updateUserName({required String uid, required String name}) async {
    await updateUserProfile(uid: uid, data: {'name': name.trim()});
  }

  Future<void> updateUserPrefs({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await updateUserProfile(uid: uid, data: data);
  }

  Future<void> updateLastLogin(String uid) async {
    await userRef(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // SONGS
  Stream<List<Map<String, dynamic>>> watchSongs() {
    return songsRef()
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // PROGRESS
  Future<void> setSongProgress({
    required String uid,
    required String songId,
    required double percent, // 0..1
    required int stars, // 0..3
    int? bestScore,
  }) async {
    final p = percent.clamp(0.0, 1.0);
    final s = stars.clamp(0, 3);

    await progressRef(uid).doc(songId).set({
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
    return progressRef(uid).doc(songId).snapshots().map((doc) => doc.data());
  }

  Stream<List<Map<String, dynamic>>> watchUserProgressList(String uid) {
    return progressRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
