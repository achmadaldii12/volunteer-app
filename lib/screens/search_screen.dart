import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';

class SearchScreen extends StatefulWidget {
  final bool embedded;
  final String? initialCategory;
  final ActivityType? initialType;
  final bool autofocus;
  const SearchScreen(
      {super.key, this.embedded = false, this.initialCategory, this.initialType, this.autofocus = false});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Set<String> _cats = {};
  ActivityType? _type;
  String? _city;
  bool _online = false;
  bool _onlyOpen = true;
  String _sort = 'terbaru';

  static const _sorts = {
    'terbaru': 'Aktivitas Terbaru',
    'terdekat': 'Tanggal Terdekat',
    'populer': 'Paling Diminati',
    'kuota': 'Kuota Terbanyak',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) _cats.add(widget.initialCategory!);
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _filterCount =>
      _cats.length + (_type != null ? 1 : 0) + (_city != null ? 1 : 0) + (_online ? 1 : 0) + (_onlyOpen ? 0 : 1);

  void _reset() => setState(() {
        _cats = {};
        _type = null;
        _city = null;
        _online = false;
        _onlyOpen = true;
      });

  Future<void> _openFilter() async {
    final s = context.read<AppState>();
    var cats = {..._cats};
    var type = _type;
    var city = _city;
    var online = _online;
    var onlyOpen = _onlyOpen;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 680),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scroll) => Column(children: [
            Expanded(
              child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(24, 0, 24, 12), children: [
                const Text('Filter Aktivitas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                const Text('Isu / Kategori', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in kCategories)
                    FilterChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: cats.contains(c.name),
                      onSelected: (v) => setM(() => v ? cats.add(c.name) : cats.remove(c.name)),
                    ),
                ]),
                const SizedBox(height: 20),
                const Text('Jenis aktivitas', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in ActivityType.values)
                    ChoiceChip(
                      avatar: Icon(typeIcon(t), size: 16),
                      label: Text(typeLabel(t)),
                      selected: type == t,
                      onSelected: (v) => setM(() => type = v ? t : null),
                    ),
                ]),
                const SizedBox(height: 20),
                const Text('Kota', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in s.cities)
                    ChoiceChip(label: Text(c), selected: city == c, onSelected: (v) => setM(() => city = v ? c : null)),
                ]),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hanya aktivitas online'),
                  subtitle: const Text('Bisa diikuti dari mana saja'),
                  value: online,
                  onChanged: (v) => setM(() => online = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hanya yang masih dibuka'),
                  subtitle: const Text('Sembunyikan aktivitas penuh / selesai'),
                  value: onlyOpen,
                  onChanged: (v) => setM(() => onlyOpen = v),
                ),
              ]),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setM(() {
                        cats = {};
                        type = null;
                        city = null;
                        online = false;
                        onlyOpen = true;
                      }),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _cats = cats;
                          _type = type;
                          _city = city;
                          _online = online;
                          _onlyOpen = onlyOpen;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final results = s.query(
        q: _ctrl.text, categories: _cats, type: _type, city: _city, onlineOnly: _online, onlyOpen: _onlyOpen, sort: _sort);
    final narrow = context.screenW < 700;

    final active = <Widget>[
      for (final c in _cats) _chip(c, () => setState(() => _cats = {..._cats}..remove(c))),
      if (_type != null) _chip(typeLabel(_type!), () => setState(() => _type = null)),
      if (_city != null) _chip(_city!, () => setState(() => _city = null)),
      if (_online) _chip('Online', () => setState(() => _online = false)),
      if (!_onlyOpen) _chip('Termasuk yang ditutup', () => setState(() => _onlyOpen = true)),
    ];

    final searchField = TextField(
      controller: _ctrl,
      autofocus: widget.autofocus,
      onChanged: (_) => setState(() {}),
      decoration: inputDeco(
        hintText: 'Cari aktivitas...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _ctrl.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_ctrl.clear)),
      ),
    );

    final filterBtn = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), padding: const EdgeInsets.symmetric(horizontal: 22)),
      onPressed: _openFilter,
      icon: const Icon(Icons.filter_alt_outlined),
      label: Text(_filterCount > 0 ? 'Filter ($_filterCount)' : 'Filter'),
    );

    final sortBtn = PopupMenuButton<String>(
      tooltip: '',
      position: PopupMenuPosition.under,
      onSelected: (v) => setState(() => _sort = v),
      itemBuilder: (_) => [
        for (final e in _sorts.entries)
          PopupMenuItem(value: e.key, child: Text(e.value, style: TextStyle(fontWeight: _sort == e.key ? FontWeight.w800 : FontWeight.w400))),
      ],
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.swap_vert, size: 20),
          const SizedBox(width: 8),
          Text('Urutkan: ${_sorts[_sort]}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );

    final content = SingleChildScrollView(
      child: Column(children: [
        PageWrap(
          maxWidth: 1240,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 32),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Cari Aktivitas, ', style: TextStyle(fontSize: narrow ? 26 : 36, fontWeight: FontWeight.w800)),
                TextSpan(text: '${results.length} aktivitas membutuhkan bantuanmu', style: TextStyle(fontSize: narrow ? 20 : 32, fontWeight: FontWeight.w400)),
              ]),
            ),
            const SizedBox(height: 22),
            if (narrow) ...[
              searchField,
              const SizedBox(height: 10),
              Row(children: [Expanded(child: filterBtn), const SizedBox(width: 10), Expanded(child: sortBtn)]),
            ] else
              Row(children: [
                Expanded(flex: 5, child: searchField),
                const Spacer(flex: 2),
                filterBtn,
                const SizedBox(width: 14),
                sortBtn,
              ]),
            if (active.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Wrap(spacing: 8, runSpacing: 6, children: active)),
                TextButton(onPressed: _reset, child: const Text('Hapus filter')),
              ]),
            ],
            const SizedBox(height: 24),
            if (results.isEmpty)
              EmptyState(
                icon: Icons.search_off,
                title: 'Aktivitas tidak ditemukan',
                subtitle: 'Coba kata kunci lain atau longgarkan filter pencarianmu.',
                action: OutlinedButton(onPressed: _reset, child: const Text('Reset filter')),
              )
            else
              ResponsiveWrap(minItemWidth: 270, maxCols: 4, spacing: 20, children: results.map((a) => ActivityCard(a)).toList()),
            const SizedBox(height: 56),
          ]),
        ),
        const SiteFooter(),
      ]),
    );

    return widget.embedded ? content : Scaffold(body: content);
  }

  Widget _chip(String label, VoidCallback onDelete) => InputChip(label: Text(label), onDeleted: onDelete);
}
