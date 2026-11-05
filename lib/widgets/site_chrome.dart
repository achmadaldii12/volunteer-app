import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'common.dart';

/// Memungkinkan halaman mana pun berpindah menu utama (Beranda, Cari, dst).
class ShellNav extends InheritedWidget {
  final void Function(int) go;
  const ShellNav({super.key, required this.go, required super.child});

  static ShellNav of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<ShellNav>()!;

  @override
  bool updateShouldNotify(ShellNav old) => false;
}

class NavIndex {
  static const home = 0;
  static const activities = 1;
  static const organizations = 2;
  static const mine = 3;
  static const howItWorks = 4;
  static const about = 5;
  static const profile = 6;
}

class BrandLogo extends StatelessWidget {
  final Color color;
  final double size;
  const BrandLogo({super.key, this.color = Colors.white, this.size = 26});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.volunteer_activism, color: color, size: size + 4),
        const SizedBox(width: 8),
        Text('Volunteer',
            style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, letterSpacing: -0.5)),
      ]);
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = ShellNav.of(context);
    Widget link(String t, int i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(onTap: () => nav.go(i), child: Text(t, style: TextStyle(color: Colors.white.withAlpha(215), fontSize: 14))),
        );
    Widget head(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
        );
    return Container(
      width: double.infinity,
      color: const Color(0xFF7A0F1A),
      padding: const EdgeInsets.fromLTRB(0, 44, 0, 28),
      child: PageWrap(
        maxWidth: 1200,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 48, runSpacing: 28, children: [
            SizedBox(
              width: 320,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const BrandLogo(),
                const SizedBox(height: 14),
                Text('Platform yang mempertemukan relawan dengan organisasi sosial untuk menciptakan dampak nyata bagi sesama.',
                    style: TextStyle(color: Colors.white.withAlpha(205), height: 1.5, fontSize: 14)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              head('Jelajahi'),
              link('Cari Aktivitas', NavIndex.activities),
              link('Cari Organisasi', NavIndex.organizations),
              link('Cara Kerja', NavIndex.howItWorks),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              head('Tentang'),
              link('Tentang Kami', NavIndex.about),
              link('Profil Saya', NavIndex.profile),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              head('Hubungi Kami'),
              Text('halo@volunteer.example', style: TextStyle(color: Colors.white.withAlpha(215), fontSize: 14)),
              const SizedBox(height: 10),
              Text('Senin - Jumat, 09.00 - 17.00 WIB', style: TextStyle(color: Colors.white.withAlpha(215), fontSize: 14)),
            ]),
          ]),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withAlpha(50)),
          const SizedBox(height: 12),
          Text('© ${DateTime.now().year} Volunteer. Proyek tugas besar. Data dalam aplikasi ini adalah contoh.',
              style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 12.5)),
        ]),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool center;
  const SectionTitle(this.title, {super.key, this.subtitle, this.center = true});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, textAlign: center ? TextAlign.center : TextAlign.start, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, textAlign: center ? TextAlign.center : TextAlign.start, style: TextStyle(fontSize: 16, color: context.muted)),
          ],
        ],
      );
}
