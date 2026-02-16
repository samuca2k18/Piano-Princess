import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piano_princess/data/services/firestore_service.dart';
import 'package:piano_princess/ui/player/piano_player_page.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final TextEditingController _search = TextEditingController();
  String _selectedCategory = 'Todas';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openSong(String songId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PianoPlayerPage(songId: songId),
      ),
    );
  }

  List<SongItem> _mergeSongsWithProgress({
    required List<Map<String, dynamic>> songs,
    required Map<String, Map<String, dynamic>> progressBySongId,
  }) {
    return songs.map((s) {
      final id = s['id'] as String;
      final p = progressBySongId[id];

      return SongItem(
        id: id,
        title: (s['title'] as String?) ?? 'Sem título',
        subtitle: (s['subtitle'] as String?) ?? '',
        category: (s['category'] as String?) ?? 'Outros',
        minutes: (s['minutes'] as num?)?.toInt() ?? 0,
        progress: (p?['percent'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  List<SongItem> _applyFilters(List<SongItem> songs) {
    final q = _search.text.trim().toLowerCase();

    return songs.where((s) {
      final matchCategory = _selectedCategory == 'Todas' || s.category == _selectedCategory;
      final matchText = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.subtitle.toLowerCase().contains(q);
      return matchCategory && matchText;
    }).toList();
  }

  List<SongItem> _continuePlaying(List<SongItem> songs) {
    final list = List<SongItem>.from(songs)
      ..sort((a, b) => b.progress.compareTo(a.progress));
    return list.where((s) => s.progress > 0 && s.progress < 1).take(6).toList();
  }

  List<String> _buildCategories(List<SongItem> songs) {
    final set = <String>{};
    for (final s in songs) {
      if (s.category.trim().isNotEmpty) set.add(s.category.trim());
    }
    final cats = set.toList()..sort();
    return ['Todas', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Faça login para ver as músicas.'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.watchSongs(),
      builder: (context, songsSnap) {
        if (songsSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final songsRaw = songsSnap.data ?? [];

        if (songsRaw.isEmpty) {
          return const Center(child: Text('Nenhuma música cadastrada no banco.'));
        }

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirestoreService.instance.watchUserProgressList(user.uid),
          builder: (context, progSnap) {
            final progressList = progSnap.data ?? [];
            final progressBySongId = <String, Map<String, dynamic>>{
              for (final p in progressList) (p['id'] as String): p,
            };

            final songs = _mergeSongsWithProgress(
              songs: songsRaw,
              progressBySongId: progressBySongId,
            );

            final categories = _buildCategories(songs);
            final filtered = _applyFilters(songs);
            final continuePlaying = _continuePlaying(songs);

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                children: [
                  Text(
                    'Músicas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black.withOpacity(0.88),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Busca
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar música...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Continue tocando
                  if (continuePlaying.isNotEmpty) ...[
                    _SectionTitle(
                      title: 'Continue tocando',
                      actionText: 'Ver tudo',
                      onTap: () {
                        // pode melhorar depois: scroll até a lista
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: continuePlaying.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final song = continuePlaying[i];
                          return _ContinueCard(
                            song: song,
                            colorScheme: cs,
                            onTap: () => _openSong(song.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Categorias
                  _SectionTitle(
                    title: 'Categorias',
                    actionText: 'Limpar',
                    onTap: () => setState(() => _selectedCategory = 'Todas'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((c) {
                      final selected = c == _selectedCategory;
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = c),
                        selectedColor: cs.primary.withOpacity(0.18),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: selected ? cs.primary : Colors.black.withOpacity(0.78),
                        ),
                        side: BorderSide(color: cs.primary.withOpacity(selected ? 0.22 : 0.10)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Lista
                  Row(
                    children: [
                      const Text('Todas as músicas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Text(
                        '${filtered.length}',
                        style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...filtered.map((song) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SongTile(
                      song: song,
                      colorScheme: cs,
                      onTap: () => _openSong(song.id),
                    ),
                  )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class SongItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double progress; // 0..1
  final int minutes;

  const SongItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.progress,
    required this.minutes,
  });
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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final SongItem song;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.song,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (song.progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 240,
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.music_note_rounded, color: colorScheme.primary),
                ),
                const Spacer(),
                Text(
                  '$pct%',
                  style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              song.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              song.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black.withOpacity(0.62)),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: song.progress,
                minHeight: 8,
                backgroundColor: colorScheme.primary.withOpacity(0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final SongItem song;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SongTile({
    required this.song,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (song.progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.queue_music_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black.withOpacity(0.62)),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: song.progress,
                      minHeight: 8,
                      backgroundColor: colorScheme.primary.withOpacity(0.10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onTap,
                  child: const Text('Tocar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
