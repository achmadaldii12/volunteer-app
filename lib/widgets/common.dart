import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../screens/activity_detail_screen.dart';
import '../screens/organizations_screen.dart';

void openActivity(BuildContext c, String id) => Navigator.push(
    c, MaterialPageRoute(builder: (_) => ActivityDetailScreen(activityId: id)));

void openOrg(BuildContext c, String id) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => OrganizationDetailScreen(orgId: id)));

/// Membatasi lebar konten agar rapi di layar lebar (Chrome / tablet).
class PageWrap extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  const PageWrap(
      {super.key,
      required this.child,
      this.maxWidth = 1100,
      this.padding = const EdgeInsets.symmetric(horizontal: 16)});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: padding, child: child),
        ),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap,
      this.color,
      this.radius = 18});

  @override
  Widget build(BuildContext context) => Material(
        color: color ?? context.cardBg,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: context.line),
              boxShadow: context.isDark
                  ? null
                  : const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
            ),
            child: child,
          ),
        ),
      );
}

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final int maxCols;
  const ResponsiveWrap(
      {super.key,
      required this.children,
      this.minItemWidth = 300,
      this.spacing = 14,
      this.maxCols = 4});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, cons) {
        final w = cons.maxWidth;
        final cols = ((w + spacing) / (minItemWidth + spacing)).floor().clamp(1, maxCols).toInt();
        final itemW = (w - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((e) => SizedBox(width: itemW, child: e)).toList(),
        );
      });
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  const SectionHeader(this.title, {super.key, this.subtitle, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 28, 0, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: TextStyle(color: context.muted, fontSize: 13)),
                ),
            ]),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
        ]),
      );
}

class ActivityCover extends StatelessWidget {
  final Activity a;
  final double height;
  final Widget? overlay;
  const ActivityCover(this.a, {super.key, this.height = 112, this.overlay});

  @override
  Widget build(BuildContext context) {
    final c = categoryInfo(a.category);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.color, Color.lerp(c.color, Colors.black, 0.4)!],
        ),
      ),
      child: ClipRect(
        child: Stack(children: [
          Positioned(
              right: -18,
              bottom: -26,
              child: Icon(c.icon, size: height * 0.95, color: Colors.white.withAlpha(40))),
          Positioned(
              left: -34,
              top: -34,
              child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(22)))),
          if (overlay != null) Positioned.fill(child: overlay!),
        ]),
      ),
    );
  }
}

class TypeChip extends StatelessWidget {
  final ActivityType type;
  const TypeChip(this.type, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: Colors.white.withAlpha(235), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(typeIcon(type), size: 13, color: AppColors.primaryDark),
          const SizedBox(width: 4),
          Text(typeLabel(type),
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
        ]),
      );
}

class StatusBadge extends StatelessWidget {
  final ActStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    late String t;
    late Color c;
    switch (status) {
      case ActStatus.open:
        t = 'Dibuka';
        c = AppColors.success;
        break;
      case ActStatus.full:
        t = 'Kuota penuh';
        c = AppColors.accent;
        break;
      case ActStatus.closed:
        t = 'Ditutup';
        c = Colors.grey;
        break;
      case ActStatus.finished:
        t = 'Selesai';
        c = Colors.blueGrey;
        break;
    }
    return Pill(t, color: c);
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, {super.key, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: color.withAlpha(34), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoRow(this.icon, this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [
          Icon(icon, size: 15, color: context.muted),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: context.muted))),
        ]),
      );
}

class OrgAvatar extends StatelessWidget {
  final Organization org;
  final double size;
  const OrgAvatar(this.org, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = categoryInfo(org.category).color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: c.withAlpha(36), borderRadius: BorderRadius.circular(size * 0.3), border: Border.all(color: c.withAlpha(90))),
      child: Text(initials(org.name),
          style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: size * 0.36)),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  const ProgressBar(this.value, {super.key, this.color, this.height = 7});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: height,
          backgroundColor: context.line,
          color: color ?? (value >= 1 ? AppColors.accent : AppColors.primary),
        ),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState(
      {super.key, required this.icon, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: context.softTeal, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: context.muted), textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;
  const CountUp(this.value, {super.key, this.style, this.suffix = ''});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 1400),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Text('${fmtNum(v.round())}$suffix', style: style),
      );
}


Color typeColor(ActivityType t) {
  switch (t) {
    case ActivityType.event:
      return const Color(0xFFEA580C);
    case ActivityType.regular:
      return const Color(0xFF16A34A);
    case ActivityType.project:
      return const Color(0xFF65A30D);
    case ActivityType.webinar:
      return const Color(0xFF2563EB);
  }
}

class TypeBadge extends StatelessWidget {
  final ActivityType type;
  const TypeBadge(this.type, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: typeColor(type),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Text(typeLabel(type), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      );
}

class CategoryTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool neutral;
  const CategoryTag(this.text, {super.key, this.icon, this.neutral = false});

