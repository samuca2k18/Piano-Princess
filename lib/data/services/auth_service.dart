import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ==================== SIGNUP ====================
  Future<UserCredential> signup(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Erro inesperado ao criar conta: $e');
    }
  }

  // ==================== LOGIN ====================
  Future<UserCredential> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Erro inesperado ao fazer login: $e');
    }
  }

  // ==================== LOGIN COM GOOGLE ====================
  Future<UserCredential> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Login cancelado.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erro ao entrar com Google: $e');
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Erro ao fazer logout: $e');
    }
  }

  // ==================== RESET PASSWORD ====================
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Erro ao redefinir senha: $e');
    }
  }

  // ==================== UPDATE PROFILE ====================
  Future<void> updateDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AuthException('Usuário não autenticado.');

      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Erro ao atualizar nome: $e');
    }
  }

  // ==================== HELPER METHODS ====================
  static String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Esse email já está cadastrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'Senha fraca. Use uma senha mais forte.';
      case 'user_model.dart-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'Email ou senha inválidos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem internet. Verifique sua conexão.';
      case 'account-exists-with-different-credential':
        return 'Esse email existe com outro método de login.';
      case 'popup-closed-by-user_model.dart':
        return 'Login cancelado.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}