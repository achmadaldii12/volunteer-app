import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/seed_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';
import 'article_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ActivityType _type = ActivityType.event;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final nav = ShellNav.of(context);
    final narrow = context.screenW < 700;
    final list = s.query(type: _type, sort: 'terbaru');

    return SingleChildScrollView(
      child: Column(children: [
        // ======================================================= HERO + STATISTIK
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: double.infinity,
            // Tinggi diperbesar agar area gambar jauh lebih leluasa ke bawah
            height: narrow ? 500 : 580,
            decoration: BoxDecoration(
              color: Colors.red,
              image: DecorationImage(
                image: const AssetImage('assets/image/gambar_volunteer.JPG'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(children: [
              Positioned(right: -60, top: -60, child: _circle(300, 18)),
              Positioned(left: -80, bottom: -90, child: _circle(340, 14)),
              Positioned(right: 140, bottom: 40, child: Icon(Icons.volunteer_activism, size: 210, color: Colors.white.withAlpha(20))),
              Positioned(left: 60, top: 40, child: Icon(Icons.favorite, size: 90, color: Colors.white.withAlpha(16))),
              Center(
                child: Padding(
                  // Padding atas ditambah agar posisi teks dan tombol berada persis di tengah-tengah layar dengan rapi
                  padding: EdgeInsets.fromLTRB(24, narrow ? 90 : 120, 24, narrow ? 60 : 80),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Jadilah relawan, mulai dari sini',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: narrow ? 30 : 46, fontWeight: FontWeight.w800, height: 1.15)),
                    const SizedBox(height: 14),
                    Text('Temukan kegiatan sosial yang sesuai minatmu dan berkontribusi hari ini.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withAlpha(225), fontSize: narrow ? 15 : 19)),
                    const SizedBox(height: 26),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white, foregroundColor: AppColors.primary, minimumSize: const Size(190, 52)),
                      onPressed: () => nav.go(NavIndex.activities),
                      child: const Text('Cari Aktivitas', style: TextStyle(fontSize: 16)),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: narrow ? -70 : -56,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: narrow ? 16 : 24, horizontal: 12),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
                    ),
                    child: Row(children: [
                      _stat(context, Icons.person_outline, 12480, 'Relawan', narrow),
                      _stat(context, Icons.apartment, s.allOrgs.length, 'Organisasi', narrow),
                      _stat(context, Icons.event_available, s.allActivities.length, 'Aktivitas', narrow),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ]),
        SizedBox(height: narrow ? 100 : 90),

        // ======================================================= LAYANAN
        PageWrap(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(builder: (ctx, c) {
            final stacked = c.maxWidth < 900;
            final left = Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFFD6202F), Color(0xFFE8503A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Satu tempat untuk menemukan relawan dan aksi sosial',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.25)),
                const SizedBox(height: 14),
                Text('Dari bersih pantai hingga mengajar anak-anak, temukan peran yang cocok untukmu dan catat setiap kontribusinya.',
                    style: TextStyle(color: Colors.white.withAlpha(225), fontSize: 15, height: 1.5)),
                const SizedBox(height: 22),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), minimumSize: const Size(150, 46)),
                  onPressed: () => nav.go(NavIndex.howItWorks),
                  child: const Text('Selengkapnya'),
                ),
              ]),
            );
            final right = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Kenali layanan Volunteer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ResponsiveWrap(minItemWidth: 190, maxCols: 3, spacing: 14, children: [
                _ServiceCard(Icons.volunteer_activism, 'Jadi Relawan', 'Temukan dan ikuti aktivitas sosial sesuai minatmu.', () => nav.go(NavIndex.activities)),
                _ServiceCard(Icons.apartment, 'Cari Organisasi', 'Kenali organisasi dan ikuti kabar terbarunya.', () => nav.go(NavIndex.organizations)),
                _ServiceCard(Icons.handshake, 'Cari Relawan', 'Penyelenggara dapat membuat aktivitas dan merekrut relawan.', () => nav.go(NavIndex.mine)),
              ]),
            ]);
            if (stacked) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [left, const SizedBox(height: 28), right]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 4, child: left),
              const SizedBox(width: 32),
              Expanded(flex: 8, child: right),
            ]);
          }),
        ),

        // ======================================================= AKTIVITAS TERBARU
        const SizedBox(height: 64),
        PageWrap(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SectionTitle('Aktivitas Terbaru', subtitle: 'Pilih aktivitas kerelawanan sesuai minat, lokasi, dan isu yang kamu suka'),
            const SizedBox(height: 26),
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final t in ActivityType.values)
                    InkWell(
                      onTap: () => setState(() => _type = t),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        margin: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: _type == t ? AppColors.primary : Colors.transparent, width: 3)),
                        ),
                        child: Text(typeLabel(t),
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: _type == t ? AppColors.primary : null)),
                      ),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              const EmptyState(icon: Icons.event_busy, title: 'Belum ada aktivitas', subtitle: 'Belum ada aktivitas terbuka untuk jenis ini.')
            else
              ActivityCarousel(list),
            const SizedBox(height: 26),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(220, 52)),
              onPressed: () => nav.go(NavIndex.activities),
              child: const Text('Lihat aktivitas lainnya'),
            ),
          ]),
        ),

        // ======================================================= DAMPAK
        const SizedBox(height: 70),
        Container(
          width: double.infinity,
          color: context.band,
          padding: const EdgeInsets.symmetric(vertical: 56),
          child: PageWrap(
            maxWidth: 1200,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const SectionTitle('Dampak Relawan Kita', subtitle: 'Hasil kontribusi komunitas relawan (data contoh)'),
              const SizedBox(height: 32),
              ResponsiveWrap(minItemWidth: 330, maxCols: 3, spacing: 20, children: const [
                _ImpactCard('820', 'Aksi', 'Kegiatan bersih lingkungan terlaksana', Icons.eco),
                _ImpactCard('540', 'Taman Baca', 'Terbentuk dan terdampingi relawan', Icons.menu_book),
                _ImpactCard('3.250', 'Jam', 'Kontribusi tercatat dari seluruh relawan', Icons.timer),
                _ImpactCard('1.120', 'Anak', 'Terdampingi belajar secara rutin', Icons.child_care),
                _ImpactCard('18.400', 'Kilogram', 'Sampah terpilah dan terkelola', Icons.recycling),
                _ImpactCard('640', 'Pemeriksaan', 'Kesehatan gratis untuk warga', Icons.monitor_heart),
              ]),
            ]),
          ),
        ),

        // ======================================================= BLOG
        const SizedBox(height: 64),
        PageWrap(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SectionTitle('Blog Volunteer'),
            const SizedBox(height: 30),
            ResponsiveWrap(minItemWidth: 330, maxCols: 3, spacing: 22, children: [
              for (var i = 0; i < 3; i++) _BlogCard(SeedData.articles[i], i),
            ]),
            const SizedBox(height: 28),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(220, 52)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticleListScreen())),
              child: const Text('Baca artikel lainnya'),
            ),
          ]),
        ),

        // ======================================================= TESTIMONI
        const SizedBox(height: 70),
        PageWrap(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SectionTitle('Kata Mereka', subtitle: 'Cerita relawan dan penyelenggara (contoh)'),
            const SizedBox(height: 28),
            ResponsiveWrap(minItemWidth: 330, maxCols: 3, spacing: 20, children: SeedData.testimonials.map((t) => _Testimonial(t)).toList()),
          ]),
        ),
        const SizedBox(height: 72),
        const SiteFooter(),
      ]),
    );
  }

  Widget _circle(double size, int alpha) => Container(
      width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(alpha)));

  Widget _stat(BuildContext context, IconData icon, int value, String label, bool narrow) => Expanded(
        child: narrow
            ? Column(children: [
                Icon(icon, color: AppColors.primary, size: 30),
                const SizedBox(height: 6),
                CountUp(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                Text(label, style: TextStyle(color: context.muted, fontSize: 13)),
              ])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: AppColors.primary, size: 52),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CountUp(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1)),
                  Text(label, style: const TextStyle(fontSize: 18)),
                ]),
              ]),
      );
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title, text;
  final VoidCallback onTap;
  const _ServiceCard(this.icon, this.title, this.text, this.onTap);

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withAlpha(24), child: Icon(icon, color: AppColors.primary, size: 28)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: context.muted, height: 1.45, fontSize: 14)),
          const SizedBox(height: 12),
          const Row(children: [
            Text('Buka', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
          ]),
        ]),
      );
}

