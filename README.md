# Volunteer App (Frontend Flutter)

Aplikasi relawan bergaya platform kerelawanan: cari aktivitas, daftar, pantau status,
catat jam kontribusi, sertifikat, serta sisi penyelenggara untuk mengelola pendaftar.

Versi ini **tidak membutuhkan backend**: data contoh dan data pengguna disimpan lokal
(shared_preferences). Lapisan data terpusat di `lib/providers/app_state.dart`, sehingga
nanti mudah diganti dengan pemanggilan API.

## Menjalankan
```
flutter pub get
flutter run -d chrome
```
Akun demo (password 123456): `relawan@demo.com` dan `organizer@demo.com`.

## Tampilan
Tema terang formal (merah), navigasi di bagian atas seperti situs web (menu: Beranda,
Cari Aktivitas, Cari Organisasi, Aktivitasku/Kelola, Cara Kerja, Tentang Kami, akun).
Di layar kecil menu berubah menjadi tombol hamburger.

## Struktur
- `core/` tema, warna kategori, utilitas
- `models/` model data + JSON
- `data/seed_data.dart` data contoh (organisasi, aktivitas, artikel)
- `providers/app_state.dart` seluruh logika: auth, pencarian, pendaftaran, notifikasi
- `widgets/common.dart` komponen UI bersama
- `screens/` seluruh halaman

## Fitur
Relawan: onboarding, login/daftar, beranda, pencarian + filter + urutkan, detail aktivitas,
daftar dengan motivasi, batal, simpan, ikuti organisasi, ulasan, sertifikat, level & lencana,
notifikasi, mode gelap, layout responsif (Chrome/tablet).
Penyelenggara: dasbor, buat/edit/hapus aktivitas, terima/tolak pendaftar, tandai hadir.
