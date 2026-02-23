<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.9-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Android-Suportado-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/iOS-Suportado-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS">
</p>

<h1 align="center">🎹👑 Piano Princess</h1>

<p align="center">
  <strong>Aplicativo mobile de piano interativo — aprenda músicas tocando nota a nota, acompanhe seu progresso e conquiste estrelas.</strong>
</p>

---

## 📋 Sobre o Projeto

**Piano Princess** é um aplicativo mobile desenvolvido em **Flutter** que transforma o aprendizado de piano em uma experiência gamificada e interativa.

A usuária toca as notas corretas em um teclado virtual na tela, seguindo a partitura de músicas armazenadas no **Cloud Firestore**. O app registra progresso, pontuação e estrelas conquistadas por música, tudo sincronizado em nuvem via Firebase.

---

## ✨ Funcionalidades

- 🔐 **Autenticação completa** — Login com e-mail/senha, **Login com Google** e recuperação de senha por e-mail
- 🎹 **Piano interativo** — Teclado virtual com 2 oitavas (C4–B5), notas naturais e sustenidas/bemóis
- 🎵 **Player de músicas** — Lê partituras do Firestore e guia a usuária nota a nota
- 🔊 **Engine de áudio real** — Sons de piano em `.wav` com suporte a **12 vozes simultâneas** via `flutter_soloud`
- ⭐ **Sistema de estrelas** — 0 a 3 estrelas por música, com pontuação e percentual de acerto
- 📊 **Progresso persistido** — Progresso de cada música salvo no Firestore em tempo real
- 👤 **Perfil de usuário** — Criação de perfil com nome e avatar ao cadastrar
- 🌈 **Design encantado** — Gradiente rosa/lilás/azul, Material 3, animações suaves e efeito de brilhos

---

## 🛠️ Stack Tecnológico

| Tecnologia | Versão | Uso |
|---|---|---|
| **Flutter** | 3.x | Framework multiplataforma |
| **Dart** | ^3.9.2 | Linguagem principal |
| **Firebase Auth** | ^5.0.0 | Autenticação (email + Google) |
| **Cloud Firestore** | ^5.0.0 | Banco de dados e partituras |
| **flutter_soloud** | ^2.0.0 | Engine de áudio (sons de piano) |
| **google_sign_in** | ^6.2.1 | Login com Google |
| **flutter_lints** | ^5.0.0 | Linting e boas práticas |
| **flutter_launcher_icons** | ^0.13.1 | Ícone do app |
| **flutter_native_splash** | ^2.4.0 | Splash screen nativa |

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                     # Entrada do app (inicializa Firebase)
├── app/
│   └── piano_princess_app.dart   # MaterialApp + rotas + tema
├── config/
│   └── app_constants.dart        # Cores, espaçamentos, rotas e mensagens
├── core/
│   └── extensions.dart           # Extensões de BuildContext, String, Color, List
├── audio/
│   └── piano_sound_engine.dart   # Engine de áudio (SoLoud, carrega .wav por nota)
├── data/
│   ├── models/
│   │   └── song_progress_model.dart  # Model de progresso (%, estrelas, score)
│   └── services/
│       ├── auth_service.dart     # Login, signup, Google, logout, reset senha
│       └── firestore_service.dart # Perfis, progresso e partituras
└── ui/
    ├── auth/
    │   ├── auth_gate.dart        # Roteamento autenticado/não autenticado
    │   ├── login_page.dart       # Tela de login
    │   └── signup_page.dart      # Tela de cadastro
    ├── player/
    │   ├── piano_player_page.dart # Tela principal do piano (modo paisagem)
    │   └── piano_keyboard.dart   # Widget do teclado interativo
    └── components/
        └── ui_components.dart    # Componentes reutilizáveis de UI
