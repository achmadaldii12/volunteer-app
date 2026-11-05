import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils.dart';
import '../data/seed_data.dart';
import '../models/models.dart';

class LevelInfo {
  final String name;
  final int minHours;
  final int? nextHours;
  const LevelInfo(this.name, this.minHours, this.nextHours);
}

LevelInfo levelFor(int hours) {
  if (hours >= 50) return const LevelInfo('Pahlawan Komunitas', 50, null);
  if (hours >= 20) return const LevelInfo('Relawan Andalan', 20, 50);
  if (hours >= 5) return const LevelInfo('Relawan Aktif', 5, 20);
  return const LevelInfo('Relawan Baru', 0, 5);
}

class AppState extends ChangeNotifier {
  static const _key = 'volunteer_state_v3';

  bool ready = false;
  bool onboarded = false;
  ThemeMode themeMode = ThemeMode.light;
  String? sessionId;

  List<AppUser> users = [];
  List<Registration> regs = [];
  List<Activity> customActivities = [];
  List<Organization> customOrgs = [];
  List<Notif> notifs = [];
  Set<String> bookmarks = {};
  Set<String> follows = {};
  Set<String> hiddenSeed = {};

  final List<Organization> seedOrgs = SeedData.organizations();
  final List<Activity> seedActivities = SeedData.activities(DateTime.now());

