# Koini

Aplikasi Android yang membantu anak usia **6–12 tahun** belajar mengatur uang saku dan menabung untuk impiannya, didampingi orang tua.

Proyek Capstone mata kuliah **Digital Entrepreneurship Product Development (DEPD)**, Informatika, Universitas Ciputra, Semester 5 (2026). Tim **Sharpener**.

> Koini hanya **mencatat dan mengajarkan**. Tidak ada uang sungguhan, bank, QRIS, atau dompet digital.

## Masalah yang diselesaikan

Dari survei 12 orang tua (9 responden dengan anak di usia target):
- Tantangan terbesar adalah anak **cepat bosan / tidak konsisten** menabung (6 dari 9 responden).
- 7 dari 9 anak sebenarnya **sudah bisa** menabung, tetapi kebiasaannya tidak bertahan.
- 7 dari 9 anak **belum konsisten membedakan kebutuhan dan keinginan**.

## Fitur utama

- **Tiga toples uang saku:** Tabung, Jajan, Berbagi. Sisanya dihitung otomatis dari catatan.
- **Catat uang:** jajan, menabung untuk impian, berbagi, uang masuk.
- **Rasi Impianku:** progres tabungan digambar sebagai rasi bintang. Setiap tabungan menyalakan satu bintang.
- **Misi cerita:** kuis "butuh atau mau" dengan bintang dan lencana.
- **Area orang tua dengan PIN:** ringkasan, perkembangan, setelan, atur uang saku.
- **Koini Plus (simulasi):** Rencana Pintar, target bertanggal, rapor bulanan, email ringkasan.

## Prototipe

Prototipe interaktif (hasil desain Figma): <https://hans106.github.io/koini-prototype-v3/>

## Tech stack

| Bagian | Teknologi |
|---|---|
| Aplikasi mobile | Flutter (Dart), Android. Riverpod, go_router, google_fonts, Lottie, flutter_secure_storage, intl |
| Backend | Supabase: PostgreSQL, Auth (login Google), Row Level Security, Edge Functions, pg_cron, Secrets |
| Email | Gmail SMTP |
| AI (opsional) | OpenRouter model gratis, hanya untuk kalimat Rencana Pintar, dengan template sebagai cadangan |
| Distribusi | File APK |

## Struktur repo

```
mobile/      Aplikasi Flutter (Android)
supabase/    Migrasi database, kebijakan RLS, data awal, Edge Functions   (menyusul)
docs/        Diagram dan dokumentasi                                    (menyusul)
```

## Status pengerjaan

| Tahap | Status |
|---|---|
| Survei pengguna, Lean Canvas, wireframe, desain hi-fi | Selesai |
| Prototipe interaktif + usability testing Week 8 | Selesai |
| ERD (13 tabel), sequence diagram (7 alur), panduan teknis | Selesai |
| Setup proyek Flutter (Android) | Selesai |
| Setup Supabase (tabel, RLS, login) | Belum dimulai |
| Fitur MVP | Belum dimulai |

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

```bash
cd mobile
flutter pub get
flutter run
```
