import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/site_chrome.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: const Column(children: [
            Text('Tentang Volunteer', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Text('Menghubungkan niat baik dengan aksi nyata', style: TextStyle(color: Colors.white70, fontSize: 17)),
          ]),
        ),
        PageWrap(
          maxWidth: 960,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Siapa kami', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
                'Volunteer adalah platform kerelawanan yang mempertemukan individu yang ingin berkontribusi dengan organisasi sosial yang membutuhkan tenaga dan keahlian. Kami percaya setiap orang bisa berperan, sekecil apa pun waktu yang dimiliki.',
                style: TextStyle(fontSize: 16, height: 1.65, color: context.muted)),
            const SizedBox(height: 32),
            ResponsiveWrap(minItemWidth: 280, maxCols: 3, spacing: 16, children: const [
              _Card(Icons.visibility, 'Visi', 'Menjadi ruang kolaborasi kerelawanan yang mudah diakses oleh semua orang di Indonesia.'),
              _Card(Icons.flag, 'Misi', 'Mempermudah pencarian aktivitas, mencatat kontribusi, dan memperkuat kerja organisasi sosial.'),
              _Card(Icons.favorite, 'Nilai', 'Peduli, transparan, kolaboratif, dan berdampak bagi lingkungan sekitar.'),
            ]),
            const SizedBox(height: 32),
            const Text('Tentang proyek ini', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
                'Aplikasi ini dibuat sebagai tugas besar mata kuliah pemrograman mobile menggunakan Flutter. Seluruh data (organisasi, aktivitas, artikel, dan angka dampak) adalah data contoh untuk keperluan demonstrasi.',
                style: TextStyle(fontSize: 16, height: 1.65, color: context.muted)),
          ]),
        ),
        const SiteFooter(),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const _Card(this.icon, this.title, this.text);

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.primary.withAlpha(25), child: Icon(icon, color: AppColors.primary)),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: context.muted, height: 1.5)),
        ]),
      );
}
