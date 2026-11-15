# Koini V3 Â· Flutter Android

Buka direktori `mobile/` sebagai proyek Flutter di Android Studio. Pilih emulator Pixel 7 atau perangkat Android lalu jalankan `lib/main.dart`. Dari terminal:

```powershell
cd mobile
flutter pub get
flutter run
```

## Mencoba alur lokal

1. Jalankan aplikasi di Pixel 7. Setelah Splash, pilih **Masuk dalam mode demo** atau buka **Belum punya akun? Daftar** lalu pilih **Daftar dalam mode demo**.
2. Jika profil belum ada, berikan persetujuan Ayah/Bunda, isi nama panggilan dan usia, buat dan konfirmasi PIN enam digit, isi uang saku serta batas jajan, lalu simpan pembagian tiga toples. Pilih **Mulai main** untuk menyelesaikan setup.
3. Jika profil sudah ada, Login dan Daftar membuka Beranda dengan data yang tersimpan. Pilih **Terima uang saku** setelah uang tunai diterima. Pengaturan pembagian berlaku untuk penerimaan berikutnya.
4. Buka **Profil → Akses orang tua** atau pilih **Atur** di Beranda. Masukkan PIN untuk melihat ringkasan, setelan, laporan, dan paket Plus. Keluar atau gunakan tombol Kembali untuk mengunci area orang tua lagi.
5. Pilih **Profil → Keluar dari mode demo** untuk menutup sesi. Membuka aplikasi kembali setelah proses berhenti selalu menampilkan Login. Hot Reload mempertahankan sesi yang sedang aktif.

## Cakupan dan referensi desain

- **Anak** â€” beranda, detail toples, catat dan pindah uang, riwayat, impian dan rasi bintang, peta misi, kuis, profil, dan galeri lencana.
- **Orang tua** â€” ringkasan mingguan, perbandingan rencana dengan realisasi, riwayat terbaru dan hasil misi, uang saku, PIN, bonus, dan setelan.
- **Plus** â€” perbandingan Gratis, Bulanan, dan Tahunan, aktivasi demo dengan PIN, Rencana Pintar, catatan per kategori, rapor bulanan, pratinjau peringatan email, target bertanggal, dan pembagian uang hadiah termasuk titipan orang tua.
- Warna, langit, wordmark, maskot, ikon navigasi, dan ilustrasi diambil dari desain V3 Final. Baloo 2 dan Nunito dibundel untuk penggunaan offline. Ikon aksi Material, status bar Android, dan animasi Flutter digunakan di sejumlah layar. Master vektor serta timing animasi Figma tidak disertakan dalam PDF.

## Audit referensi V3

Audit memakai papan PDF Week 8, prototipe V3 yang tercantum pada README repo, dan pembagian lingkup pada laporan Agile Week 9. PDF memuat 45 frame layar dan keadaan yang terlihat, di luar contoh komponen dan overlay. Dari 45 frame tersebut, 42 dipetakan ke 29 implementasi layar Flutter. Tiga frame transisi maskot atau kilau dipetakan ke animasi Flutter pada Splash dan perayaan. Overlay berpola sama dipetakan ke lembar aksi dan dialog yang sudah ada.

| Kelompok | Perbandingan |
|---|---|
| Akun dan setup | Splash, Welcome, panel Ayah/Bunda, profil anak, pengaturan awal, pembagian toples, dan siap bermain memakai langit, maskot, tipografi, kartu, dan tombol Koini. Splash sekarang menampilkan wordmark dan tagline. Tombol Mulai pada Welcome ditempatkan pada footer seperti frame. Frame Ayah/Bunda menjadi acuan Login demo. Daftar memakai komponen yang sama dan memerlukan tinjauan UI/UX karena referensi tidak memuat frame Daftar tersendiri. |
| Anak | Beranda, impian dan rasi, catat uang, riwayat, toples, peta serta kuis, profil, dan lencana dibandingkan berdasarkan urutan konten, warna, hierarki, ilustrasi, posisi tab, dan kondisi kosong, benar, salah, serta sukses. Angka berubah sesuai data lokal. |
| Orang tua | PIN, ringkasan, uang saku, perkembangan, setelan, dan contoh email memakai kartu, keypad, dan tindakan bawah yang sama. Ringkasan dan layar turunannya memerlukan verifikasi PIN di rute aplikasi. |
| Plus | Pemilihan paket, PIN aktivasi, paket aktif, input, proses dan hasil Rencana Pintar, catatan terstruktur, rapor, email, target bertanggal, dan musim hadiah punya alur lokal. Isi laporan dan estimasi mengikuti data demo. |
| Overlay dan animasi | Lembar penilaian, fitur Plus/Tahunan, validasi nominal, dan perayaan memakai komponen Flutter bersama. Status bar mengikuti Android. File Figma asli yang dapat diedit, master vektor, dan timeline animasi presisi tidak tersedia melalui referensi yang diberikan. |