  int _counter = 0;
  String _id(String p) => '${p}_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  // ---------------------------------------------------------------- init
  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw != null) {
      try {
        _load(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _seed();
      }
    } else {
      _seed();
    }
    ready = true;
    notifyListeners();
  }

  void _seed() {
    final now = DateTime.now();
    users = SeedData.users();
    regs = SeedData.registrations(now);
    notifs = SeedData.notifications(now);
    customActivities = [];
    customOrgs = [];
    bookmarks = {};
    follows = {};
    hiddenSeed = {};
    sessionId = null;
    _save();
  }

  void _load(Map<String, dynamic> j) {
    onboarded = j['onboarded'] ?? false;
    sessionId = j['sessionId'];
    themeMode = ThemeMode.values.byName(j['theme'] ?? 'light');
    users = (j['users'] as List).map((e) => AppUser.fromJson(e)).toList();
    regs = (j['regs'] as List).map((e) => Registration.fromJson(e)).toList();
    customActivities = (j['custom'] as List).map((e) => Activity.fromJson(e)).toList();
    customOrgs = (j['orgs'] as List).map((e) => Organization.fromJson(e)).toList();
    notifs = (j['notifs'] as List).map((e) => Notif.fromJson(e)).toList();
    bookmarks = Set<String>.from(j['bookmarks'] ?? []);
    follows = Set<String>.from(j['follows'] ?? []);
    hiddenSeed = Set<String>.from(j['hidden'] ?? []);
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _key,
        jsonEncode({
          'onboarded': onboarded,
          'sessionId': sessionId,
          'theme': themeMode.name,
          'users': users.map((e) => e.toJson()).toList(),
          'regs': regs.map((e) => e.toJson()).toList(),
          'custom': customActivities.map((e) => e.toJson()).toList(),
          'orgs': customOrgs.map((e) => e.toJson()).toList(),
          'notifs': notifs.map((e) => e.toJson()).toList(),
          'bookmarks': bookmarks.toList(),
          'follows': follows.toList(),
          'hidden': hiddenSeed.toList(),
        }));
  }

  void _commit() {
    _save();
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    _seed();
    notifyListeners();
  }

  // ---------------------------------------------------------------- app
  void finishOnboarding() {
    onboarded = true;
    _commit();
  }

  void setThemeMode(ThemeMode m) {
    themeMode = m;
    _commit();
  }

  // ---------------------------------------------------------------- auth
  AppUser? get user => sessionId == null ? null : users.where((u) => u.id == sessionId).firstOrNull;

  String? login(String email, String password) {
    final e = email.trim().toLowerCase();
    final u = users.where((u) => u.email.toLowerCase() == e).firstOrNull;
    if (u == null || u.password != password) return 'Email atau password salah';
    sessionId = u.id;
    _commit();
    return null;
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String city = '',
    String orgName = '',
    List<String> interests = const [],
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Semua kolom wajib diisi';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      return 'Format email tidak valid';
    }
    if (password.length < 6) return 'Password minimal 6 karakter';
    if (users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      return 'Email sudah terdaftar';
    }
    final uid = _id('u');
    String? orgId;
    if (role == UserRole.organizer) {
      if (orgName.trim().isEmpty) return 'Nama organisasi wajib diisi';
      orgId = _id('org');
      customOrgs.add(Organization(
        id: orgId,
        name: orgName.trim(),
        tagline: 'Organisasi baru di Volunteer',
        about: 'Belum ada deskripsi. Lengkapi profil organisasi Anda.',
        type: 'Komunitas',
        city: city.trim(),
        category: 'Sosial',
        email: email.trim(),
        ownerId: uid,
        rating: 0,
      ));
    }
    users.add(AppUser(
      id: uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      role: role,
      city: city.trim(),
      interests: List<String>.from(interests),
      orgId: orgId,
    ));
    sessionId = uid;
    _notify(uid, 'Selamat datang di Volunteer',
        role == UserRole.organizer
            ? 'Akun penyelenggara siap. Buat aktivitas pertama untuk mencari relawan.'
            : 'Jelajahi aktivitas dan mulai kontribusi pertamamu hari ini.',
        'info');
    _commit();
    return null;
  }

  void logout() {
    sessionId = null;
    _commit();
  }

  void updateProfile({
    required String name,
    required String city,
    required String bio,
    required String phone,
    required List<String> interests,
  }) {
    final u = user;
    if (u == null) return;
    u.name = name.trim();
    u.city = city.trim();
    u.bio = bio.trim();
    u.phone = phone.trim();
    u.interests = interests;
    _commit();
  }

  // ---------------------------------------------------------------- data
  List<Activity> get allActivities => [
        ...seedActivities.where((a) => !hiddenSeed.contains(a.id)),
        ...customActivities,
      ];
  List<Organization> get allOrgs => [...seedOrgs, ...customOrgs];

  Activity? activityById(String id) => allActivities.where((a) => a.id == id).firstOrNull;
  Organization? orgById(String id) => allOrgs.where((o) => o.id == id).firstOrNull;
  Organization orgOf(Activity a) => orgById(a.orgId) ?? seedOrgs.first;

  List<String> get cities {
    final s = <String>{};
    for (final a in allActivities) {
      if (!a.isOnline && a.city.isNotEmpty) s.add(a.city);
    }
    return s.toList()..sort();
  }

  int joinedCount(Activity a) =>
      a.baseJoined +
      regs
          .where((r) =>
              r.activityId == a.id &&
              (r.status == RegStatus.pending ||
                  r.status == RegStatus.accepted ||
                  r.status == RegStatus.attended))
          .length;

  int remaining(Activity a) => (a.quota - joinedCount(a)).clamp(0, a.quota);

  ActStatus statusOf(Activity a) {
    final today = dayOnly(DateTime.now());
    if (a.end.isBefore(today)) return ActStatus.finished;
    if (a.deadline.isBefore(today)) return ActStatus.closed;
    if (joinedCount(a) >= a.quota) return ActStatus.full;
    return ActStatus.open;
  }

  List<Activity> query({
    String q = '',
    Set<String> categories = const {},
    ActivityType? type,
    String? city,
    bool onlineOnly = false,
    bool onlyOpen = true,
    String sort = 'terdekat',
  }) {
    final text = q.trim().toLowerCase();
    var list = allActivities.where((a) {
      if (onlyOpen && statusOf(a) != ActStatus.open) return false;
      if (categories.isNotEmpty && !categories.contains(a.category)) return false;
      if (type != null && a.type != type) return false;
      if (onlineOnly && !a.isOnline) return false;
      if (city != null && city.isNotEmpty && a.city != city) return false;
      if (text.isNotEmpty) {
        final org = orgOf(a).name.toLowerCase();
        final hay = '${a.title} ${a.city} ${a.address} ${a.category} ${a.description} $org'.toLowerCase();
        if (!hay.contains(text)) return false;
      }
      return true;
    }).toList();
    switch (sort) {
      case 'terbaru':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'populer':
        list.sort((a, b) => joinedCount(b).compareTo(joinedCount(a)));
        break;
      case 'kuota':
        list.sort((a, b) => remaining(b).compareTo(remaining(a)));
        break;
      default:
        list.sort((a, b) => a.start.compareTo(b.start));
    }
    return list;
  }

  List<Activity> get closingSoon {
    final list = allActivities
        .where((a) => statusOf(a) == ActStatus.open && daysLeft(a.deadline) <= 7)
        .toList();
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  List<Activity> activitiesOfOrg(String orgId) =>
      allActivities.where((a) => a.orgId == orgId).toList()
        ..sort((a, b) => b.start.compareTo(a.start));

  /// Statistik organisasi: (jumlah aktivitas, jumlah relawan, total jam kontribusi)
  (int, int, int) orgStats(String orgId) {
    var vol = 0, hours = 0;
    final acts = activitiesOfOrg(orgId);
    for (final a in acts) {
      final j = joinedCount(a);
      vol += j;
      hours += j * a.hours;
    }
    return (acts.length, vol, hours);
  }

  List<Organization> queryOrgs({
    String q = '',
    String? province,
    String? focus,
    String? type,
    String sort = 'terbaru',
  }) {
    final text = q.trim().toLowerCase();
    final list = allOrgs.where((o) {
      if (province != null && provinceOf(o.city) != province) return false;
      if (focus != null && o.category != focus) return false;
      if (type != null && o.type != type) return false;
      if (text.isNotEmpty && !'${o.name} ${o.city} ${o.tagline}'.toLowerCase().contains(text)) return false;
      return true;
    }).toList();
    DateTime latest(Organization o) {
      final acts = activitiesOfOrg(o.id);
      if (acts.isEmpty) return DateTime(2000);
      return acts.map((a) => a.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
    }
    switch (sort) {
      case 'nama':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'relawan':
        list.sort((a, b) => orgStats(b.id).$2.compareTo(orgStats(a.id).$2));
        break;
      case 'jam':
        list.sort((a, b) => orgStats(b.id).$3.compareTo(orgStats(a.id).$3));
        break;
      default:
        list.sort((a, b) => latest(b).compareTo(latest(a)));
    }
    return list;
  }

  List<Activity> related(Activity a) {
    final list = allActivities
        .where((x) => x.id != a.id && statusOf(x) == ActStatus.open && (x.category == a.category || x.orgId == a.orgId))
        .toList();
    return list.take(4).toList();
  }

  // ---------------------------------------------------------------- registrations
  Registration? regFor(String userId, String activityId) => regs
      .where((r) => r.userId == userId && r.activityId == activityId && r.status != RegStatus.cancelled)
      .firstOrNull;

  List<Registration> regsOfUser(String userId) =>
      regs.where((r) => r.userId == userId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Registration> regsOfActivity(String activityId) =>
      regs.where((r) => r.activityId == activityId && r.status != RegStatus.cancelled).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Registration> reviewsOf(String activityId) =>
      regs.where((r) => r.activityId == activityId && r.rating != null).toList();

  String? apply(Activity a, String motivation) {
    final u = user;
    if (u == null) return 'Silakan masuk terlebih dahulu';
    if (u.isOrganizer) return 'Akun penyelenggara tidak dapat mendaftar sebagai relawan';
    if (regFor(u.id, a.id) != null) return 'Kamu sudah terdaftar di aktivitas ini';
    final st = statusOf(a);
    if (st == ActStatus.full) return 'Mohon maaf, kuota sudah penuh';
    if (st != ActStatus.open) return 'Pendaftaran sudah ditutup';
    regs.add(Registration(
        id: _id('r'),
        activityId: a.id,
        userId: u.id,
        userName: u.name,
        motivation: motivation.trim()));
    _notify(u.id, 'Pendaftaran terkirim',
        'Pendaftaranmu di "${a.title}" sedang ditinjau penyelenggara.', 'info');
    final owner = orgOf(a).ownerId;
    if (owner != null) {
      _notify(owner, 'Pendaftar baru', '${u.name} mendaftar di "${a.title}".', 'info');
    }
    _commit();
    return null;
  }

  void cancelReg(String regId) {
    final r = regs.where((r) => r.id == regId).firstOrNull;
    if (r == null) return;
    if (r.status == RegStatus.pending || r.status == RegStatus.accepted) {
      r.status = RegStatus.cancelled;
      _commit();
    }
  }

  void setRegStatus(String regId, RegStatus status) {
    final r = regs.where((r) => r.id == regId).firstOrNull;
    if (r == null) return;
    final a = activityById(r.activityId);
    r.status = status;
    final title = a?.title ?? 'aktivitas';
    switch (status) {
      case RegStatus.accepted:
        _notify(r.userId, 'Pendaftaran diterima', 'Selamat! Kamu diterima di "$title".', 'success');
        break;
      case RegStatus.rejected:
        _notify(r.userId, 'Pendaftaran belum diterima',
            'Mohon maaf, pendaftaranmu di "$title" belum dapat diterima.', 'warning');
        break;
      case RegStatus.attended:
        _notify(r.userId, 'Kehadiran tercatat',
            'Terima kasih sudah hadir di "$title". Sertifikatmu sudah tersedia.', 'success');
        break;
      default:
        break;
    }
    _commit();
  }

  void submitReview(String regId, int rating, String text) {
    final r = regs.where((r) => r.id == regId).firstOrNull;
    if (r == null) return;
    r.rating = rating;
    r.review = text.trim();
    _commit();
  }

  // ---------------------------------------------------------------- stats
  List<Registration> attendedOf(String userId) =>
      regs.where((r) => r.userId == userId && r.status == RegStatus.attended).toList();

  int hoursOf(String userId) {
    var h = 0;
    for (final r in attendedOf(userId)) {
      h += activityById(r.activityId)?.hours ?? 0;
    }
    return h;
  }

  Set<String> categoriesDone(String userId) {
    final s = <String>{};
    for (final r in attendedOf(userId)) {
      final a = activityById(r.activityId);
      if (a != null) s.add(a.category);
    }
    return s;
  }

  // ---------------------------------------------------------------- bookmarks & follows
  bool isBookmarked(String activityId) => user != null && bookmarks.contains('${user!.id}:$activityId');

  void toggleBookmark(String activityId) {
    final u = user;
    if (u == null) return;
    final k = '${u.id}:$activityId';
    bookmarks.contains(k) ? bookmarks.remove(k) : bookmarks.add(k);
    _commit();
  }

  List<Activity> get bookmarkedActivities {
    final u = user;
    if (u == null) return [];
    return allActivities.where((a) => bookmarks.contains('${u.id}:${a.id}')).toList();
  }

  bool isFollowing(String orgId) => user != null && follows.contains('${user!.id}:$orgId');

  void toggleFollow(String orgId) {
    final u = user;
    if (u == null) return;
    final k = '${u.id}:$orgId';
    follows.contains(k) ? follows.remove(k) : follows.add(k);
    _commit();
  }

  int followersOf(Organization o) =>
      o.followersBase + follows.where((k) => k.endsWith(':${o.id}')).length;

  int followingCount(String userId) => follows.where((k) => k.startsWith('$userId:')).length;

  // ---------------------------------------------------------------- notifications
  void _notify(String userId, String title, String body, String kind) {
    notifs.add(Notif(id: _id('n'), userId: userId, title: title, body: body, kind: kind));
  }

  List<Notif> get myNotifs {
    final u = user;
    if (u == null) return [];
    return notifs.where((n) => n.userId == u.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get unreadCount => myNotifs.where((n) => !n.read).length;

  void markAllRead() {
    for (final n in myNotifs) {
      n.read = true;
    }
    _commit();
  }

  // ---------------------------------------------------------------- organizer
  List<Activity> managedBy(AppUser u) {
    final orgId = u.orgId;
    if (orgId == null) return [];
    return activitiesOfOrg(orgId);
  }

  int pendingCount(String activityId) =>
      regs.where((r) => r.activityId == activityId && r.status == RegStatus.pending).length;

  void saveActivity(Activity a, {bool isNew = true}) {
    if (isNew) {
      customActivities.add(a);
    } else {
      final i = customActivities.indexWhere((x) => x.id == a.id);
      if (i >= 0) {
        customActivities[i] = a;
      } else {
        // activity bawaan: sembunyikan versi lama lalu simpan salinan baru
        hiddenSeed.add(a.id);
        customActivities.add(a);
      }
    }
    _commit();
  }

  void deleteActivity(String id) {
    customActivities.removeWhere((a) => a.id == id);
    if (seedActivities.any((a) => a.id == id)) hiddenSeed.add(id);
    regs.removeWhere((r) => r.activityId == id);
    _commit();
  }

  String newActivityId() => _id('act');
}
