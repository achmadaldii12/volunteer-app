import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'certificate_screen.dart';

class MyActivitiesScreen extends StatelessWidget {
  const MyActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final regs = s.regsOfUser(u.id);
    final active = regs.where((r) {
      final a = s.activityById(r.activityId);
      if (a == null) return false;
      return (r.status == RegStatus.pending || r.status == RegStatus.accepted) &&
          s.statusOf(a) != ActStatus.finished;
    }).toList();
    final history = regs.where((r) => !active.contains(r)).toList();
    final saved = s.bookmarkedActivities;
    final hours = s.hoursOf(u.id);
    final done = s.attendedOf(u.id).length;

    return SafeArea(
      bottom: false,
      child: DefaultTabController(
        length: 3,
        child: PageWrap(
          maxWidth: 900,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            const Text('Aktivitasku', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Row(children: [
              _Summary(Icons.timer, '$hours', 'Jam kontribusi', AppColors.primary),
              const SizedBox(width: 10),
              _Summary(Icons.check_circle, '$done', 'Aktivitas selesai', AppColors.success),
              const SizedBox(width: 10),
              _Summary(Icons.hourglass_top, '${active.length}', 'Sedang berjalan', AppColors.accent),
            ]),
            const SizedBox(height: 14),
            TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: context.muted,
              indicatorColor: AppColors.primary,
              dividerColor: context.line,
              tabs: [
                Tab(text: 'Terdaftar (${active.length})'),
                Tab(text: 'Tersimpan (${saved.length})'),
                Tab(text: 'Riwayat (${history.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                _regList(context, s, active, 'Belum ada pendaftaran aktif', 'Cari aktivitas dan daftar untuk mulai berkontribusi.'),
                saved.isEmpty
                    ? const EmptyState(icon: Icons.bookmark_border, title: 'Belum ada yang tersimpan', subtitle: 'Ketuk ikon penanda pada aktivitas untuk menyimpannya.')
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 14, bottom: 40),
                        child: ResponsiveWrap(minItemWidth: 280, maxCols: 2, children: saved.map((a) => ActivityCard(a)).toList()),
                      ),
                _regList(context, s, history, 'Riwayat masih kosong', 'Aktivitas yang selesai atau dibatalkan akan muncul di sini.'),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _regList(BuildContext context, AppState s, List<Registration> list, String t, String sub) {
    if (list.isEmpty) return EmptyState(icon: Icons.assignment_outlined, title: t, subtitle: sub);
    return ListView.separated(
      padding: const EdgeInsets.only(top: 14, bottom: 40),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _RegTile(list[i]),
    );
  }
}

class _Summary extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Summary(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: context.muted)),
              ]),
            ),
          ]),
        ),
      );
}

(String, Color, IconData) regStatusInfo(RegStatus s) {
  switch (s) {
    case RegStatus.pending:
      return ('Menunggu konfirmasi', AppColors.accent, Icons.hourglass_top);
    case RegStatus.accepted:
      return ('Diterima', AppColors.success, Icons.check_circle);
    case RegStatus.rejected:
      return ('Tidak diterima', AppColors.danger, Icons.cancel);
    case RegStatus.attended:
      return ('Hadir', AppColors.info, Icons.verified);
    case RegStatus.cancelled:
      return ('Dibatalkan', Colors.grey, Icons.block);
  }
}

class _RegTile extends StatelessWidget {
  final Registration r;
  const _RegTile(this.r);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.activityById(r.activityId);
    if (a == null) return const SizedBox.shrink();
    final org = s.orgOf(a);
    final info = regStatusInfo(r.status);
    final c = categoryInfo(a.category);
    return AppCard(
      onTap: () => openActivity(context, a.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: c.color.withAlpha(34), borderRadius: BorderRadius.circular(14)),
            child: Icon(c.icon, color: c.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.25)),
              const SizedBox(height: 3),
              Text(org.name, style: TextStyle(fontSize: 12.5, color: context.muted)),
              InfoRow(Icons.calendar_month, '${fmtRange(a.start, a.end)} • ${a.time}'),
              InfoRow(a.isOnline ? Icons.public : Icons.place, a.locationLabel),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Pill(info.$1, color: info.$2, icon: info.$3),
          const Spacer(),
          if (r.status == RegStatus.pending || r.status == RegStatus.accepted)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () async {
                if (await confirmDialog(context, 'Batalkan pendaftaran?', 'Kuota akan dilepas untuk relawan lain.',
                    confirmText: 'Batalkan', danger: true)) {
                  s.cancelReg(r.id);
                  if (context.mounted) toast(context, 'Pendaftaran dibatalkan');
                }
              },
              child: const Text('Batalkan'),
            ),
          if (r.status == RegStatus.attended) ...[
            if (r.rating == null)
              TextButton.icon(onPressed: () => _review(context, s, r, a), icon: const Icon(Icons.rate_review, size: 18), label: const Text('Beri ulasan'))
            else
              Row(children: [
                for (var i = 0; i < 5; i++) Icon(i < r.rating! ? Icons.star : Icons.star_border, size: 16, color: AppColors.accent),
              ]),
            const SizedBox(width: 6),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 12)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(regId: r.id))),
              icon: const Icon(Icons.workspace_premium, size: 18),
              label: const Text('Sertifikat'),
            ),
          ],
        ]),
      ]),
    );
  }

  Future<void> _review(BuildContext context, AppState s, Registration r, Activity a) async {
    var rating = 5;
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Beri ulasan'),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title, style: TextStyle(color: ctx.muted, fontSize: 13)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setD(() => rating = i),
                  icon: Icon(i <= rating ? Icons.star : Icons.star_border, color: AppColors.accent, size: 32),
                ),
            ]),
            TextField(controller: ctrl, maxLines: 3, decoration: inputDeco(hintText: 'Ceritakan pengalamanmu...')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(90, 42)),
              onPressed: () {
                s.submitReview(r.id, rating, ctrl.text);
                Navigator.pop(ctx);
                toast(context, 'Terima kasih atas ulasanmu!');
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