## Struktur MVVM dan Riverpod

```text
lib/
  app/                 Akar aplikasi, router, proses startup, dan shell tab anak
  core/providers/      Dependensi KoiniStore dan AuthService
  core/theme/          Warna, tipografi, dan tema bersama
  core/widgets/        Tombol, halaman, form, progres, dialog, dan ilustrasi
  core/viewmodels/     Kelas dasar untuk operasi layar dan perubahan store
  features/<fitur>/
    views/             Halaman atau langkah onboarding
    viewmodels/        State layar, aksi pengguna, dan data siap tampil
    widgets/           Komponen khusus fitur
  models/              Entitas dan format penyimpanan
  services/            Autentikasi demo, saldo, penyimpanan, dan kalkulasi
  previews/            Host dengan ProviderScope dan penyimpanan memori per kartu
```

| Bagian | Tanggung jawab |
|---|---|
| Model | Entitas toples, transaksi, impian, dan representasi JSON. |
| View | Merender hasil `ref.watch`, mengirim aksi, dan menangani navigasi, fokus, serta animasi. `TextEditingController` tetap dimiliki View. |
| ViewModel | Menyimpan draft dan status aksi, memvalidasi masukan layar, menyiapkan data untuk View, dan memanggil service. ViewModel fitur yang ada memakai `ChangeNotifierProvider.autoDispose.family` agar Riverpod mengelola masa hidup dan notifikasinya. Akun memakai `NotifierProvider` dengan `AuthState`. |
| Service | Menjalankan aturan saldo, kalkulasi, PIN, dan penyimpanan. `KoiniStore` adalah sumber saldo dan data profil. `DeviceStorage` memakai kontrak `KoiniStorage` serta kunci dan JSON Android yang sama. |

View memantau provider dan memanggil aksi ViewModel. ViewModel memanggil service dan Riverpod merender perubahan. Contoh ringkas dari alur Beranda berikut mengasumsikan `screenProvider` yang sudah diikat ke argumen layar.

```dart
final model = ref.watch(screenProvider);
return KButton(
  'Terima uang saku',
  onTap: model.busy || model.receivedThisWeek
      ? null
      : () async {
          final saved = await model.receiveAllowance();
          if (!context.mounted) return;
          if (!saved && model.error != null) note(context, model.error!);
        },
);
```

Lihat [HomeView](lib/features/home/views/home_view.dart) dan [HomeViewModel](lib/features/home/viewmodels/home_viewmodel.dart) untuk aksi yang lengkap. Pada aplikasi, `KoiniApp` menyediakan store. Pada Widget Previewer, `KoiniPreviewHost` membuat scope baru serta store memori untuk setiap kartu.

## Navigasi go_router

[Router aplikasi](lib/app/app_router.dart) mendefinisikan rute, redirect, dan pembuatan layar. `/splash` memuat data lokal, `/masuk` dan `/daftar` adalah titik masuk akun, dan `/pengaturan-awal` menangani onboarding. Shell `/anak/:tab` menampilkan Beranda, Impian, Catat, Misi, atau Profil. Layar detail seperti `/toples/:jar` dan `/impian/:id` dibuka di atas tab asal agar tombol Kembali mengembalikan pengguna ke konteksnya.

Rute `/orang-tua` dan turunannya memakai grant PIN lokal yang aktif selama ringkasan orang tua terbuka. Navigasi ke URL terlindungi tanpa grant mengarah ke Beranda setelah login. Dialog dan lembar aksi tetap memakai kontrol modal Flutter. Preview memakai rute layar yang sama melalui Navigator di dalam kartu sehingga tombol Kembali tetap bekerja tanpa mengubah URL Widget Previewer.

## Simulasi frontend dan handoff backend

[Login](lib/features/auth/views/login_view.dart) dan [Daftar](lib/features/auth/views/sign_up_view.dart) menggunakan [AuthService](lib/services/auth_service.dart) melalui `authServiceProvider`. Implementasi `DemoAuthService` hanya menghasilkan sesi dalam memori dan tidak menerima kredensial. PIN mempunyai tujuan terpisah, yaitu membuka pengawasan orang tua pada data perangkat. Keluar dari sesi membiarkan profil, transaksi, saldo, impian, misi, PIN, dan paket lokal tetap tersimpan.

