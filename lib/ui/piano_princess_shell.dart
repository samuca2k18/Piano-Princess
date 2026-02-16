import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:piano_princess/data/services/firestore_service.dart';
import 'package:piano_princess/ui/music/music_page.dart';
import 'package:piano_princess/ui/paint/paint_page.dart';
import 'package:piano_princess/ui/profile/profile_page.dart';
import 'package:piano_princess/ui/teacher/teacher_code_page.dart';
import 'package:piano_princess/ui/teacher/teacher_manage_page.dart';

class PianoPrincessShell extends StatefulWidget {
  const PianoPrincessShell({super.key});

  @override
  State<PianoPrincessShell> createState() => _PianoPrincessShellState();
}

class _PianoPrincessShellState extends State<PianoPrincessShell> {
  int _index = 0;

  void _openTeacherCode() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TeacherCodePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não logado')),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.watchUserProfile(uid),
      builder: (context, snap) {
        final profile = snap.data ?? const {};
        final role = (profile['role'] as String?) ?? 'student';
        final isTeacher = role == 'teacher';

        final pages = <Widget>[
          const _HomeEmptyPage(),
          const MusicPage(),
          const PaintPage(),
          const ProfilePage(),
          if (isTeacher) const TeacherManagePage(),
        ];

        final navItems = <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          const NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music_rounded),
            label: 'Músicas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.brush_outlined),
            selectedIcon: Icon(Icons.brush_rounded),
            label: 'Desenhos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
          if (isTeacher)
            const NavigationDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              selectedIcon: Icon(Icons.manage_accounts_rounded),
              label: 'Gestão',
            ),
        ];

        // ✅ se o usuário deixou de ser teacher e estava na aba "Gestão", ajusta
        if (_index >= pages.length) {
          _index = pages.length - 1;
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.music_note_rounded, color: cs.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Piano Princess'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                onPressed: _openTeacherCode,
                icon: const Icon(Icons.settings_outlined),
              ),
              const SizedBox(width: 6),
            ],
          ),

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: pages[_index],
            ),
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: navItems,
          ),
        );
      },
    );
  }
}

class _HomeEmptyPage extends StatelessWidget {
  const _HomeEmptyPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Text(
            'Bem-vinda ao Piano Princess 👑',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  color: Colors.black.withOpacity(0.06),
                )
              ],
            ),
            child: Text(
              'Escolha uma música, pinte desenhos ou treine suas notas 🎵',
              style: TextStyle(color: Colors.black.withOpacity(0.65)),
            ),
          ),
        ],
      ),
    );
  }
}
