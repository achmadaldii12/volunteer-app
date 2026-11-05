import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({super.key});
  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen> {
  final _ctrl = TextEditingController();
  String? _province, _focus, _type;
  String _sort = 'terbaru';

  static const _sorts = {
    'terbaru': 'Aktivitas Terbaru',
    'nama': 'Nama (A-Z)',
    'relawan': 'Relawan Terbanyak',
    'jam': 'Jam Terbanyak',
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _reset() => setState(() {
        _ctrl.clear();
        _province = null;
        _focus = null;
        _type = null;
        _sort = 'terbaru';
      });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.queryOrgs(q: _ctrl.text, province: _province, focus: _focus, type: _type, sort: _sort);
    final provinces = (s.allOrgs.map((o) => provinceOf(o.city)).where((p) => p.isNotEmpty).toSet().toList())..sort();
    final types = (s.allOrgs.map((o) => o.type).toSet().toList())..sort();

    Widget label(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        );

    final filter = AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cari berdasarkan nama:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(controller: _ctrl, onChanged: (_) => setState(() {}), decoration: inputDeco(hintText: 'Cari organisasi')),
        Divider(height: 32, color: context.line),
        label('Provinsi:'),
        SelectField(hint: 'Semua provinsi', value: _province, options: provinces, onChanged: (v) => setState(() => _province = v)),
        label('Fokus Organisasi:'),
        SelectField(hint: 'Pilih fokus', value: _focus, options: kCategories.map((c) => c.name).toList(), onChanged: (v) => setState(() => _focus = v)),
        label('Tipe Organisasi:'),
        SelectField(hint: 'Pilih tipe organisasi', value: _type, options: types, onChanged: (v) => setState(() => _type = v)),
        Divider(height: 32, color: context.line),
        label('Urutkan berdasarkan:'),
        SelectField(
            hint: 'Urutkan',
            value: _sort,
            allowClear: false,
            options: _sorts.keys.toList(),
            labels: _sorts,
            onChanged: (v) => setState(() => _sort = v ?? 'terbaru')),
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _reset, child: const Text('Reset'))),
      ]),
    );

    final results = list.isEmpty
        ? const EmptyState(icon: Icons.apartment, title: 'Organisasi tidak ditemukan', subtitle: 'Coba ubah kata kunci atau filter pencarianmu.')
        : Column(children: [
            for (final o in list) Padding(padding: const EdgeInsets.only(bottom: 18), child: _OrgCard(o)),
          ]);

    return SingleChildScrollView(
      child: Column(children: [
        PageWrap(
          maxWidth: 1240,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 32),
            Text('Cari Organisasi', style: TextStyle(fontSize: context.screenW < 700 ? 28 : 38, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${list.length} organisasi ditemukan', style: TextStyle(color: context.muted, fontSize: 15)),
            const SizedBox(height: 22),
            LayoutBuilder(builder: (ctx, c) {
              if (c.maxWidth < 900) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [filter, const SizedBox(height: 24), results]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 340, child: filter),
                const SizedBox(width: 28),
                Expanded(child: results),
              ]);
            }),
            const SizedBox(height: 56),
          ]),
        ),
        const SiteFooter(),
      ]),
    );
  }
}

class _OrgCard extends StatelessWidget {
  final Organization o;
  const _OrgCard(this.o);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = categoryInfo(o.category);
    final st = s.orgStats(o.id);
    Widget stat(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 19, color: context.muted),
          const SizedBox(width: 6),
          Text(t, style: TextStyle(color: context.muted, fontSize: 15)),
        ]);
    return AppCard(
      padding: const EdgeInsets.all(24),
      onTap: () => openOrg(context, o.id),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OrgLogo(o, size: 80),
        const SizedBox(width: 20),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(o.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
              if (o.verified) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.verified, size: 20, color: AppColors.info)),
            ]),
            const SizedBox(height: 4),
            Text(locationLabel(o.city), style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              CategoryTag(o.category, icon: c.icon, neutral: true),
              CategoryTag(o.type, icon: Icons.business, neutral: true),
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 22, runSpacing: 8, children: [
              stat(Icons.local_fire_department_outlined, '${st.$1} Aktivitas'),
              stat(Icons.people_outline, '${fmtNum(st.$2)} Relawan'),
              stat(Icons.schedule, '${fmtNum(st.$3)} Jam'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class OrganizationDetailScreen extends StatelessWidget {
  final String orgId;
  const OrganizationDetailScreen({super.key, required this.orgId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final o = s.orgById(orgId);
    if (o == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.apartment, title: 'Organisasi tidak ditemukan', subtitle: ''));
    }
    final c = categoryInfo(o.category).color;
    final acts = s.activitiesOfOrg(o.id);
    final open = acts.where((a) => s.statusOf(a) == ActStatus.open).toList();
    final past = acts.where((a) => s.statusOf(a) != ActStatus.open).toList();
    final following = s.isFollowing(o.id);
    final isMine = s.user?.orgId == o.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Organisasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: PageWrap(
          maxWidth: 900,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.black, 0.45)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(initials(o.name), style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (o.verified) const Pill('Terverifikasi', color: Colors.white, icon: Icons.verified),
                        if (o.verified) const SizedBox(width: 6),
                        Pill(o.category, color: Colors.white),
                      ]),
                    ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Text(o.tagline, style: TextStyle(color: Colors.white.withAlpha(225), fontSize: 14.5)),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              _Stat('${o.rating == 0 ? '-' : o.rating.toStringAsFixed(1)}', 'Rating', Icons.star, AppColors.accent),
              const SizedBox(width: 10),
              _Stat(fmtNum(s.followersOf(o)), 'Pengikut', Icons.people, AppColors.info),
              const SizedBox(width: 10),
              _Stat('${acts.length}', 'Aktivitas', Icons.event_note, AppColors.primary),
            ]),
            const SizedBox(height: 16),
            if (!(s.user?.isOrganizer ?? true))
              SizedBox(
                width: double.infinity,
                child: following
                    ? OutlinedButton.icon(onPressed: () => s.toggleFollow(o.id), icon: const Icon(Icons.check), label: const Text('Mengikuti'))
                    : FilledButton.icon(
                        onPressed: () {
                          s.toggleFollow(o.id);
                          toast(context, 'Kamu mengikuti ${o.name}');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ikuti Organisasi')),
              ),
            if (isMine)
              Pill('Ini organisasi Anda', color: AppColors.primary, icon: Icons.verified_user),
            const SectionHeader('Tentang'),
            Text(o.about, style: const TextStyle(fontSize: 15, height: 1.6)),
            if (o.email.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.mail_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(o.email, style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ],
            SectionHeader('Aktivitas dibuka (${open.length})'),
            if (open.isEmpty)
              Text('Belum ada aktivitas yang dibuka.', style: TextStyle(color: context.muted))
            else
              ResponsiveWrap(minItemWidth: 280, maxCols: 2, children: open.map((a) => ActivityCard(a)).toList()),
            if (past.isNotEmpty) ...[
              SectionHeader('Riwayat aktivitas (${past.length})'),
              ResponsiveWrap(minItemWidth: 280, maxCols: 2, children: past.map((a) => ActivityCard(a)).toList()),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _Stat(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(fontSize: 12, color: context.muted)),
          ]),
        ),
      );
}