| Pembagian | Status |
|---|---|
| Frontend | Splash, akun demo, onboarding, tab anak, PIN lokal, ringkasan orang tua, navigasi, dan Widget Previewer dapat dicoba di Android. |
| Simulasi frontend | Aktivasi Plus, preferensi notifikasi, pratinjau email, Rencana Pintar dalam Dart, dan cerita bawaan bekerja dengan data lokal. |
| Handoff backend | Ganti injeksi `AuthService` dengan autentikasi Supabase dan Google OAuth. Tim backend menangani skema dan kebijakan RLS, identitas orang tua, sinkronisasi data, pemulihan PIN, fungsi email dan jadwal, serta integrasi AI produksi bila digunakan. Pertahankan kontrak dan kompatibilitas data lokal saat merancang sinkronisasi. |

## Lokasi View dan nama preview

| Fitur | File dan preview |
|---|---|
| auth | [login_view.dart](lib/features/auth/views/login_view.dart) · Masuk akun demo<br>[sign_up_view.dart](lib/features/auth/views/sign_up_view.dart) · Daftar akun demo |
| dreams | [create_dream_view.dart](lib/features/dreams/views/create_dream_view.dart) Â· Buat impian dan ubah target<br>[dream_detail_view.dart](lib/features/dreams/views/dream_detail_view.dart) Â· Detail sepeda - 40%<br>[dream_list_view.dart](lib/features/dreams/views/dream_list_view.dart) Â· Daftar impian |
| home | [home_view.dart](lib/features/home/views/home_view.dart) Â· Beranda - saldo normal, Beranda - saldo kosong, Beranda - impian 40%, Beranda - misi selesai<br>[weekly_summary_view.dart](lib/features/home/views/weekly_summary_view.dart) Â· Ringkasan mingguan |
| jars | [jar_detail_view.dart](lib/features/jars/views/jar_detail_view.dart) Â· Toples Tabung, Toples Jajan, Toples Berbagi |
| missions | [koini_story_view.dart](lib/features/missions/views/koini_story_view.dart) Â· Cerita dengan Koini<br>[mission_map_view.dart](lib/features/missions/views/mission_map_view.dart) Â· Peta misi, Peta misi - selesai<br>[mission_quiz_view.dart](lib/features/missions/views/mission_quiz_view.dart) Â· Kuis butuh atau mau |
| onboarding | [child_profile_setup_view.dart](lib/features/onboarding/views/child_profile_setup_view.dart) Â· Profil anak<br>[initial_jar_split_view.dart](lib/features/onboarding/views/initial_jar_split_view.dart) Â· Pembagian toples awal<br>[initial_settings_view.dart](lib/features/onboarding/views/initial_settings_view.dart) Â· Pengaturan awal<br>[onboarding_flow_view.dart](lib/features/onboarding/views/onboarding_flow_view.dart) Â· alur onboarding<br>[parent_login_view.dart](lib/features/onboarding/views/parent_login_view.dart) Â· Masuk orang tua<br>[ready_to_play_view.dart](lib/features/onboarding/views/ready_to_play_view.dart) Â· Siap bermain<br>[splash_view.dart](lib/features/onboarding/views/splash_view.dart) Â· Splash Koini<br>[welcome_view.dart](lib/features/onboarding/views/welcome_view.dart) Â· Selamat datang |
| parents | [allowance_settings_view.dart](lib/features/parents/views/allowance_settings_view.dart) Â· Atur uang saku<br>[change_pin_view.dart](lib/features/parents/views/change_pin_view.dart) Â· Ganti PIN demo 123456<br>[email_preview_view.dart](lib/features/parents/views/email_preview_view.dart) Â· Contoh email mingguan, Peringatan email<br>[parent_dashboard_view.dart](lib/features/parents/views/parent_dashboard_view.dart) Â· Ringkasan orang tua<br>[parent_pin_view.dart](lib/features/parents/views/parent_pin_view.dart) Â· Masuk dengan PIN demo 123456<br>[parent_report_view.dart](lib/features/parents/views/parent_report_view.dart) Â· Detail perkembangan, Rapor bulanan<br>[parent_settings_view.dart](lib/features/parents/views/parent_settings_view.dart) Â· Setelan orang tua |
| plus | [active_plan_view.dart](lib/features/plus/views/active_plan_view.dart) Â· Paket Tahunan aktif<br>[choose_dated_dream_view.dart](lib/features/plus/views/choose_dated_dream_view.dart) Â· Pilih impian bertanggal<br>[dated_goal_view.dart](lib/features/plus/views/dated_goal_view.dart) Â· Target bertanggal<br>[gift_release_view.dart](lib/features/plus/views/gift_release_view.dart) Â· Pengembalian uang titipan<br>[gift_season_view.dart](lib/features/plus/views/gift_season_view.dart) Â· Musim uang hadiah<br>[plus_packages_view.dart](lib/features/plus/views/plus_packages_view.dart) Â· Pilih paket - PIN 123456<br>[smart_plan_result_view.dart](lib/features/plus/views/smart_plan_result_view.dart) Â· Rencana Pintar - hasil<br>[smart_plan_view.dart](lib/features/plus/views/smart_plan_view.dart) Â· Rencana Pintar - masukan |
| rewards | [badge_gallery_view.dart](lib/features/rewards/views/badge_gallery_view.dart) Â· Galeri lencana<br>[profile_view.dart](lib/features/rewards/views/profile_view.dart) Â· Profil anak |
| transactions | [add_transaction_view.dart](lib/features/transactions/views/add_transaction_view.dart) Â· Catat transaksi, Catat transaksi - saldo kurang<br>[structured_history_view.dart](lib/features/transactions/views/structured_history_view.dart) Â· Catatan terstruktur<br>[transaction_history_view.dart](lib/features/transactions/views/transaction_history_view.dart) Â· Riwayat transaksi |

