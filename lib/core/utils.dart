import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _loc = 'id_ID';

String fmtDate(DateTime d) => DateFormat('d MMM yyyy', _loc).format(d);
String fmtLong(DateTime d) => DateFormat('EEEE, d MMMM yyyy', _loc).format(d);
String fmtShort(DateTime d) => DateFormat('d MMM', _loc).format(d);
String fmtNum(num n) => NumberFormat('#,###', _loc).format(n);

String fmtRange(DateTime a, DateTime b) {
  if (a.year == b.year && a.month == b.month && a.day == b.day) return fmtDate(a);
  return '${fmtShort(a)} - ${fmtDate(b)}';
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int daysLeft(DateTime d) => dayOnly(d).difference(dayOnly(DateTime.now())).inDays;

String relTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return fmtDate(t);
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Selamat pagi';
  if (h < 15) return 'Selamat siang';
  if (h < 18) return 'Selamat sore';
  return 'Selamat malam';
}

String initials(String name) {
  final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  if (p.length == 1) return p.first.substring(0, 1).toUpperCase();
  return (p.first.substring(0, 1) + p[1].substring(0, 1)).toUpperCase();
}

void toast(BuildContext context, String msg, {bool error = false}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? const Color(0xFFB91C1C) : null,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

Future<bool> confirmDialog(BuildContext context, String title, String message,
    {String confirmText = 'Ya', bool danger = false}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: const Size(90, 42),
              backgroundColor: danger ? const Color(0xFFDC2626) : null),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return r ?? false;
}

const _provinces = {
  'Surabaya': 'Jawa Timur',
  'Gresik': 'Jawa Timur',
  'Malang': 'Jawa Timur',
  'Sidoarjo': 'Jawa Timur',
  'Jakarta': 'DKI Jakarta',
  'Yogyakarta': 'DI Yogyakarta',
  'Bandung': 'Jawa Barat',
  'Semarang': 'Jawa Tengah',
  'Denpasar': 'Bali',
  'Medan': 'Sumatera Utara',
};

String provinceOf(String city) => _provinces[city] ?? '';
String locationLabel(String city) {
  final p = provinceOf(city);
  return p.isEmpty ? city : '$city, $p';
}
