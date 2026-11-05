import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.myNotifs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (s.unreadCount > 0) TextButton(onPressed: s.markAllRead, child: const Text('Tandai dibaca')),
        ],
      ),
      body: list.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: 'Belum ada notifikasi', subtitle: 'Kabar terbaru tentang pendaftaranmu akan muncul di sini.')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = list[i];
                final (icon, color) = switch (n.kind) {
                  'success' => (Icons.check_circle, AppColors.success),
                  'warning' => (Icons.warning_amber_rounded, AppColors.accent),
                  _ => (Icons.info, AppColors.info),
                };
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: AppCard(
                      color: n.read ? null : context.softTeal,
                      padding: const EdgeInsets.all(14),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: color.withAlpha(34), shape: BoxShape.circle),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(n.body, style: const TextStyle(height: 1.35)),
                            const SizedBox(height: 6),
                            Text(relTime(n.createdAt), style: TextStyle(fontSize: 11.5, color: context.muted)),
                          ]),
                        ),
                        if (!n.read) const Icon(Icons.circle, size: 10, color: AppColors.primary),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
