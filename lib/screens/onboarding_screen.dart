import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    (Icons.travel_explore, 'Temukan aktivitas yang kamu pedulikan',
        'Cari kegiatan relawan berdasarkan minat, lokasi, dan waktu luangmu, dari bersih pantai sampai webinar.'),
    (Icons.how_to_reg, 'Daftar dalam hitungan detik',
        'Kirim motivasi singkat, pantau status pendaftaran, dan dapatkan notifikasi saat penyelenggara menerimamu.'),
    (Icons.workspace_premium, 'Catat jam & raih sertifikat',
        'Setiap kontribusi tercatat otomatis. Kumpulkan lencana, naikkan level, dan unduh e-sertifikat.'),
  ];

  void _next() {
    if (_page == _pages.length - 1) {
      context.read<AppState>().finishOnboarding();
    } else {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: s.finishOnboarding, child: const Text('Lewati')),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 190,
                          height: 190,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 40, offset: const Offset(0, 16))
                            ],
                          ),
                          child: Icon(p.$1, size: 90, color: Colors.white),
                        ),
                        const SizedBox(height: 44),
                        Text(p.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.25)),
                        const SizedBox(height: 14),
                        Text(p.$3,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, height: 1.5, color: context.muted)),
                      ]),
                    );
                  },
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: i == _page ? AppColors.primary : context.line,
                        borderRadius: BorderRadius.circular(8)),
                  ),
              ]),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _next,
                      child: Text(_page == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut')),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
