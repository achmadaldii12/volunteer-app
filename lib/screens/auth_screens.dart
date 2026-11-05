import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class _AuthHeader extends StatelessWidget {
  final String title, subtitle;
  const _AuthHeader(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: const Icon(Icons.volunteer_activism, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: context.muted), textAlign: TextAlign.center),
      ]);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;
  String? _err;

  void _submit() {
    final e = context.read<AppState>().login(_email.text, _pass.text);
    if (e != null) setState(() => _err = e);
  }

  void _demo(String email) {
    _email.text = email;
    _pass.text = '123456';
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final form = SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(children: [
                const _AuthHeader('Selamat datang', 'Masuk untuk mulai berbagi waktu dan kebaikan'),
                const SizedBox(height: 30),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDeco(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pass,
                  obscureText: _hide,
                  onSubmitted: (_) => _submit(),
                  decoration: inputDeco(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hide = !_hide)),
                  ),
                ),
                if (_err != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                      const SizedBox(width: 6),
                      Expanded(child: Text(_err!, style: const TextStyle(color: AppColors.danger))),
                    ]),
                  ),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _submit, child: const Text('Masuk'))),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Belum punya akun? Daftar sekarang'),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Divider(color: context.line)),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau coba akun demo', style: TextStyle(color: context.muted, fontSize: 12.5))),
                  Expanded(child: Divider(color: context.line)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () => _demo('relawan@demo.com'),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Relawan'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: OutlinedButton.icon(
                          onPressed: () => _demo('organizer@demo.com'),
                          icon: const Icon(Icons.business_outlined),
                          label: const Text('Penyelenggara'))),
                ]),
              ]),
            ),
          ),
        ),
      );
    if (context.screenW < 900) return Scaffold(body: form);
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(56),
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6E0C17), Color(0xFFD6202F)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Stack(children: [
              Positioned(right: -40, bottom: -40, child: Icon(Icons.volunteer_activism, size: 360, color: Colors.white.withAlpha(22))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Row(children: [
                  Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                  SizedBox(width: 10),
                  Text('Volunteer', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                ]),
                const SizedBox(height: 32),
                const Text('Jadilah relawan,\nmulai dari sini',
                    style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800, height: 1.15)),
                const SizedBox(height: 16),
                Text('Temukan kegiatan sosial yang sesuai minatmu dan catat setiap kontribusimu.',
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 18, height: 1.5)),
              ]),
            ]),
          ),
        ),
        Expanded(flex: 4, child: form),
      ]),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _city = TextEditingController();
  final _org = TextEditingController();
  UserRole _role = UserRole.volunteer;
  final Set<String> _interests = {};
  String? _err;

  void _submit() {
    final e = context.read<AppState>().register(
          name: _name.text,
          email: _email.text,
          password: _pass.text,
          role: _role,
          city: _city.text,
          orgName: _org.text,
          interests: _interests.toList(),
        );
    if (e != null) {
      setState(() => _err = e);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = _role == UserRole.organizer;
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Saya ingin mendaftar sebagai', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _roleCard(UserRole.volunteer, Icons.person, 'Relawan', 'Ikut aktivitas sosial')),
                const SizedBox(width: 12),
                Expanded(child: _roleCard(UserRole.organizer, Icons.business, 'Penyelenggara', 'Cari relawan')),
              ]),
              const SizedBox(height: 20),
              TextField(
                  controller: _name,
                  decoration: inputDeco(
                      labelText: isOrg ? 'Nama penanggung jawab' : 'Nama lengkap',
                      prefixIcon: const Icon(Icons.badge_outlined))),
              const SizedBox(height: 12),
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDeco(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
              const SizedBox(height: 12),
              TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: inputDeco(
                      labelText: 'Password (min. 6 karakter)', prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 12),
              TextField(
                  controller: _city,
                  decoration: inputDeco(labelText: 'Kota domisili', prefixIcon: Icon(Icons.place_outlined))),
              if (isOrg) ...[
                const SizedBox(height: 12),
                TextField(
                    controller: _org,
                    decoration: inputDeco(
                        labelText: 'Nama organisasi / komunitas', prefixIcon: Icon(Icons.apartment))),
              ] else ...[
                const SizedBox(height: 20),
                const Text('Isu yang kamu minati', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Pilih satu atau lebih (opsional)', style: TextStyle(color: context.muted, fontSize: 12.5)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in kCategories)
                    FilterChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: _interests.contains(c.name),
                      onSelected: (v) => setState(() => v ? _interests.add(c.name) : _interests.remove(c.name)),
                    ),
                ]),
              ],
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(_err!, style: const TextStyle(color: AppColors.danger)),
                ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: _submit, child: const Text('Daftar'))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(UserRole r, IconData icon, String title, String sub) {
    final sel = _role == r;
    return AppCard(
      onTap: () => setState(() => _role = r),
      color: sel ? context.softTeal : null,
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Icon(icon, size: 30, color: sel ? AppColors.primary : context.muted),
        const SizedBox(height: 6),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: sel ? AppColors.primary : null)),
        Text(sub, style: TextStyle(fontSize: 11.5, color: context.muted), textAlign: TextAlign.center),
      ]),
    );
  }
}
