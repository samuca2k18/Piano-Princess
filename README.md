# 🎹 Piano Princess

**Piano Princess** é um aplicativo educacional de piano voltado para crianças, com foco em aprendizado progressivo, visual encantado e interação direta com teclado e partitura.  
O projeto combina **educação musical**, **gamificação** e **tecnologia moderna** usando Flutter + Firebase.

---

## ✨ Visão Geral

O objetivo do Piano Princess é tornar o aprendizado do piano:
- Divertido 🎀
- Visual 🎼
- Progressivo ⭐
- Seguro para crianças 👧👦

O app foi pensado para funcionar como uma **plataforma educativa**, com:
- Contas de usuário
- Progresso individual
- Histórico musical
- Evolução por níveis

---

## 🧩 Funcionalidades

### 🔐 Autenticação
- Login com email e senha (Firebase Auth)
- Criação de conta
- Recuperação de senha
- AuthGate (controle automático de sessão)

### 👤 Perfil do Usuário
- Nome editável
- Email
- Estatísticas:
  - Sequência de dias
  - Minutos semanais
- Preferências (ex: som do teclado)
- Logout seguro

### 🎼 Piano & Aprendizado
- Teclado interativo (toque direto na tela)
- Reprodução de notas individuais
- Layout horizontal:
  - Partitura na parte superior
  - Teclado ocupando toda a área inferior
- Estrutura pronta para:
  - Músicas por nível
  - Progresso por música
  - Sistema de estrelas / pontuação

### ☁️ Banco de Dados (Firestore)
- Perfil do usuário
- Catálogo de músicas
- Progresso por música
- Preparado para:
  - Conquistas
  - Histórico
  - Rankings
  - Backup em nuvem

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** (Material 3)
- **Firebase Authentication**
- **Cloud Firestore**
- **SoLoud / flutter_soloud** (áudio de baixa latência)
- **Arquitetura baseada em Services**
- **Design responsivo e infantil**

---

## 📁 Estrutura do Projeto

```text
lib/
├o
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
│
├── ui/
│   ├── auth/
│   │   ├── auth_gate.dart
│   │   ├── login_page.dart
│   │   └── signup_page.dart
│   │
│   ├── profile/
│   │   └── profile_page.dart
│   │
│   ├── piano/
│   │   ├── piano_page.dart
│   │   └── keyboard_widget.dart
│   │
│   └── piano_princess_shell.dart
│
└── main.dart