## Membuka Widget Preview

1. Buka folder `mobile/` sebagai proyek Flutter di Android Studio. Pastikan plugin **Flutter** dan **Dart** aktif, SDK Flutter mengarah ke **3.47.9**, dan **Flutter Widget Preview** tersedia di sidebar. Pada workstation ini terpasang plugin Flutter **98.0.0** dan Dart **511.0.0**.
2. Buka file seperti `lib/features/home/views/home_view.dart`, lalu buka panel **Flutter Widget Preview**. Aktifkan **Filter previews by selected file** untuk menampilkan varian di file tersebut. Nonaktifkan filter untuk menelusuri semua kelompok.
3. Gunakan PIN demo **123456** untuk preview Orang tua dan Plus. Untuk mencoba validasi saldo, buka **Catat transaksi - saldo kurang**, pilih Jajan, lalu masukkan Rp5.000. Preview itu mulai dengan Rp2.000 di toples Jajan.
4. Gunakan tombol **Hot restart** pada kartu untuk mengulang skenario dengan data awal.

Dari terminal di `mobile/`:

```powershell
flutter widget-preview start
```

Jika browser tidak terbuka otomatis, jalankan `flutter widget-preview start --web-server` dan buka alamat localhost yang ditampilkan. Setup pertama mungkin mengunduh dependensi Flutter Previewer. Data, font, dan ilustrasi Koini dilayani dari proyek lokal. Cache `.widget_preview/` sudah diabaikan oleh Git.

## Menambah fitur, ViewModel, dan preview

1. Tambahkan layar ke `features/<fitur>/views/`. Definisikan tujuannya di `KRoute` dan builder pada `app/app_router.dart`, lalu buka dengan `openPage(context, KRoute...)`. Tambahkan aturan redirect untuk layar yang memerlukan PIN atau paket tertentu.
2. Letakkan state dan aksi baru di `viewmodels/`. Terima dependensi melalui konstruktor atau provider. Gunakan `NotifierProvider` untuk state baru yang imutabel atau `ChangeNotifierProvider.autoDispose.family` untuk ViewModel berbasis ChangeNotifier yang sudah ada.
3. Pantau provider lewat `ref.watch` dalam View. Riverpod menutup ViewModel yang memakai `autoDispose`. View menutup controller input miliknya sendiri.
4. Tambahkan fungsi publik di file View yang mengembalikan `KoiniPreviewHost`. Pakai `@Preview(name: ..., group: ..., size: koiniPreviewSize)`. Berikan View asli ke `page` dan, bila perlu, halaman asal ke `returnPage` untuk menguji navigasi kembali.
5. Ubah skenario terpusat di [preview_data.dart](lib/previews/preview_data.dart). Setiap kartu mendapatkan store baru. Tambahkan fungsi preview ke [widget_preview_test.dart](test/widget_preview_test.dart) untuk pengujian render.

```dart
@Preview(name: 'Contoh halaman', group: 'Contoh', size: koiniPreviewSize)
Widget examplePreview() => KoiniPreviewHost(
  page: (_, store) => ExampleView(store: store),
  scenario: PreviewScenario.normal,
);
```

## Pemeriksaan

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Gunakan emulator untuk menguji instalasi APK, penyimpanan terenkripsi Android, data setelah aplikasi dibuka ulang, tombol kembali sistem, dan keyboard Android. APK debug tersedia di `build/app/outputs/flutter-apk/app-debug.apk`.

Rujukan [Flutter Widget Previewer](https://docs.flutter.dev/tools/widget-previewer).