  @override
  Widget build(BuildContext context) {
    final fg = neutral ? (context.isDark ? Colors.white70 : const Color(0xFF374151)) : AppColors.primary;
    final bg = neutral ? context.band : AppColors.primary.withAlpha(context.isDark ? 40 : 22);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon == null ? 12 : 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: neutral ? null : Border.all(color: AppColors.primary.withAlpha(70)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 15, color: fg), const SizedBox(width: 5)],
        Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: fg, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class OrgLogo extends StatelessWidget {
  final Organization org;
  final double size;
  const OrgLogo(this.org, {super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final c = categoryInfo(org.category).color;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [c, Color.lerp(c, Colors.black, 0.35)!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(initials(org.name), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.34)),
    );
  }
}

/// Kolom pilihan bergaya dropdown (aman lintas versi Flutter).
class SelectField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> options;
  final void Function(String?) onChanged;
  final bool allowClear;
  final Map<String, String>? labels;
  const SelectField(
      {super.key, required this.hint, required this.value, required this.options, required this.onChanged, this.allowClear = true, this.labels});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (ctx, cons) => PopupMenuButton<String>(
          tooltip: '',
          position: PopupMenuPosition.under,
          constraints: BoxConstraints(minWidth: cons.maxWidth, maxWidth: cons.maxWidth),
          onSelected: (v) => onChanged(v == '__all__' ? null : v),
          itemBuilder: (_) => [
            if (allowClear) PopupMenuItem(value: '__all__', child: Text(hint, style: TextStyle(color: context.muted))),
            for (final o in options) PopupMenuItem(value: o, child: Text(labels?[o] ?? o)),
          ],
          child: InputDecorator(
            decoration: inputDeco(suffixIcon: const Icon(Icons.keyboard_arrow_down)),
            child: Text(
              value == null ? hint : (labels?[value] ?? value!),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: value == null ? context.muted : null),
            ),
          ),
        ),
      );
}

String deadlineText(AppState s, Activity a) {
  switch (s.statusOf(a)) {
    case ActStatus.open:
      final left = daysLeft(a.deadline);
      return left <= 0 ? 'Batas registrasi hari ini' : 'Batas registrasi $left hari lagi';
    case ActStatus.full:
      return 'Kuota sudah penuh';
    case ActStatus.closed:
      return 'Pendaftaran ditutup';
    case ActStatus.finished:
      return 'Aktivitas selesai';
  }
}

class ActivityCard extends StatelessWidget {
  final Activity a;
  const ActivityCard(this.a, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final org = s.orgOf(a);
    final tags = <String>[a.category, if (a.skills.isNotEmpty) a.skills.first];
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 14,
      onTap: () => openActivity(context, a.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: ActivityCover(
            a,
            height: 150,
            overlay: Stack(children: [
              Positioned(left: 12, top: 12, child: TypeBadge(a.type)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.black.withAlpha(120),
                  alignment: Alignment.center,
                  child: Text(deadlineText(s, a), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5)),
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 6, runSpacing: 6, children: [for (final t in tags) CategoryTag(t)]),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, height: 1.25)),
            ),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Text(org.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: context.muted))),
              if (org.verified) const Icon(Icons.verified, size: 15, color: AppColors.info),
            ]),
            const SizedBox(height: 16),
            _row(context, Icons.calendar_month, fmtRange(a.start, a.end)),
            const SizedBox(height: 6),
            _row(context, a.isOnline ? Icons.public : Icons.place, a.isOnline ? 'Aktivitas Online' : '${a.city} • ${a.address}'),
          ]),
        ),
      ]),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) => Row(children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, color: context.muted))),
      ]);
}

/// Daftar aktivitas horizontal dengan tombol panah kiri/kanan.
class ActivityCarousel extends StatefulWidget {
  final List<Activity> items;
  const ActivityCarousel(this.items, {super.key});
  @override
  State<ActivityCarousel> createState() => ActivityCarouselState();
}

class ActivityCarouselState extends State<ActivityCarousel> {
  final _c = ScrollController();
  double _step = 300;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void scrollBy(int dir) {
    final target = (_c.offset + dir * _step).clamp(0.0, _c.position.maxScrollExtent).toDouble();
    _c.animateTo(target, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, cons) {
        final w = cons.maxWidth;
        final visible = w >= 1000 ? 4 : (w >= 720 ? 3 : (w >= 480 ? 2 : 1));
        const gap = 16.0;
        final itemW = (w - gap * (visible - 1)) / visible;
        _step = (itemW + gap) * visible;
        return Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _arrow(Icons.chevron_left, () => scrollBy(-1)),
              const SizedBox(width: 8),
              _arrow(Icons.chevron_right, () => scrollBy(1)),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 410,
            child: ListView.separated(
              controller: _c,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: gap),
              itemBuilder: (_, i) => SizedBox(width: itemW, child: ActivityCard(widget.items[i])),
            ),
          ),
        ]);
      });

  Widget _arrow(IconData icon, VoidCallback onTap) => Material(
        color: context.cardBg,
        shape: CircleBorder(side: BorderSide(color: context.line)),
        elevation: 2,
        child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon))),
      );
}
