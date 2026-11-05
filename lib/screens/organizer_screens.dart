import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'my_activities_screen.dart' show regStatusInfo;

// =============================================================== DASHBOARD
class OrganizerDashboard extends StatelessWidget {
  const OrganizerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final u = s.user!;
    final acts = s.managedBy(u);
    var totalApplicants = 0, pending = 0, attended = 0;
    for (final a in acts) {
      for (final r in s.regsOfActivity(a.id)) {
        totalApplicants++;
        if (r.status == RegStatus.pending) pending++;
        if (r.status == RegStatus.attended) attended++;
      }
    }
    final open = acts.where((a) => s.statusOf(a) == ActStatus.open).length;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: PageWrap(
          maxWidth: 1000,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Row(children: [
              const Expanded(child: Text('Kelola Aktivitas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800))),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityFormScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Buat'),
              ),
            ]),
            Text('Pantau pendaftar dan catat kehadiran relawan', style: TextStyle(color: context.muted)),
            const SizedBox(height: 16),
            ResponsiveWrap(minItemWidth: 200, maxCols: 4, spacing: 12, children: [
              _DashStat(Icons.event_note, '${acts.length}', 'Total aktivitas', AppColors.primary),
              _DashStat(Icons.lock_open, '$open', 'Sedang dibuka', AppColors.success),
              _DashStat(Icons.hourglass_top, '$pending', 'Menunggu konfirmasi', AppColors.accent),
              _DashStat(Icons.verified, '$attended', 'Relawan hadir (dari $totalApplicants)', AppColors.info),
            ]),
            const SectionHeader('Aktivitas saya'),
            if (acts.isEmpty)
              EmptyState(
                icon: Icons.add_circle_outline,
                title: 'Belum ada aktivitas',
                subtitle: 'Buat aktivitas pertama untuk mulai mencari relawan.',
                action: FilledButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityFormScreen())),
                    child: const Text('Buat Aktivitas')),
              )
            else
              ResponsiveWrap(minItemWidth: 440, maxCols: 2, children: acts.map((a) => _ManageTile(a)).toList()),
          ]),
        ),
      ),
    );
  }
}

class _DashStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _DashStat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label, style: TextStyle(fontSize: 12, color: context.muted)),
            ]),
          ),
        ]),
      );
}

class _ManageTile extends StatelessWidget {
  final Activity a;
  const _ManageTile(this.a);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final st = s.statusOf(a);
    final pending = s.pendingCount(a.id);
    final c = categoryInfo(a.category);
    return AppCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantsScreen(activityId: a.id))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: c.color.withAlpha(34), borderRadius: BorderRadius.circular(14)),
            child: Icon(c.icon, color: c.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.25)),
              InfoRow(Icons.calendar_month, fmtRange(a.start, a.end)),
              InfoRow(a.isOnline ? Icons.public : Icons.place, a.locationLabel),
            ]),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFormScreen(existing: a)));
              } else if (v == 'delete') {
                if (await confirmDialog(context, 'Hapus aktivitas?', 'Semua data pendaftar pada aktivitas ini ikut terhapus.',
                    confirmText: 'Hapus', danger: true)) {
                  s.deleteActivity(a.id);
                  if (context.mounted) toast(context, 'Aktivitas dihapus');
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        ProgressBar(a.quota == 0 ? 0 : s.joinedCount(a) / a.quota),
        const SizedBox(height: 8),
        Row(children: [
          Text('${s.joinedCount(a)} / ${a.quota} relawan', style: TextStyle(fontSize: 12.5, color: context.muted, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (pending > 0) Pill('$pending menunggu', color: AppColors.accent, icon: Icons.hourglass_top),
          const SizedBox(width: 6),
          StatusBadge(st),
        ]),
      ]),
    );
  }
}

// =============================================================== PENDAFTAR
class ApplicantsScreen extends StatefulWidget {
  final String activityId;
  const ApplicantsScreen({super.key, required this.activityId});
  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  RegStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.activityById(widget.activityId);
    if (a == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.event_busy, title: 'Aktivitas tidak ditemukan', subtitle: ''));
    }
    final all = s.regsOfActivity(a.id);
    final list = _filter == null ? all : all.where((r) => r.status == _filter).toList();
    int count(RegStatus st) => all.where((r) => r.status == st).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: PageWrap(
          maxWidth: 820,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text(a.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.25)),
            const SizedBox(height: 4),
            Text('${fmtRange(a.start, a.end)} • ${s.joinedCount(a)} / ${a.quota} relawan', style: TextStyle(color: context.muted)),
            const SizedBox(height: 14),
            SizedBox(
              height: 42,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _chip('Semua (${all.length})', null),
                _chip('Menunggu (${count(RegStatus.pending)})', RegStatus.pending),
                _chip('Diterima (${count(RegStatus.accepted)})', RegStatus.accepted),
                _chip('Hadir (${count(RegStatus.attended)})', RegStatus.attended),
                _chip('Ditolak (${count(RegStatus.rejected)})', RegStatus.rejected),
              ]),
            ),
            const SizedBox(height: 12),
            if (list.isEmpty)
              const EmptyState(icon: Icons.people_outline, title: 'Belum ada pendaftar', subtitle: 'Pendaftar akan muncul di sini.')
            else
              for (final r in list)
                Padding(padding: const EdgeInsets.only(bottom: 10), child: _ApplicantTile(r)),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, RegStatus? st) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: _filter == st, onSelected: (_) => setState(() => _filter = st)),
      );
}

