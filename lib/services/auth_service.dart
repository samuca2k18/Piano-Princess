import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // -----------------------------
  // SIGNUP
  // -----------------------------
  Future<UserCredential> signup(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageFromCode(e.code));
    }
  }

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageFromCode(e.code));
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<void> logout() async {
    await _auth.signOut();
  }

  // -----------------------------
  // RESET PASSWORD
  // -----------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageFromCode(e.code));
    }
  }

  // -----------------------------
  // (Opcional) Atualizar nome no Auth
  // -----------------------------
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  // -----------------------------
  // Mensagens amigáveis
  // -----------------------------
  static String messageFromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Esse email já está cadastrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'Senha fraca. Use uma senha mais forte.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'Email ou senha inválidos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem internet. Verifique sua conexão.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
