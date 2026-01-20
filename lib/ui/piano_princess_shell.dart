import 'package:flutter/material.dart';
import 'package:piano_princess/ui/music/music_page.dart';
import 'package:piano_princess/ui/paint/paint_page.dart';
import 'package:piano_princess/ui/profile/profile_page.dart';

class PianoPrincessShell extends StatefulWidget {
  const PianoPrincessShell({super.key});

  @override
  State<PianoPrincessShell> createState() => _PianoPrincessShellState();
}

class _PianoPrincessShellState extends State<PianoPrincessShell> {
  int _index = 0;

  final _pages = const [
    _HomeEmptyPage(),
    MusicPage(),
    PaintPage(),
    ProfilePage(),
  ];



  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // TOP BAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo depois a gente troca por Image.asset(...)
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
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),

      // BODY (HOME VAZIA POR ENQUANTO)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_index],
      ),

      // BOTTOM NAV BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music_rounded),
            label: 'Músicas',
          ),
          NavigationDestination(
            icon: Icon(Icons.brush_outlined),
            selectedIcon: Icon(Icons.brush_rounded),
            label: 'Desenhos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// HOME VAZIA (A GENTE VAI PREENCHER DEPOIS)
class _HomeEmptyPage extends StatelessWidget {
  const _HomeEmptyPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          _GreetingHeader(colorScheme: cs),
          const SizedBox(height: 12),
          _ProgressCard(colorScheme: cs),
          const SizedBox(height: 12),
          _AchievementsRow(colorScheme: cs),
          const SizedBox(height: 18),

          _SectionTitle(
            title: 'Continue tocando',
            actionText: 'Ver tudo',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _HorizontalCards(
            items: const [
              _CardItem(title: 'Brilha Brilha Estrelinha', subtitle: 'Iniciante • 60%'),
              _CardItem(title: 'A Bela e a Fera', subtitle: 'Iniciante • 20%'),
              _CardItem(title: 'Parabéns Pra Você', subtitle: 'Iniciante • 0%'),
            ],
            colorScheme: cs,
            leadingIcon: Icons.queue_music_rounded,
          ),

          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Jogos',
            actionText: 'Explorar',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _HorizontalCards(
            items: const [
              _CardItem(title: 'Acerte as Notas', subtitle: 'Treino rápido'),
              _CardItem(title: 'Memória Musical', subtitle: 'Combine pares'),
              _CardItem(title: 'Ritmo da Coroa', subtitle: 'Siga o tempo'),
            ],
            colorScheme: cs,
            leadingIcon: Icons.extension_rounded,
          ),

          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Pintar',
            actionText: 'Abrir',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _HorizontalCards(
            items: const [
              _CardItem(title: 'Notas com Estrelas', subtitle: 'Colorir e aprender'),
              _CardItem(title: 'Castelo Musical', subtitle: 'Tema princesa'),
              _CardItem(title: 'Arco-íris das Claves', subtitle: 'Diversão'),
            ],
            colorScheme: cs,
            leadingIcon: Icons.brush_rounded,
          ),

          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Exercícios',
            actionText: 'Começar',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _HorizontalCards(
            items: const [
              _CardItem(title: 'Dedos 1–5', subtitle: 'Coordenação'),
              _CardItem(title: 'Mão Direita', subtitle: '5 minutos'),
              _CardItem(title: 'Mão Esquerda', subtitle: '5 minutos'),
            ],
            colorScheme: cs,
            leadingIcon: Icons.fitness_center_rounded,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  const _GreetingHeader({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.14),
            colorScheme.secondary.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Princesa 👑',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Vamos treinar um pouquinho hoje?',
                  style: TextStyle(color: Colors.black.withOpacity(0.62)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _ProgressCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    const progress = 0.42; // fake por enquanto

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Seu progresso',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.88),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.primary.withOpacity(0.10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Meta de hoje: 10 minutos • Sequência: 3 dias',
            style: TextStyle(color: Colors.black.withOpacity(0.62)),
          ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final ColorScheme colorScheme;
  const _AchievementsRow({required this.colorScheme});

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
              Icon(Icons.emoji_events_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Conquistas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.88),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AchievementChip(
                label: '1ª Música',
                icon: Icons.music_note_rounded,
                colorScheme: colorScheme,
              ),
              _AchievementChip(
                label: '3 dias seguidos',
                icon: Icons.local_fire_department_rounded,
                colorScheme: colorScheme,
              ),
              _AchievementChip(
                label: 'Dedos 1–5',
                icon: Icons.back_hand_rounded,
                colorScheme: colorScheme,
              ),
              _AchievementChip(
                label: 'Jogo completo',
                icon: Icons.extension_rounded,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;

  const _AchievementChip({
    required this.label,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionTitle({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(actionText),
        ),
      ],
    );
  }
}

class _CardItem {
  final String title;
  final String subtitle;
  const _CardItem({required this.title, required this.subtitle});
}

class _HorizontalCards extends StatelessWidget {
  final List<_CardItem> items;
  final ColorScheme colorScheme;
  final IconData leadingIcon;

  const _HorizontalCards({
    required this.items,
    required this.colorScheme,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return _FeatureCard(
            title: item.title,
            subtitle: item.subtitle,
            colorScheme: colorScheme,
            icon: leadingIcon,
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 220,
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black.withOpacity(0.62)),
            ),
          ],
        ),
      ),
    );
  }
}


// PÁGINAS PLACEHOLDER
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