class _ApplicantTile extends StatelessWidget {
  final Registration r;
  const _ApplicantTile(this.r);

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final info = regStatusInfo(r.status);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(40),
              child: Text(initials(r.userName), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('Mendaftar ${relTime(r.createdAt)}', style: TextStyle(fontSize: 12, color: context.muted)),
            ]),
          ),
          Pill(info.$1, color: info.$2, icon: info.$3),
        ]),
        if (r.motivation.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: context.softTeal, borderRadius: BorderRadius.circular(12)),
            child: Text('"${r.motivation}"', style: const TextStyle(fontStyle: FontStyle.italic, height: 1.35)),
          ),
        ],
        if (r.status == RegStatus.pending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size(0, 42)),
                onPressed: () {
                  s.setRegStatus(r.id, RegStatus.rejected);
                  toast(context, '${r.userName} ditolak');
                },
                child: const Text('Tolak'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
                onPressed: () {
                  s.setRegStatus(r.id, RegStatus.accepted);
                  toast(context, '${r.userName} diterima');
                },
                child: const Text('Terima'),
              ),
            ),
          ]),
        ],
        if (r.status == RegStatus.accepted) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 42)),
              onPressed: () {
                s.setRegStatus(r.id, RegStatus.attended);
                toast(context, 'Kehadiran ${r.userName} dicatat');
              },
              icon: const Icon(Icons.how_to_reg),
              label: const Text('Tandai Hadir'),
            ),
          ),
        ],
      ]),
    );
  }
}

// =============================================================== FORM
class ActivityFormScreen extends StatefulWidget {
  final Activity? existing;
  const ActivityFormScreen({super.key, this.existing});
  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _time = TextEditingController(text: '08:00 - 12:00 WIB');
  final _quota = TextEditingController(text: '20');
  final _hours = TextEditingController(text: '3');
  final _req = TextEditingController();
  final _ben = TextEditingController();
  final _skills = TextEditingController();
  final _agenda = TextEditingController();

