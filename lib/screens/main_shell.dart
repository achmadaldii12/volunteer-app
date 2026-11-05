import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/app_state.dart';
import '../widgets/site_chrome.dart';
import 'about_screen.dart';
import 'home_screen.dart';
import 'my_activities_screen.dart';
import 'notifications_screen.dart';
import 'organizations_screen.dart';
import 'organizer_screens.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _nav = GlobalKey<NavigatorState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  int _i = 0;
  bool _isScrolled = false;

  bool get _org => context.read<AppState>().user?.isOrganizer ?? false;

  Widget _page(int i) {
    switch (i) {
      case NavIndex.activities:
        return const SearchScreen(embedded: true);
      case NavIndex.organizations:
        return const OrganizationsScreen();
      case NavIndex.mine:
        return _org ? const OrganizerDashboard() : const MyActivitiesScreen();
      case NavIndex.howItWorks:
        return const HowItWorksScreen(embedded: true);
      case NavIndex.about:
        return const AboutScreen();
      case NavIndex.profile:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Route<dynamic> _route(int i) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => Scaffold(body: _page(i)),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );

  void _go(int i) {
    setState(() {
      _i = i;
      _isScrolled = false;
    });
    _nav.currentState?.pushAndRemoveUntil(_route(i), (r) => false);
  }

  void _openNotifs() =>
      _nav.currentState?.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user;
    if (u == null) return const SizedBox.shrink();
    final wide = context.screenW >= 960;
    final items = <(String, int)>[
      ('Beranda', NavIndex.home),
      ('Cari Aktivitas', NavIndex.activities),
      ('Cari Organisasi', NavIndex.organizations),
      (u.isOrganizer ? 'Kelola Aktivitas' : 'Aktivitasku', NavIndex.mine),
      ('Cara Kerja', NavIndex.howItWorks),
      ('Tentang Kami', NavIndex.about),
    ];

    final body = NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (_i == 0) {
          if (notification.metrics.pixels > 30 && !_isScrolled) {
            setState(() => _isScrolled = true);
          } else if (notification.metrics.pixels <= 30 && _isScrolled) {
            setState(() => _isScrolled = false);
          }
        }
        return false;
      },
      child: ShellNav(
        go: _go,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Navigator(
            key: _nav,
            onGenerateRoute: (_) => _route(NavIndex.home),
          ),
        ),
      ),
    );

    final isHome = (_i == 0);
    final showTransparent = isHome && !_isScrolled;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final n = _nav.currentState;
        if (n != null && n.canPop()) {
          n.pop();
        } else if (_i != 0) {
          _go(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffold,
        drawer: wide ? null : _drawer(context, s, items),
        body: isHome
            ? Stack(children: [
                body,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: wide ? _topBar(context, s, items, showTransparent) : _mobileBar(context, s, showTransparent),
                ),
              ])
            : Column(children: [
                wide ? _topBar(context, s, items, false) : _mobileBar(context, s, false),
                Expanded(child: body),
              ]),
      ),
    );
  }

  // ------------------------------------------------------------ bar atas (desktop)
  Widget _topBar(BuildContext context, AppState s, List<(String, int)> items, bool transparent) {
    final u = s.user!;
    return Padding(
      // Padding atas dibuat 0 agar mentok ke atas, sementara kiri dan kanan tetap ada spasi
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        // Sudut atas dibuat lurus/tajam (0), sudut bawah melengkung penuh
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: Material(
          color: transparent ? Colors.transparent : AppColors.primary,
          elevation: transparent ? 0 : 4,
          child: SafeArea(
            bottom: false,
            top: false,
            child: SizedBox(
              height: 72,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(children: [
                      InkWell(onTap: () => _go(NavIndex.home), child: const BrandLogo()),
                      const SizedBox(width: 28),
                      for (final it in items)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _NavItem(label: it.$1, active: _i == it.$2, onTap: () => _go(it.$2)),
                        ),
                      const Spacer(),
                      Stack(clipBehavior: Clip.none, children: [
                        IconButton(
                          onPressed: _openNotifs,
                          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 26),
                        ),
                        if (s.unreadCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                              child: Text('${s.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ),
                      ]),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        tooltip: 'Akun',
                        position: PopupMenuPosition.under,
                        onSelected: (v) {
                          if (v == 'profile') _go(NavIndex.profile);
                          if (v == 'notif') _openNotifs();
                          if (v == 'logout') s.logout();
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              enabled: false,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
                                Text(u.email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ])),
                          const PopupMenuDivider(),
                          const PopupMenuItem(value: 'profile', child: ListTile(dense: true, leading: Icon(Icons.person_outline), title: Text('Profil Saya'))),
                          const PopupMenuItem(value: 'notif', child: ListTile(dense: true, leading: Icon(Icons.notifications_none), title: Text('Notifikasi'))),
                          const PopupMenuItem(value: 'logout', child: ListTile(dense: true, leading: Icon(Icons.logout), title: Text('Keluar'))),
                        ],
                        child: Row(children: [
                          CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.white,
                              child: Text(initials(u.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13))),
                          const SizedBox(width: 8),
                          Text(u.firstName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ bar atas (mobile)
  Widget _mobileBar(BuildContext context, AppState s, bool transparent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: Material(
          color: transparent ? Colors.transparent : AppColors.primary,
          elevation: transparent ? 0 : 4,
          child: SafeArea(
            bottom: false,
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(children: [
                IconButton(onPressed: () => _scaffold.currentState?.openDrawer(), icon: const Icon(Icons.menu, color: Colors.white)),
                InkWell(onTap: () => _go(NavIndex.home), child: const BrandLogo(size: 22)),
                const Spacer(),
                Stack(clipBehavior: Clip.none, children: [
                  IconButton(onPressed: _openNotifs, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                  if (s.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: Text('${s.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ]),
                const SizedBox(width: 4),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawer(BuildContext context, AppState s, List<(String, int)> items) {
    final u = s.user!;
    const icons = {
      NavIndex.home: Icons.home_outlined,
      NavIndex.activities: Icons.search,
      NavIndex.organizations: Icons.apartment,
      NavIndex.mine: Icons.assignment_turned_in_outlined,
      NavIndex.howItWorks: Icons.help_outline,
      NavIndex.about: Icons.info_outline,
    };
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: [
        Container(
          color: AppColors.primary,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const BrandLogo(),
            const SizedBox(height: 18),
            Row(children: [
              CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(initials(u.name), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  Text(u.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12)),
                ]),
              ),
            ]),
          ]),
        ),
        for (final it in items)
          ListTile(
            leading: Icon(icons[it.$2], color: _i == it.$2 ? AppColors.primary : null),
            title: Text(it.$1, style: TextStyle(fontWeight: _i == it.$2 ? FontWeight.w800 : FontWeight.w500, color: _i == it.$2 ? AppColors.primary : null)),
            selected: _i == it.$2,
            onTap: () {
              Navigator.pop(context);
              _go(it.$2);
            },
          ),
        const Divider(),
        ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil Saya'),
            onTap: () {
              Navigator.pop(context);
              _go(NavIndex.profile);
            }),
        ListTile(leading: const Icon(Icons.logout), title: const Text('Keluar'), onTap: () => s.logout()),
      ]),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.label, required this.active, required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : (_hover ? Colors.white.withAlpha(30) : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.active ? AppColors.primary : Colors.white,
              fontSize: 15,
              fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}