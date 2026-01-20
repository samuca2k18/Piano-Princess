import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _editName(BuildContext context, String uid, String currentName) async {
    final ctrl = TextEditingController(text: currentName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Nome da criança'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Ex: Maressa',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newName == null) return;
    if (newName.isEmpty) {
      _toast(context, 'Digite um nome válido.');
      return;
    }

    await FirestoreService.instance.updateUserProfile(
      uid: uid,
      data: {'name': newName},
    );

    _toast(context, 'Nome atualizado ✅');
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.logout();
    // ✅ não navega
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
          child: const Text('Ir para Login'),
        ),
      );
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: FirestoreService.instance.watchUserProfile(user.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data ?? {};

        final name = (data['name'] as String?)?.trim().isNotEmpty == true ? data['name'] as String : 'Princesa';
        final streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;
        final minutesThisWeek = (data['minutesThisWeek'] as num?)?.toInt() ?? 0;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withOpacity(0.88),
                ),
              ),
              const SizedBox(height: 12),

              // Card do perfil REAL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.16),
                      cs.secondary.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Icons.face_rounded, size: 34, color: cs.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? 'Piano Princess',
                            style: TextStyle(color: Colors.black.withOpacity(0.62)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _MiniStat(
                                label: 'Sequência',
                                value: '$streakDays dias',
                                icon: Icons.local_fire_department_rounded,
                                colorScheme: cs,
                              ),
                              const SizedBox(width: 10),
                              _MiniStat(
                                label: 'Semana',
                                value: '$minutesThisWeek min',
                                icon: Icons.timer_rounded,
                                colorScheme: cs,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Preferências
              _Card(
                title: 'Preferências',
                icon: Icons.tune_rounded,
                child: Column(
                  children: [
                    _TileButton(
                      title: 'Nome da criança',
                      subtitle: 'Alterar nome exibido',
                      icon: Icons.edit_rounded,
                      onTap: () => _editName(context, user.uid, name),
                    ),
                    const Divider(height: 1),
                    _TileButton(
                      title: 'Som do teclado',
                      subtitle: (data['soundEnabled'] ?? true) == true ? 'Ativado' : 'Desativado',
                      icon: Icons.volume_up_rounded,
                      onTap: () async {
                        final current = (data['soundEnabled'] ?? true) == true;
                        await FirestoreService.instance.updateUserProfile(
                          uid: user.uid,
                          data: {'soundEnabled': !current},
                        );
                        _toast(context, !current ? 'Som ativado 🔊' : 'Som desativado 🔇');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Dados
              _Card(
                title: 'Progresso & Dados',
                icon: Icons.storage_rounded,
                child: Column(
                  children: [
                    _TileButton(
                      title: 'Conquistas',
                      subtitle: 'Em breve (vamos ligar no banco)',
                      icon: Icons.emoji_events_rounded,
                      onTap: () => _toast(context, 'Conquistas: próxima etapa'),
                    ),
                    const Divider(height: 1),
                    _TileButton(
                      title: 'Histórico de músicas',
                      subtitle: 'Em breve (vamos ligar no banco)',
                      icon: Icons.history_rounded,
                      onTap: () => _toast(context, 'Histórico: próxima etapa'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              FilledButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.black.withOpacity(0.62), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TileButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(color: Colors.black.withOpacity(0.62))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
