import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class CertificateScreen extends StatelessWidget {
  final String regId;
  const CertificateScreen({super.key, required this.regId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final r = s.regs.where((x) => x.id == regId).firstOrNull;
    final a = r == null ? null : s.activityById(r.activityId);
    if (r == null || a == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.workspace_premium, title: 'Sertifikat tidak ditemukan', subtitle: ''));
    }
    final org = s.orgOf(a);
    final no = 'VLN/${a.end.year}/${a.id.toUpperCase()}/${r.id.hashCode.abs() % 100000}';
    const gold = Color(0xFFB45309);
    return Scaffold(
      appBar: AppBar(title: const Text('E-Sertifikat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: gold.withAlpha(120))),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Color(0xFF3B2A12)),
                    child: Column(children: [
                      const Icon(Icons.workspace_premium, size: 64, color: gold),
                      const SizedBox(height: 6),
                      const Text('SERTIFIKAT RELAWAN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('No. $no', style: const TextStyle(fontSize: 11.5, color: gold)),
                      const SizedBox(height: 26),
                      const Text('Diberikan kepada'),
                      const SizedBox(height: 8),
                      Text(r.userName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: gold)),
                      const SizedBox(height: 18),
                      const Text('atas partisipasi dan kontribusinya sebagai relawan dalam kegiatan', textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text('"${a.title}"', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
                      const SizedBox(height: 14),
                      Text('${fmtRange(a.start, a.end)} • ${a.locationLabel}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(color: gold.withAlpha(30), borderRadius: BorderRadius.circular(20)),
                        child: Text('${a.hours} jam kontribusi', style: const TextStyle(fontWeight: FontWeight.w800, color: gold)),
                      ),
                      const SizedBox(height: 28),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(children: [
                          const Text('Penyelenggara', style: TextStyle(fontSize: 11.5)),
                          const SizedBox(height: 18),
                          Text(org.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ]),
                        Column(children: [
                          const Text('Diterbitkan', style: TextStyle(fontSize: 11.5)),
                          const SizedBox(height: 18),
                          Text(fmtDate(a.end), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ]),
                      ]),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: 'Sertifikat Relawan $no\n${r.userName} • ${a.title} • ${a.hours} jam'));
                    toast(context, 'Informasi sertifikat disalin');
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Salin Info Sertifikat'),
                ),
              ),
              const SizedBox(height: 10),
              Text('Fitur unduh PDF dapat ditambahkan pada pengembangan berikutnya.', style: TextStyle(fontSize: 12, color: context.muted), textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }
}