class _ImpactCard extends StatelessWidget {
  final String value, unit, text;
  final IconData icon;
  const _ImpactCard(this.value, this.unit, this.text, this.icon);

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(26),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                TextSpan(text: ' $unit', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              ])),
              const SizedBox(height: 8),
              Text(text, style: TextStyle(fontSize: 15, color: context.muted, height: 1.4)),
            ]),
          ),
          const SizedBox(width: 12),
          CircleAvatar(radius: 32, backgroundColor: AppColors.primary.withAlpha(22), child: Icon(icon, color: AppColors.primary, size: 32)),
        ]),
      );
}

class _BlogCard extends StatelessWidget {
  final Article art;
  final int index;
  const _BlogCard(this.art, this.index);

  @override
  Widget build(BuildContext context) {
    final c = kCategories[(index * 3 + 1) % kCategories.length].color;
    final icon = kCategories[(index * 3 + 1) % kCategories.length].icon;
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 14,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleScreen(article: art, color: c))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.black, 0.4)!], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: ClipRect(
              child: Stack(children: [
                Positioned(right: -20, bottom: -30, child: Icon(icon, size: 170, color: Colors.white.withAlpha(40))),
                Positioned(left: 16, top: 16, child: Pill(art.category, color: Colors.white)),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 50, child: Text(art.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3))),
            const SizedBox(height: 10),
            SizedBox(height: 66, child: Text(art.excerpt, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.muted, height: 1.5, fontSize: 15))),
            const SizedBox(height: 14),
            Align(
                alignment: Alignment.centerRight,
                child: Text('Baca lebih lanjut', style: TextStyle(fontWeight: FontWeight.w600, color: context.muted))),
          ]),
        ),
      ]),
    );
  }
}

class _Testimonial extends StatelessWidget {
  final Testimonial t;
  const _Testimonial(this.t);

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.format_quote, size: 34, color: AppColors.primary),
          Text(t.text, style: const TextStyle(height: 1.55, fontSize: 15)),
          const SizedBox(height: 18),
          Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(initials(t.name), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(t.role, style: TextStyle(fontSize: 12.5, color: context.muted)),
              ]),
            ),
          ]),
        ]),
      );
}