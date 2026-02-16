import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piano_princess/core/extensions.dart';

import '../../config/app_constants.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../components/ui_components.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _editName(
      BuildContext context,
      String uid,
      String currentName,
      ) async {
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

    if (newName == null || newName.isEmpty) {
      if (!context.mounted) return;
      context.showErrorSnackBar('Digite um nome válido');
      return;
    }

    try {
      await FirestoreService.instance.updateUserProfile(
        uid: uid,
        data: {'name': newName},
      );
      if (!context.mounted) return;
      context.showSuccessSnackBar('Nome atualizado ✅');
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorSnackBar(e.toString());
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.instance.logout();
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (_) => false,
          ),
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
        final profile = _buildProfile(data);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingDefault,
              AppConstants.paddingMedium,
              AppConstants.paddingLarge,
            ),
            children: [
              const PageHeader(title: 'Perfil'),
              const SizedBox(height: AppConstants.paddingDefault),
              _buildProfileCard(context, user, profile),
              const SizedBox(height: AppConstants.paddingDefault),
              _buildPreferencesSection(context, user.uid, data),
              const SizedBox(height: AppConstants.paddingDefault),
              _buildDataSection(context),
              const SizedBox(height: AppConstants.paddingMedium),
              PrimaryButton(
                label: 'Sair',
                onPressed: () => _logout(context),
                icon: Icons.logout_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  _UserProfile _buildProfile(Map<String, dynamic> data) {
    return _UserProfile(
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'Princesa',
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      minutesThisWeek: (data['minutesThisWeek'] as num?)?.toInt() ?? 0,
    );
  }

  Widget _buildProfileCard(
      BuildContext context,
      User user,
      _UserProfile profile,
      ) {
    final cs = Theme.of(context).colorScheme;

    return GradientCard(
      borderRadius: AppConstants.radiusLarge,
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
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? 'Piano Princess',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.62),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMiniStat(
                      context,
                      'Sequência',
                      '${profile.streakDays} dias',
                      Icons.local_fire_department_rounded,
                    ),
                    const SizedBox(width: 10),
                    _buildMiniStat(
                      context,
                      'Semana',
                      '${profile.minutesThisWeek} min',
                      Icons.timer_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    final cs = Theme.of(context).colorScheme;

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
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.62),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
      BuildContext context,
      String uid,
      Map<String, dynamic> data,
      ) {
    return _ProfileSection(
      title: 'Preferências',
      icon: Icons.tune_rounded,
      children: [
        _PreferencesTile(
          title: 'Nome da criança',
          subtitle: 'Alterar nome exibido',
          icon: Icons.edit_rounded,
          onTap: () {
            final name = (data['name'] as String?)?.trim() ?? 'Princesa';
            _editName(context, uid, name);
          },
        ),
        const Divider(height: 1),
        _PreferencesTile(
          title: 'Som do teclado',
          subtitle: (data['soundEnabled'] ?? true) == true
              ? 'Ativado'
              : 'Desativado',
          icon: Icons.volume_up_rounded,
          onTap: () async {
            final current = (data['soundEnabled'] ?? true) == true;
            await FirestoreService.instance.updateUserProfile(
              uid: uid,
              data: {'soundEnabled': !current},
            );
            if (!context.mounted) return;
            context.showSuccessSnackBar(
              !current ? 'Som ativado 🔊' : 'Som desativado 🔇',
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return _ProfileSection(
      title: 'Progresso & Dados',
      icon: Icons.storage_rounded,
      children: [
        _PreferencesTile(
          title: 'Conquistas',
          subtitle: 'Em breve (próxima etapa)',
          icon: Icons.emoji_events_rounded,
          onTap: () => context.showSnackBar('Conquistas: próxima etapa'),
        ),
        const Divider(height: 1),
        _PreferencesTile(
          title: 'Histórico de músicas',
          subtitle: 'Em breve (próxima etapa)',
          icon: Icons.history_rounded,
          onTap: () => context.showSnackBar('Histórico: próxima etapa'),
        ),
      ],
    );
  }
}

class _UserProfile {
  final String name;
  final int streakDays;
  final int minutesThisWeek;

  const _UserProfile({
    required this.name,
    required this.streakDays,
    required this.minutesThisWeek,
  });
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusDefault),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _PreferencesTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PreferencesTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingDefault,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.62),
                      ),
                    ),
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