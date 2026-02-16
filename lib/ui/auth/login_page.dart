import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piano_princess/core/extensions.dart';
import '../../config/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../components/ui_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService.instance;

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      context.showErrorSnackBar('Preenchimento campos obrigatórios');
      return;
    }

    if (!email.isValidEmail) {
      context.showErrorSnackBar('Email inválido');
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.login(email, password);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.instance.updateLastLogin(user.uid);
      }

      if (!mounted) return;
      context.showSuccessSnackBar('Login realizado! 🎉');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _loading = true);

    try {
      final cred = await _auth.loginWithGoogle();
      final user = cred.user;

      if (user != null) {
        await FirestoreService.instance.ensureUserProfileFromAuth(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Princesa',
          avatarUrl: user.photoURL,
        );
      }

      if (!mounted) return;
      context.showSuccessSnackBar('Bem-vinda! 👑');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      context.showErrorSnackBar('Digite seu email primeiro');
      return;
    }

    if (!email.isValidEmail) {
      context.showErrorSnackBar('Email inválido');
      return;
    }

    try {
      await _auth.resetPassword(email);
      if (!mounted) return;
      context.showSuccessSnackBar('Email de recuperação enviado ✅');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE1F3),
            Color(0xFFE7D7FF),
            Color(0xFFD6F2FF),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingXL,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                _buildHeader(),
                const SizedBox(height: 18),
                _buildLoginForm(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(AppConstants.primaryDarkColor),
                Color(AppConstants.accentColor),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Piano Princess',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Entre para continuar tocando ✨',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.62),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return SimpleCard(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      borderRadius: AppConstants.radiusXL,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailCtrl,
            hint: 'Email',
            icon: Icons.mail_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppConstants.paddingDefault),
          AuthTextField(
            controller: _passCtrl,
            hint: 'Senha',
            icon: Icons.lock_rounded,
            obscureText: _obscure,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
            ),
          ),
          const SizedBox(height: AppConstants.paddingDefault),
          Row(
            children: [
              TextButton(
                onPressed: _handleForgotPassword,
                child: const Text('Esqueci minha senha'),
              ),
              const Spacer(),
              _buildLevelBadge(),
            ],
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          PrimaryButton(
            label: 'Entrar',
            onPressed: _handleLogin,
            isLoading: _loading,
            icon: Icons.piano_rounded,
          ),
          const SizedBox(height: 14),
          _buildDivider(),
          const SizedBox(height: 14),
          SecondaryButton(
            label: 'Entrar com Google',
            onPressed: _handleGoogleLogin,
            icon: Icons.g_mobiledata_rounded,
          ),
          const SizedBox(height: 12),
          _buildSignupLink(),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(AppConstants.primaryDarkColor).withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(AppConstants.primaryDarkColor).withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 16),
          const SizedBox(width: 6),
          Text(
            'Nível 1',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.12))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'ou',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.12))),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Não tem conta? '),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text('Criar conta'),
        ),
      ],
    );
  }
}