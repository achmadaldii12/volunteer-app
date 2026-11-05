import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'certificate_screen.dart';
import 'organizer_screens.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;
  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fungsi scroll otomatis berdasarkan posisi piksel yang akurat
  void _scrollToSection(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    double targetOffset = 0;
    if (index == 0) {
      targetOffset = 0;        // Ke Bagian Deskripsi
    } else if (index == 1) {
      targetOffset = 420;      // Ke Bagian Detail Aktivitas
    } else if (index == 2) {
      targetOffset = 650;      // Ke Bagian Divisi
    } else if (index == 3) {
      targetOffset = 880;      // Ke Bagian Galeri
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.activityById(widget.activityId);
    if (a == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
            icon: Icons.event_busy, title: 'Aktivitas tidak ditemukan', subtitle: 'Aktivitas ini mungkin sudah dihapus.'),
      );
    }
    final u = s.user!;
    final org = s.orgOf(a);
    final st = s.statusOf(a);
    final joined = s.joinedCount(a);
    final reg = s.regFor(u.id, a.id);
    final isOwner = u.isOrganizer && org.ownerId == u.id;
    final bm = s.isBookmarked(a.id);
    final reviews = s.reviewsOf(a.id);
    final related = s.related(a);
    final isDesktop = context.screenW >= 960;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        toolbarHeight: 10,
        actions: [
          IconButton(
            icon: Icon(bm ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              s.toggleBookmark(a.id);
              toast(context, bm ? 'Dihapus dari tersimpan' : 'Disimpan ke Aktivitasku');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Clipboard.setData(ClipboardData(
                  text: '${a.title}\n${fmtRange(a.start, a.end)} • ${a.locationLabel}\nPenyelenggara: ${org.name}\nIkut jadi relawan lewat aplikasi Volunteer!'));
              toast(context, 'Info aktivitas disalin ke clipboard');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layout Utama Dua Kolom
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kolom Kiri: Banner proporsional, Organizer, Menu Tab & Isi Konten
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Banner Foto dengan ukuran proporsional (tidak memenuhi layar penuh)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: SizedBox(
                                          height: 380,
                                          width: double.infinity,
                                          child: ActivityCover(a, height: 380),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildOrganizerRow(context, s, org),
                                      const SizedBox(height: 20),

                                      // Tab Navigasi Menu Interaktif
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                                        ),
                                        child: Row(
                                          children: [
                                            _buildTabItem(0, 'Deskripsi', () => _scrollToSection(0)),
                                            _buildTabItem(1, 'Detail Aktivitas', () => _scrollToSection(1)),
                                            _buildTabItem(2, 'Divisi', () => _scrollToSection(2)),
                                            _buildTabItem(3, 'Galeri', () => _scrollToSection(3)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Bagian Konten Berurutan ke Bawah
                                      _buildDescSection(a),
                                      const SizedBox(height: 24),
                                      _buildDetailSection(a),
                                      const SizedBox(height: 24),
                                      _buildDivisionSection(),
                                      const SizedBox(height: 24),
                                      _buildGallerySection(),

                                      if (reviews.isNotEmpty) ...[
                                        const SizedBox(height: 32),
                                        const _Title('Ulasan relawan'),
                                        for (final r in reviews)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: AppCard(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Row(children: [
                                                  CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor: AppColors.primary.withAlpha(40),
                                                      child: Text(initials(r.userName), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary))),
                                                  const SizedBox(width: 10),
                                                  Expanded(child: Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700))),
                                                  for (var i = 0; i < 5; i++)
                                                    Icon(i < r.rating! ? Icons.star : Icons.star_border, size: 16, color: AppColors.accent),
                                                ]),
                                                if ((r.review ?? '').isNotEmpty) ...[const SizedBox(height: 8), Text(r.review!)],
                                              ]),
                                            ),
                                          ),
                                      ],
                                      if (related.isNotEmpty) ...[
                                        const SizedBox(height: 32),
                                        const _Title('Aktivitas serupa'),
                                        ResponsiveWrap(minItemWidth: 260, maxCols: 2, children: related.map((x) => ActivityCard(x)).toList()),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Kolom Kanan: Kartu Aksi Pendaftaran ("Jadi Relawan") yang ikut bergerak/sticky saat discroll
                                Expanded(
                                  flex: 5,
                                  child: StickySidebarWrapper(
                                    child: _buildRightActionCard(context, s, a, st, reg, isOwner, u, joined),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 240,
                                    width: double.infinity,
                                    child: ActivityCover(a, height: 240),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildOrganizerRow(context, s, org),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTabItem(0, 'Deskripsi', () => _scrollToSection(0)),
                                      _buildTabItem(1, 'Detail', () => _scrollToSection(1)),
                                      _buildTabItem(2, 'Divisi', () => _scrollToSection(2)),
                                      _buildTabItem(3, 'Galeri', () => _scrollToSection(3)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildRightActionCard(context, s, a, st, reg, isOwner, u, joined),
                                const SizedBox(height: 24),
                                _buildDescSection(a),
                                const SizedBox(height: 24),
                                _buildDetailSection(a),
                                const SizedBox(height: 24),
                                _buildDivisionSection(),
                                const SizedBox(height: 24),
                                _buildGallerySection(),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, VoidCallback onTap) {
    final active = _selectedTabIndex == index;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: active ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizerRow(BuildContext context, AppState s, Organization org) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => openOrg(context, org.id),
      child: Row(children: [
        OrgAvatar(org, size: 48),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(org.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
              if (org.verified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, size: 16, color: AppColors.info)),
            ]),
            Text('${org.city} • ${s.followersOf(org)} pengikut', style: TextStyle(fontSize: 13, color: context.muted)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDescSection(Activity a) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(a.description, style: const TextStyle(fontSize: 15, height: 1.6)),
          if (a.requirements.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Persyaratan Relawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final r in a.requirements) _CheckRow(Icons.check_circle, r, AppColors.primary),
          ],
          if (a.benefits.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Yang Kamu Dapatkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final r in a.benefits) _CheckRow(Icons.card_giftcard, r, AppColors.accent),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(Activity a) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('• Metode briefing: Tatap muka / Online via Zoom', style: TextStyle(fontSize: 14.5, height: 1.6)),
          const SizedBox(height: 6),
          const Text('• Sertifikat: E-Sertifikat Resmi Kerelawanan', style: TextStyle(fontSize: 14.5, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildDivisionSection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pekerjaan / Divisi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _divisionCard('Divisi Lapangan', 'Membantu koordinasi peserta dan jalannya acara utama.', '20 Relawan'),
          const SizedBox(height: 10),
          _divisionCard('Divisi Dokumentasi', 'Mengabadikan momen dan menyusun laporan visual kegiatan.', '5 Relawan'),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Galeri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _galleryBox('Foto Kegiatan 1'),
              _galleryBox('Foto Kegiatan 2'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightActionCard(BuildContext context, AppState s, Activity a, ActStatus st, Registration? reg, bool isOwner, AppUser u, int joined) {
    Widget button;
    String caption = '${s.remaining(a)} kuota tersisa';
    if (isOwner) {
      caption = '${s.pendingCount(a.id)} pendaftar menunggu';
      button = FilledButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantsScreen(activityId: a.id))),
        icon: const Icon(Icons.people),
        label: const Text('Kelola Pendaftar'),
      );
    } else if (u.isOrganizer) {
      button = const FilledButton(onPressed: null, child: Text('Hanya relawan yang dapat mendaftar'));
    } else if (reg != null) {
      switch (reg.status) {
        case RegStatus.pending:
          caption = 'Menunggu konfirmasi penyelenggara';
          button = OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              if (await confirmDialog(context, 'Batalkan pendaftaran?', 'Pendaftaranmu di aktivitas ini akan dibatalkan.',
                  confirmText: 'Batalkan', danger: true)) {
                s.cancelReg(reg.id);
                if (context.mounted) toast(context, 'Pendaftaran dibatalkan');
              }
            },
            icon: const Icon(Icons.hourglass_top),
            label: const Text('Menunggu • Batalkan'),
          );
          break;
        case RegStatus.accepted:
          caption = 'Kamu sudah diterima. Sampai jumpa di lokasi!';
          button = OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              if (await confirmDialog(context, 'Batalkan keikutsertaan?', 'Kuota akan dilepas untuk relawan lain.',
                  confirmText: 'Batalkan', danger: true)) {
                s.cancelReg(reg.id);
                if (context.mounted) toast(context, 'Keikutsertaan dibatalkan');
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Diterima • Batalkan'),
          );
          break;
        case RegStatus.attended:
          caption = 'Terima kasih sudah berkontribusi!';
          button = FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(regId: reg.id))),
            icon: const Icon(Icons.workspace_premium),
            label: const Text('Lihat Sertifikat'),
          );
          break;
        default:
          caption = 'Pendaftaranmu belum dapat diterima';
          button = const FilledButton(onPressed: null, child: Text('Pendaftaran tidak diterima'));
      }
    } else if (st == ActStatus.open) {
      button = FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        onPressed: () => _applySheet(context, a),
        child: const Text('Jadi Relawan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
    } else {
      caption = st == ActStatus.full ? 'Kuota sudah penuh' : 'Periode pendaftaran berakhir';
      button = FilledButton(onPressed: null, child: Text(st == ActStatus.full ? 'Kuota Penuh' : 'Pendaftaran Ditutup'));
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [TypeChip(a.type), const SizedBox(width: 8), Pill(a.category, color: AppColors.primary)]),
          const SizedBox(height: 14),
          Text(a.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_month, 'Jadwal Event', fmtRange(a.start, a.end)),
          const SizedBox(height: 12),
          _infoRow(Icons.schedule, 'Waktu', a.time),
          const SizedBox(height: 12),
          _infoRow(Icons.place, 'Lokasi', a.isOnline ? 'Online • ${a.address}' : '${a.city} • ${a.address}'),
          const SizedBox(height: 12),
          _infoRow(Icons.event_available, 'Batas Pendaftaran', fmtDate(a.deadline)),
          const SizedBox(height: 16),
          ProgressBar(a.quota == 0 ? 0 : joined / a.quota, height: 8),
          const SizedBox(height: 6),
          Text(caption, style: TextStyle(fontSize: 12.5, color: context.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          button,
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => toast(context, 'Menghubungkan ke kontak organisasi...'),
              child: const Text('Kontak Organisasi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Text(value, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        ]),
      ),
    ]);
  }

  Widget _divisionCard(String title, String desc, String quota) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: Text(quota, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ]),
    );
  }

  Widget _galleryBox(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 36, color: Colors.grey),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _applySheet(BuildContext context, Activity a) async {
    final ctrl = TextEditingController();
    var agree = false;
    String? err;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text('Daftar jadi relawan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(a.title, style: TextStyle(color: context.muted)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 4,
                maxLength: 300,
                decoration: inputDeco(
                    labelText: 'Motivasi mengikuti aktivitas', hintText: 'Ceritakan alasan dan pengalamanmu secara singkat...', alignLabelWithHint: true),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: agree,
                onChanged: (v) => setM(() => agree = v ?? false),
                title: const Text('Saya bersedia hadir sesuai jadwal dan mengikuti arahan koordinator.', style: TextStyle(fontSize: 13.5)),
              ),
              if (err != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(err!, style: const TextStyle(color: AppColors.danger))),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (ctrl.text.trim().length < 10) {
                      setM(() => err = 'Motivasi minimal 10 karakter');
                      return;
                    }
                    if (!agree) {
                      setM(() => err = 'Centang pernyataan kesediaan terlebih dahulu');
                      return;
                    }
                    final e = context.read<AppState>().apply(a, ctrl.text);
                    if (e != null) {
                      setM(() => err = e);
                    } else {
                      Navigator.pop(ctx);
                      toast(context, 'Pendaftaran terkirim! Pantau statusnya di Aktivitasku.');
                    }
                  },
                  child: const Text('Kirim Pendaftaran'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// Widget Sticky Sidebar untuk Kartu Aksi Kanan agar ikut bergerak/sticky saat discroll
class StickySidebarWrapper extends StatelessWidget {
  final Widget child;
  const StickySidebarWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );
}

class _CheckRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _CheckRow(this.icon, this.text, this.color);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ]),
      );
}