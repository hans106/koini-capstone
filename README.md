# Koini

Aplikasi Android yang membantu anak usia **6–12 tahun** belajar mengatur uang saku tunai dan menabung untuk impiannya, didampingi orang tua.

Proyek Capstone mata kuliah **Digital Entrepreneurship Product Development (DEPD)**, Informatika, Universitas Ciputra, Semester 5 (2026). Tim **Sharpener**.

> Koini hanya **mencatat dan mengajarkan**. Uangnya tetap tunai (di celengan atau dipegang orang tua) — tidak ada penyimpanan uang sungguhan, rekening bank, QRIS, atau dompet digital.

## Masalah yang diselesaikan

Dari survei 12 orang tua (9 responden dengan anak di usia target 6–12 tahun):
- Tantangan terbesar adalah anak **cepat bosan / tidak konsisten** menabung (6 dari 9 responden).
- 7 dari 9 anak sebenarnya **sudah bisa** menabung, tetapi kebiasaannya tidak bertahan.
- 7 dari 9 anak **belum konsisten membedakan kebutuhan dan keinginan**.

## Fitur utama (MVP)

- **Masuk & pengaturan awal:** login orang tua (Google Sign-In / email lewat Supabase Auth), persetujuan data anak, PIN orang tua 6 angka (disimpan lokal di perangkat), profil anak, dan pengaturan uang saku.
- **Tiga toples & periode uang saku:** Tabung, Jajan, Berbagi dengan pilihan periode **harian, mingguan, atau bulanan**. Saldo dihitung otomatis dari catatan.
- **Sisa jajan otomatis ke tabungan:** di akhir periode, sisa toples Jajan dipindahkan otomatis ke toples Tabung melalui fungsi database (`sisa_jajan`) yang idempoten, lengkap dengan notifikasi pengingat memasukkan uang tunai ke celengan.
- **Catat uang & Cek Celengan:** catat jajan, menabung ke impian, berbagi, dan uang masuk di luar uang saku, serta layar **Cek Celengan** untuk mencocokkan uang tunai fisik dengan catatan aplikasi.
- **Rasi Impianku:** impian utama terisi otomatis dari tabungan, progres digambar sebagai rasi bintang, disertai perkiraan waktu tercapai otomatis.
- **Misi cerita (50 soal kuis literasi keuangan OJK):** 5 topik (*butuh atau mau, menabung bertahap, mengatur jajan, menahan keinginan, promo*) × 2 level (10 misi × 5 soal), disertai penjelasan benar/salah, bintang, streak, dan galeri lencana.
- **Panduan pertama kali:** tutorial singkat 4 langkah saat anak pertama kali membuka aplikasi.
- **Area orang tua (terkunci PIN):** Ringkasan, Detail perkembangan, Atur uang saku, Ganti PIN, dan kelola Koini Plus.
- **Koini Plus (simulasi Rp5.000/bulan atau Rp50.000/tahun):** membuka **Tantangan Hadiah** (orang tua membuat tantangan & mengonfirmasi hadiah masuk ke impian), **Bonus Tabungan** (orang tua menjanjikan bonus jika tabungan utuh sampai waktu tertentu), serta **Rapor Uang Bulanan**. Pembayaran pada MVP hanya disimulasikan tanpa perpindahan uang.

## Prototipe

Prototipe interaktif (hasil desain Figma V3): <https://hans106.github.io/koini-v3-final-design-testing/>

## Tech stack

| Bagian | Teknologi |
|---|---|
| Aplikasi mobile | Flutter (Dart), Android. `flutter_riverpod`, `go_router`, `supabase_flutter`, `google_sign_in`, `flutter_secure_storage`, `intl` |
| Backend & database | Supabase: PostgreSQL (14 tabel), Auth (Google Sign-In & Email), Row Level Security (RLS), Postgres Function (`sisa_jajan`) |
| Konten kuis | Bank 50 soal cerita acuan buku literasi keuangan OJK tingkat SD (*Mengenal Jasa Keuangan* / SikapiUangmu), tersimpan di PostgreSQL |
| Distribusi | File APK (Google Drive / WhatsApp untuk uji coba) |

## Struktur repo

```text
mobile/      Aplikasi Flutter (Android), state management, layar anak & orang tua, serta unit/widget tests
supabase/    Konfigurasi Supabase CLI, migrasi skema 14 tabel + RLS + fungsi sisa_jajan, dan seed 50 soal + lencana
```

## Status pengerjaan

| Tahap | Status |
|---|---|
| Survei pengguna, Lean Canvas, wireframe, desain hi-fi | Selesai |
| Prototipe interaktif + usability testing Week 8–9 | Selesai |
| ERD (14 tabel), sequence diagram, spesifikasi MVP | Selesai |
| Setup proyek Flutter (Android) & UI seluruh layar utama | Selesai |
| Setup Supabase (14 tabel, RLS, fungsi `sisa_jajan`, seed 50 soal OJK & lencana) | Selesai |
| Integrasi Flutter ↔ Supabase (Auth, repository 14 tabel, katalog misi dari DB) | Selesai |
| Fitur MVP tambahan (3 periode uang saku, sisa jajan otomatis, Cek Celengan, panduan 4 langkah, Tantangan Hadiah, Bonus Tabungan) | Selesai |
| Finalisasi sebelum rilis (konfigurasi OAuth Google Sign-In, uji emulator/APK end-to-end, sinkronisasi `lencana_anak`, ekspor PDF & grafik rapor) | Sedang berjalan |

Progres per tugas dicatat di papan Kanban (GitHub Projects).

## Tim Sharpener

| Nama | Peran |
|---|---|
| Hans Vere Liem | Project Manager |
| Ricky Kennard Wong | Frontend Developer |
| Michael Mulyadi | UI/UX Designer, Frontend (fitur anak) |
| Maverick Effenberg | Backend Developer |
| Flabianos Jason Muljono | Backend Developer |
| Siane Soesilo | QA Engineer & CMO |

## Menjalankan aplikasi

Butuh Flutter SDK dan Android SDK (Android Studio).

1. Salin file contoh konfigurasi Supabase di folder `mobile/`:

   ```bash
   cd mobile
   cp env.example.json env.json
   ```

2. Isi `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, dan (jika menguji login Google) `GOOGLE_WEB_CLIENT_ID` di `mobile/env.json`. File `env.json` diabaikan oleh git agar kredensial lokal tidak terunggah.

3. Pasang dependensi dan jalankan aplikasi:

   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```

4. Menjalankan pengujian otomatis:

   ```bash
   flutter analyze
   flutter test
   ```
