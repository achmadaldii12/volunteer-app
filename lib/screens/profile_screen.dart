import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final hours = s.hoursOf(u.id);
    final done = s.attendedOf(u.id).length;
    final cats = s.categoriesDone(u.id).length;
    final lvl = levelFor(hours);
    final progress = lvl.nextHours == null ? 1.0 : (hours - lvl.minHours) / (lvl.nextHours! - lvl.minHours);
    final org = u.orgId == null ? null : s.orgById(u.orgId!);

    final badges = <(IconData, String, String, bool)>[
      (Icons.flag, 'Langkah Pertama', 'Selesaikan 1 aktivitas', done >= 1),
      (Icons.local_fire_department, 'Konsisten', 'Selesaikan 3 aktivitas', done >= 3),
      (Icons.timer, 'Sepuluh Jam', 'Capai 10 jam kontribusi', hours >= 10),
      (Icons.explore, 'Penjelajah', 'Ikut 3 kategori berbeda', cats >= 3),
      (Icons.favorite, 'Pendukung', 'Ikuti 3 organisasi', s.followingCount(u.id) >= 3),
      (Icons.military_tech, 'Pahlawan', 'Capai 50 jam kontribusi', hours >= 50),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: PageWrap(
          maxWidth: 760,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(children: [
                Row(children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Text(initials(u.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 22)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                      Text(u.email, style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 13)),
                      const SizedBox(height: 6),
                      Pill(u.isOrganizer ? 'Penyelenggara' : lvl.name, color: Colors.white, icon: u.isOrganizer ? Icons.business : Icons.military_tech),
                    ]),
                  ),
                ]),
                if (!u.isOrganizer) ...[
                  const SizedBox(height: 18),
                  Row(children: [
                    Text('$hours jam', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(lvl.nextHours == null ? 'Level tertinggi' : 'Menuju ${lvl.nextHours} jam',
                        style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12.5)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 9, backgroundColor: Colors.white24, color: AppColors.accent),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            if (u.isOrganizer && org != null)
              AppCard(
                onTap: () => openOrg(context, org.id),
                child: Row(children: [
                  OrgAvatar(org, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Organisasi saya', style: TextStyle(fontSize: 12)),
                      Text(org.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
              )
            else
              Row(children: [
                _Stat('$done', 'Aktivitas', Icons.check_circle, AppColors.success),
                const SizedBox(width: 10),
                _Stat('$hours', 'Jam', Icons.timer, AppColors.primary),
                const SizedBox(width: 10),
                _Stat('${s.followingCount(u.id)}', 'Mengikuti', Icons.favorite, AppColors.danger),
              ]),
            if (u.bio.isNotEmpty) ...[
              const SectionHeader('Tentang saya'),
              Text(u.bio, style: const TextStyle(height: 1.5)),
            ],
            if (u.interests.isNotEmpty) ...[
              const SectionHeader('Minat'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final i in u.interests)
                  Chip(avatar: Icon(categoryInfo(i).icon, size: 16, color: categoryInfo(i).color), label: Text(i)),
              ]),
            ],
            if (!u.isOrganizer) ...[
              const SectionHeader('Lencana', subtitle: 'Kumpulkan lencana dari setiap kontribusimu'),
              ResponsiveWrap(minItemWidth: 200, maxCols: 3, spacing: 10, children: [
                for (final b in badges)
                  Opacity(
                    opacity: b.$4 ? 1 : 0.45,
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      color: b.$4 ? context.softTeal : null,
                      child: Row(children: [
                        Icon(b.$4 ? b.$1 : Icons.lock_outline, color: b.$4 ? AppColors.accent : context.muted, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(b.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            Text(b.$3, style: TextStyle(fontSize: 11, color: context.muted)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
              ]),
            ],
            const SectionHeader('Pengaturan'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _menu(context, Icons.edit, 'Edit profil', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                _menu(context, Icons.notifications_outlined, 'Notifikasi', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    badge: s.unreadCount),
                _menu(context, Icons.help_outline, 'Cara kerja & FAQ', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HowItWorksScreen()))),
                _menu(context, Icons.info_outline, 'Tentang aplikasi', () => _about(context)),
                _menu(context, Icons.restart_alt, 'Reset data demo', () async {
                  if (await confirmDialog(context, 'Reset data demo?', 'Semua akun baru, pendaftaran, dan perubahan akan dikembalikan ke data awal.',
                      confirmText: 'Reset', danger: true)) {
                    await s.resetDemoData();
                  }
                }, last: true),
              ]),
            ),
            const SectionHeader('Tampilan'),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Terang')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Gelap')),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Sistem')),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => s.setThemeMode(v.first),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () async {
                  if (await confirmDialog(context, 'Keluar dari akun?', 'Kamu bisa masuk kembali kapan saja.', confirmText: 'Keluar', danger: true)) {
                    s.logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, IconData icon, String title, VoidCallback onTap, {int badge = 0, bool last = false}) => Column(children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            const Icon(Icons.chevron_right),
          ]),
          onTap: onTap,
        ),
        if (!last) Divider(height: 1, color: context.line),
      ]);

  void _about(BuildContext context) => showAboutDialog(
        context: context,
        applicationName: 'Volunteer',
        applicationVersion: '2.0.0',
        applicationIcon: const Icon(Icons.volunteer_activism, color: AppColors.primary, size: 40),
        children: const [
          Text('Platform yang mempertemukan relawan dengan organisasi sosial. '
              'Versi ini berjalan tanpa server (data disimpan lokal) untuk keperluan demo frontend.'),
        ],
      );
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
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(fontSize: 12, color: context.muted)),
          ]),
        ),
      );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name, _city, _bio, _phone;
  late final Set<String> _interests;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppState>().user!;
    _name = TextEditingController(text: u.name);
    _city = TextEditingController(text: u.city);
    _bio = TextEditingController(text: u.bio);
    _phone = TextEditingController(text: u.phone);
    _interests = {...u.interests};
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = context.read<AppState>().user!.isOrganizer;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(controller: _name, decoration: inputDeco(labelText: 'Nama lengkap', prefixIcon: Icon(Icons.badge_outlined))),
              const SizedBox(height: 14),
              TextField(controller: _city, decoration: inputDeco(labelText: 'Kota', prefixIcon: Icon(Icons.place_outlined))),
              const SizedBox(height: 14),
              TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: inputDeco(labelText: 'Nomor WhatsApp', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 14),
              TextField(
                  controller: _bio,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: inputDeco(labelText: 'Bio singkat', alignLabelWithHint: true)),
              if (!isOrg) ...[
                const SizedBox(height: 8),
                const Text('Minat', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in kCategories)
                    FilterChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: _interests.contains(c.name),
                      onSelected: (v) => setState(() => v ? _interests.add(c.name) : _interests.remove(c.name)),
                    ),
                ]),
              ],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_name.text.trim().isEmpty) {
                      toast(context, 'Nama tidak boleh kosong', error: true);
                      return;
                    }
                    context.read<AppState>().updateProfile(
                        name: _name.text, city: _city.text, bio: _bio.text, phone: _phone.text, interests: _interests.toList());
                    Navigator.pop(context);
                    toast(context, 'Profil diperbarui');
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class HowItWorksScreen extends StatelessWidget {
  final bool embedded;
  const HowItWorksScreen({super.key, this.embedded = false});

  static const _faq = [
    ('Apakah mendaftar sebagai relawan berbayar?', 'Tidak. Mendaftar dan mengikuti aktivitas relawan di aplikasi ini gratis.'),
    ('Bagaimana status pendaftaran saya?', 'Setelah mendaftar, status "Menunggu konfirmasi" akan berubah menjadi "Diterima" atau "Tidak diterima" setelah ditinjau penyelenggara.'),
    ('Kapan jam kontribusi saya tercatat?', 'Jam tercatat otomatis setelah penyelenggara menandai kamu "Hadir" pada aktivitas tersebut.'),
    ('Bagaimana cara mendapat sertifikat?', 'Sertifikat tersedia di tab Aktivitasku > Riwayat untuk aktivitas yang kehadirannya sudah tercatat.'),
    ('Bisakah saya membatalkan pendaftaran?', 'Bisa. Buka Aktivitasku lalu ketuk Batalkan agar kuota dapat dipakai relawan lain.'),
    ('Bagaimana cara organisasi mencari relawan?', 'Daftar dengan peran Penyelenggara, buat aktivitas, lalu kelola pendaftar dari tab Kelola.'),
  ];

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: PageWrap(
          maxWidth: 760,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Untuk relawan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _step(context, '1', 'Cari aktivitas', 'Gunakan pencarian dan filter untuk menemukan kegiatan yang cocok.'),
            _step(context, '2', 'Daftar', 'Isi motivasi singkat dan kirim pendaftaran.'),
            _step(context, '3', 'Ikuti & raih sertifikat', 'Hadir pada hari kegiatan, jam kontribusi tercatat, sertifikat terbit.'),
            const SizedBox(height: 22),
            const Text('Untuk penyelenggara', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _step(context, '1', 'Buat aktivitas', 'Lengkapi detail, kuota, persyaratan, dan agenda.'),
            _step(context, '2', 'Seleksi pendaftar', 'Terima atau tolak pendaftar sesuai kebutuhan.'),
            _step(context, '3', 'Catat kehadiran', 'Tandai relawan yang hadir agar jam kontribusi mereka tercatat.'),
            const SizedBox(height: 22),
            const Text('Pertanyaan umum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final f in _faq)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(f.$2, style: TextStyle(color: context.muted, height: 1.45))],
                    ),
                  ),
                ),
              ),
          ]),
        ),
      );
    return embedded ? scroll : Scaffold(appBar: AppBar(title: const Text('Cara Kerja & FAQ')), body: scroll);
  }

  Widget _step(BuildContext context, String n, String t, String d) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.primary, child: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(d, style: TextStyle(color: context.muted, fontSize: 13)),
              ]),
            ),
          ]),
        ),
      );
}