```

---

## 🎵 Como Funciona o Player

1. A usuária seleciona uma música no catálogo
2. A partitura é carregada do **Firestore** no formato:
   ```json
   {
     "score": [
       { "duration": 0,   "notes": ["C4"] },
       { "duration": 500, "notes": ["E4"] },
       { "duration": 500, "notes": ["G4"] }
     ]
   }
   ```
3. O app exibe a nota esperada na tela (em modo paisagem — imersivo)
4. A usuária toca a nota no teclado virtual; o som `.wav` é reproduzido instantaneamente
5. Acertos e erros são contados; ao final, as **estrelas são calculadas** e o progresso é salvo no Firestore

---

## 🔊 Engine de Áudio

O `PianoSoundEngine` usa **flutter_soloud** para:
- Carregar todos os 24 samples de piano (`.wav`) em memória ao iniciar
- Suportar até **12 vozes simultâneas** (sem fila/delay)
- Normalizar automaticamente sustenidos para bemóis (`C# → Db`, `D# → Eb`, etc.)

```
assets/audio/piano/
├── C4.wav  Db4.wav  D4.wav  Eb4.wav  E4.wav  F4.wav
├── Gb4.wav Ab4.wav  A4.wav  Bb4.wav  B4.wav
├── C5.wav  Db5.wav  D5.wav  Eb5.wav  E5.wav  F5.wav
└── Gb5.wav Ab5.wav  A5.wav  Bb5.wav  B5.wav
```

---

## ⭐ Sistema de Pontuação

| Estrelas | Critério |
|---|---|
| ⭐⭐⭐ Perfeito! | Sem erros ou mínimo de erros |
| ⭐⭐ Bom! | Poucos erros |
| ⭐ Iniciante | Muitos erros |
| Sem pontuação | Não concluído |

O progresso de cada música é salvo no Firestore com:
- `percent` — percentual de notas tocadas (0.0 a 1.0)
- `stars` — estrelas conquistadas (0 a 3)
- `bestScore` — melhor pontuação histórica
- `updatedAt` — data da última tentativa

---

## 🚀 Como Rodar

### Pré-requisitos

- **Flutter SDK** 3.x instalado
- **Android Studio** ou **VS Code** com extensões Flutter/Dart
- Conta no **Firebase** com projeto configurado
- Dispositivo físico ou emulador Android/iOS

### Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/samuca2k18/Piano-Princess.git
   cd Piano-Princess
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase:**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Ative **Authentication** (Email/Senha + Google)
   - Ative **Cloud Firestore**
   - Baixe o `google-services.json` (Android) e/ou `GoogleService-Info.plist` (iOS)
   - Coloque os arquivos nas pastas corretas (`android/app/` e `ios/Runner/`)

4. **Execute o app:**
   ```bash
   flutter run
   ```

### Build para Produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recomendado para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🎨 Design

- **Cores principais:**
  - 💜 Primário: `#B455FF` (roxo)
  - 💗 Accent: `#FF5BBE` (rosa)
  - 🔵 Fundo: `#F9F6FF` (lilás clarinho)
- **Gradiente de fundo:** `#FFE1F3 → #E7D7FF → #D6F2FF`
- **Material 3** com `ColorScheme.fromSeed`
- Animações de `200ms` (padrão) e `300ms` (longas)
- Efeito de brilhos animados (`SparklesPainter`) nas telas de auth

---

## 📦 Scripts Úteis

```bash
flutter pub get          # Instalar dependências
flutter run              # Rodar em modo debug
flutter build apk        # Build APK Android
flutter test             # Rodar testes
flutter analyze          # Análise estática do código
flutter pub outdated     # Ver dependências desatualizadas
flutter pub upgrade      # Atualizar dependências
```

---

## 🧪 Testes

O projeto possui a estrutura de testes em `test/`. Para rodar:

```bash
flutter test
```

---

## 🤝 Contribuindo

1. Faça um fork do repositório
2. Crie sua branch (`git checkout -b feature/minha-feature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona minha feature'`)
4. Push para a branch (`git push origin feature/minha-feature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT.

---

<p align="center">
  <strong>🎹 Piano Princess — Toque, aprenda e conquiste estrelas! 👑✨</strong>
</p>
