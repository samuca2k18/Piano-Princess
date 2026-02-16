/// Constantes globais do aplicativo Piano Princess
abstract class AppConstants {
  // Cores
  static const int primaryColor = 0xFFB455FF;
  static const int primaryDarkColor = 0xFF8A5CFF;
  static const int accentColor = 0xFFFF5BBE;
  static const int bgColor = 0xFFF9F6FF;
  
  // Gradientes de fundo
  static const List<int> gradientColors = [
    0xFFFFE1F3,
    0xFFE7D7FF,
    0xFFD6F2FF,
  ];

  // Espaçamento padrão
  static const double paddingSmall = 8.0;
  static const double paddingDefault = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 18.0;
  static const double paddingXL = 24.0;

  // Border radius
  static const double radiusSmall = 10.0;
  static const double radiusDefault = 14.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 18.0;
  static const double radiusXL = 28.0;

  // Durações de animação
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 300);

  // Tamanhos
  static const double buttonHeight = 52.0;
  static const double smallButtonHeight = 48.0;
  static const double appBarHeight = 56.0;

  // Opacidades
  static const double opacityLight = 0.08;
  static const double opacityMedium = 0.12;
  static const double opacityHeavy = 0.18;
  static const double opacityText = 0.62;
  static const double opacityTextStrong = 0.88;
}

/// Caminhos de rotas
abstract class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String music = '/music';
  static const String paint = '/paint';
  static const String profile = '/profile';
}

/// Mensagens de erro padrão
abstract class AppMessages {
  static const String loadingError = 'Erro ao carregar. Tente novamente.';
  static const String networkError = 'Sem internet. Verifique sua conexão.';
  static const String unknownError = 'Erro desconhecido.';
  static const String emptyFieldError = 'Este campo não pode estar vazio.';
  static const String passwordMismatchError = 'As senhas não conferem.';
  static const String emailInvalidError = 'Email inválido.';
}
