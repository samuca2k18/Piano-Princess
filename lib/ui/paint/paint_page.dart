import 'package:flutter/material.dart';
import 'package:piano_princess/ui/paint/paint_detail_page.dart';

class PaintPage extends StatefulWidget {
  const PaintPage({super.key});

  @override
  State<PaintPage> createState() => _PaintPageState();
}

class _PaintPageState extends State<PaintPage> {
  final TextEditingController _search = TextEditingController();
  String _selectedCategory = 'Todas';

  final List<ColoringItem> _items = const [
    ColoringItem(
      id: 'p1',
      title: 'Castelo Musical',
      subtitle: 'Princesas • Fácil',
      category: 'Princesas',
      done: false,
    ),
    ColoringItem(
      id: 'p2',
      title: 'Notas com Estrelas',
      subtitle: 'Teoria • Fácil',
      category: 'Teoria',
      done: true,
    ),
    ColoringItem(
      id: 'p3',
      title: 'Arco-íris das Claves',
      subtitle: 'Teoria • Médio',
      category: 'Teoria',
      done: false,
    ),
    ColoringItem(
      id: 'p4',
      title: 'Borboletas Dançantes',
      subtitle: 'Fofo • Fácil',
      category: 'Fofo',
      done: false,
    ),
    ColoringItem(
      id: 'p5',
      title: 'Doces & Notas',
      subtitle: 'Fofo • Fácil',
      category: 'Fofo',
      done: true,
    ),
  ];

  List<String> get _categories => const ['Todas', 'Princesas', 'Teoria', 'Fofo'];

  List<ColoringItem> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return _items.where((it) {
      final matchCategory = _selectedCategory == 'Todas' || it.category == _selectedCategory;
      final matchText = q.isEmpty ||
          it.title.toLowerCase().contains(q) ||
          it.subtitle.toLowerCase().contains(q);
      return matchCategory && matchText;
    }).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openColoring(ColoringItem it) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaintDetailPage(title: it.title),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Text(
            'Pintar',
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
              hintText: 'Buscar desenhos...',
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

          // Categorias
          Row(
            children: [
              const Text('Categorias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedCategory = 'Todas'),
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((c) {
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

          Row(
            children: [
              const Text('Galeria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(
                '${_filtered.length}',
                style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, i) {
              final it = _filtered[i];
              return _PaintCard(
                item: it,
                colorScheme: cs,
                onTap: () => _openColoring(it),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ColoringItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final bool done;

  const ColoringItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.done,
  });
}

class _PaintCard extends StatelessWidget {
  final ColoringItem item;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _PaintCard({
    required this.item,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
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
            // “Thumb” fake
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.16),
                      colorScheme.secondary.withOpacity(0.10),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.palette_rounded,
                        size: 44,
                        color: colorScheme.primary.withOpacity(0.85),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.done
                              ? Colors.green.withOpacity(0.12)
                              : Colors.black.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.done ? 'Concluído' : 'Novo',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: item.done ? Colors.green.shade700 : Colors.black.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
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