  ActivityType _type = ActivityType.event;
  String _cat = kCategories.first.name;
  bool _online = false;
  DateTime _start = dayOnly(DateTime.now()).add(const Duration(days: 7));
  DateTime _end = dayOnly(DateTime.now()).add(const Duration(days: 7));
  DateTime _deadline = dayOnly(DateTime.now()).add(const Duration(days: 5));
  String? _err;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    if (a != null) {
      _title.text = a.title;
      _desc.text = a.description;
      _city.text = a.isOnline ? '' : a.city;
      _address.text = a.address;
      _time.text = a.time;
      _quota.text = '${a.quota}';
      _hours.text = '${a.hours}';
      _req.text = a.requirements.join('\n');
      _ben.text = a.benefits.join('\n');
      _skills.text = a.skills.join(', ');
      _agenda.text = a.agenda.join('\n');
      _type = a.type;
      _cat = a.category;
      _online = a.isOnline;
      _start = a.start;
      _end = a.end;
      _deadline = a.deadline;
    }
  }

  Future<void> _pick(DateTime initial, void Function(DateTime) set) async {
    final d = await showDatePicker(
        context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d != null) setState(() => set(d));
  }

  List<String> _lines(String t) => t.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  void _save() {
    final s = context.read<AppState>();
    final u = s.user!;
    if (_title.text.trim().length < 5) return setState(() => _err = 'Judul minimal 5 karakter');
    if (_desc.text.trim().length < 20) return setState(() => _err = 'Deskripsi minimal 20 karakter');
    if (!_online && _address.text.trim().isEmpty) return setState(() => _err = 'Alamat lokasi wajib diisi');
    final quota = int.tryParse(_quota.text) ?? 0;
    final hours = int.tryParse(_hours.text) ?? 0;
    if (quota < 1) return setState(() => _err = 'Kuota minimal 1 relawan');
    if (hours < 1) return setState(() => _err = 'Jam kontribusi minimal 1');
    if (_end.isBefore(_start)) return setState(() => _err = 'Tanggal selesai tidak boleh sebelum tanggal mulai');
    if (_deadline.isAfter(_end)) return setState(() => _err = 'Batas pendaftaran tidak boleh setelah tanggal selesai');
    final orgId = u.orgId ?? widget.existing?.orgId;
    if (orgId == null) return setState(() => _err = 'Akun Anda belum terhubung dengan organisasi');

    final a = Activity(
      id: widget.existing?.id ?? s.newActivityId(),
      title: _title.text.trim(),
      orgId: orgId,
      category: _cat,
      type: _type,
      city: _online ? 'Online' : _city.text.trim(),
      address: _address.text.trim().isEmpty ? 'Online' : _address.text.trim(),
      isOnline: _online,
      start: _start,
      end: _end,
      deadline: _deadline,
      time: _time.text.trim(),
      quota: quota,
      baseJoined: widget.existing?.baseJoined ?? 0,
      hours: hours,
      description: _desc.text.trim(),
      requirements: _lines(_req.text).isEmpty ? ['Berkomitmen hadir sesuai jadwal'] : _lines(_req.text),
      benefits: _lines(_ben.text).isEmpty ? ['E-sertifikat kontribusi'] : _lines(_ben.text),
      skills: _skills.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      agenda: _lines(_agenda.text),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      createdBy: u.id,
    );
    s.saveActivity(a, isNew: !_isEdit);
    Navigator.pop(context);
    toast(context, _isEdit ? 'Aktivitas diperbarui' : 'Aktivitas berhasil dibuat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Aktivitas' : 'Buat Aktivitas')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Informasi utama'),
              TextField(controller: _title, decoration: inputDeco(labelText: 'Judul aktivitas')),
              const SizedBox(height: 12),
              TextField(
                  controller: _desc,
                  maxLines: 5,
                  decoration: inputDeco(labelText: 'Deskripsi', alignLabelWithHint: true)),
              _label('Jenis aktivitas'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in ActivityType.values)
                  ChoiceChip(
                      avatar: Icon(typeIcon(t), size: 16),
                      label: Text(typeLabel(t)),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t)),
              ]),
              _label('Kategori'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in kCategories)
                  ChoiceChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: _cat == c.name,
                      onSelected: (_) => setState(() => _cat = c.name)),
              ]),
              _label('Lokasi'),
              SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Aktivitas online'),
                  value: _online,
                  onChanged: (v) => setState(() => _online = v)),
              if (!_online) ...[
                TextField(controller: _city, decoration: inputDeco(labelText: 'Kota')),
                const SizedBox(height: 12),
              ],
              TextField(
                  controller: _address,
                  decoration: inputDeco(labelText: _online ? 'Platform / tautan (opsional)' : 'Alamat lengkap')),
              _label('Jadwal'),
              Row(children: [
                Expanded(child: _dateBtn('Mulai', _start, (d) {
                  _start = d;
                  if (_end.isBefore(d)) _end = d;
                })),
                const SizedBox(width: 10),
                Expanded(child: _dateBtn('Selesai', _end, (d) => _end = d)),
              ]),
              const SizedBox(height: 12),
              _dateBtn('Batas pendaftaran', _deadline, (d) => _deadline = d),
              const SizedBox(height: 12),
              TextField(controller: _time, decoration: inputDeco(labelText: 'Jam pelaksanaan')),
              _label('Kuota & kontribusi'),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _quota, keyboardType: TextInputType.number, decoration: inputDeco(labelText: 'Kuota relawan'))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(
                        controller: _hours, keyboardType: TextInputType.number, decoration: inputDeco(labelText: 'Jam kontribusi'))),
              ]),
              _label('Detail tambahan (opsional)'),
              TextField(
                  controller: _req,
                  maxLines: 3,
                  decoration: inputDeco(labelText: 'Persyaratan (satu per baris)', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              TextField(
                  controller: _ben,
                  maxLines: 3,
                  decoration: inputDeco(labelText: 'Yang didapatkan relawan (satu per baris)', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              TextField(controller: _skills, decoration: inputDeco(labelText: 'Keahlian (pisahkan dengan koma)')),
              const SizedBox(height: 12),
              TextField(
                  controller: _agenda,
                  maxLines: 4,
                  decoration: inputDeco(
                      labelText: 'Agenda (format: 08:00|Registrasi)', alignLabelWithHint: true)),
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_err!, style: const TextStyle(color: AppColors.danger))),
                  ]),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: Text(_isEdit ? 'Simpan Perubahan' : 'Terbitkan Aktivitas')),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 10),
        child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );

  Widget _dateBtn(String label, DateTime v, void Function(DateTime) set) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pick(v, set),
        child: InputDecorator(
          decoration: inputDeco(labelText: label, suffixIcon: const Icon(Icons.calendar_month)),
          child: Text(fmtDate(v)),
        ),
      );
}
