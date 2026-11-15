# Koini V3 Â· Flutter Android

Buka direktori `mobile/` sebagai proyek Flutter di Android Studio. Pilih emulator Pixel 7 atau perangkat Android lalu jalankan `lib/main.dart`. Dari terminal:

```powershell
cd mobile
flutter pub get
flutter run
```

## Mencoba alur lokal

1. Pilih **Mulai**, setujui penyimpanan data profil, lalu isi nama panggilan dan usia.
2. Buat PIN orang tua enam digit, isi uang saku dan batas jajan, lalu simpan pembagian tiga toples.
3. Pilih **Terima uang saku** setelah uang tunai diterima. Pengaturan pembagian hanya berlaku untuk penerimaan berikutnya. Untuk mencoba contoh desain, buat impian **Sepeda baru** dengan target **Rp1.000.000**.
4. Buka **Profil â†’ Akses orang tua** atau **Atur** di Beranda untuk masuk dengan PIN. Keluar dari ringkasan mengunci area orang tua kembali.

## Cakupan dan referensi desain

- **Anak** â€” beranda, detail toples, catat dan pindah uang, riwayat, impian dan rasi bintang, peta misi, kuis, profil, dan galeri lencana.
- **Orang tua** â€” ringkasan mingguan, perbandingan rencana dengan realisasi, riwayat terbaru dan hasil misi, uang saku, PIN, bonus, dan setelan.
- **Plus** â€” perbandingan Gratis, Bulanan, dan Tahunan, aktivasi demo dengan PIN, Rencana Pintar, catatan per kategori, rapor bulanan, pratinjau peringatan email, target bertanggal, dan pembagian uang hadiah termasuk titipan orang tua.
- Warna, langit, wordmark, maskot, ikon navigasi, dan ilustrasi diambil dari desain V3 Final. Baloo 2 dan Nunito dibundel untuk penggunaan offline. Ikon aksi Material, status bar Android, dan animasi Flutter digunakan di sejumlah layar. Master vektor serta timing animasi Figma tidak disertakan dalam PDF.

## Integrasi lanjutan

`lib/services/koini_store.dart` memuat penyimpanan dan aturan transaksi. Data demo dan PIN disimpan dalam penyimpanan terenkripsi perangkat dengan `flutter_secure_storage`. PIN berlaku untuk area pengawasan lokal. Batas percobaan PIN berlaku selama proses aplikasi aktif.

Login Google, pemulihan PIN lewat email, sinkronisasi backend, pengiriman email, dan pengingat sistem masih perlu integrasi. Preferensi notifikasi dan pratinjau email dapat dicoba secara lokal. Aktivasi Plus adalah simulasi tanpa pembayaran. `lib/services/smart_plan.dart` menghitung perkiraan dalam Dart. Cerita Koini menggunakan teks demo bawaan.

## Struktur MVVM

```text
lib/
  app/                 Akar aplikasi, ViewModel awal, shell tab anak, dan navigasi
  core/theme/          Warna, tipografi, dan tema bersama
  core/widgets/        Tombol, halaman, form, progres, dialog, dan ilustrasi
  core/utils/          Bantuan input keypad
  core/viewmodels/     ChangeNotifier bersama untuk operasi asinkron dan perubahan store
  features/<fitur>/
    views/             Halaman atau langkah onboarding
    viewmodels/        State layar, aksi pengguna, dan data siap tampil
    widgets/           Komponen khusus fitur
  models/              Model data dan format penyimpanan
  services/            Saldo, penyimpanan lokal, dan kalkulasi bersama
  previews/            Host navigasi dan data simulasi dalam memori
```

Sembilan fitur yang ada memakai struktur ini, yaitu `dreams`, `home`, `jars`, `missions`, `onboarding`, `parents`, `plus`, `rewards`, dan `transactions`.

| Bagian | Tanggung jawab |
|---|---|
| Model | Entitas seperti toples, transaksi, dan impian beserta representasi JSON di `models/`. |
| View | Merender UI, mengirim aksi, menampilkan umpan balik, dan membuka halaman. Fokus, animasi, dan `TextEditingController` dimiliki View. |
| ViewModel | Menyimpan draft, memvalidasi masukan layar, menyiapkan data untuk View, dan mengoordinasikan service. `ViewModel` menyediakan status operasi dan `StoreViewModel` juga meneruskan perubahan store. |
| Service | Menjalankan aturan saldo, kalkulasi, PIN, dan penyimpanan. `KoiniStore` adalah sumber data bersama. `DeviceStorage` melaksanakan kontrak `KoiniStorage` dengan format data dan kunci Android yang sama. |

View mengirim aksi ke ViewModel. ViewModel memanggil service jika perlu, kemudian memberi tahu listener ketika draft, hasil, atau status berubah. `ListenableBuilder` merender state terbaru. Pada contoh Beranda, View menonaktifkan tombol saat pencatatan uang saku berjalan, menampilkan saldo terbaru, dan menampilkan pesan ketika aksi gagal. Cuplikan ini memakai instance `HomeViewModel` yang dibuat dan di-`dispose()` oleh `State` View.

```dart
ListenableBuilder(
  listenable: model,
  builder: (context, _) => Column(
    children: [
      Text(rupiah(model.total)),
      KButton(
        'Terima uang saku',
        onTap: model.busy || model.receivedThisWeek
            ? null
            : () async {
                final saved = await model.receiveAllowance();
                if (!context.mounted) return;
                if (!saved && model.error != null) note(context, model.error!);
              },
      ),
    ],
  ),
)
```

Lihat [HomeView](lib/features/home/views/home_view.dart) dan [HomeViewModel](lib/features/home/viewmodels/home_viewmodel.dart) untuk implementasi lengkap. Router dan preview menerima `KoiniStore` sebagai dependensi. Setiap `KoiniPreviewHost` memberi layar store milik kartu itu dengan penyimpanan dalam memori.

## Lokasi View dan nama preview

| Fitur | File dan preview |
|---|---|
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

1. Tambahkan layar ke `features/<fitur>/views/`. Buat direktori fitur baru jika layar memiliki tanggung jawab yang berbeda dari fitur yang ada. Hubungkan melalui `openPage` atau ke tab yang sesuai di `app/child_shell.dart`.
2. Jika layar memiliki state atau aksi yang perlu dikelola, tambahkan file `*_viewmodel.dart` di `viewmodels/`. Terima layanan melalui konstruktor, tampilkan state melalui getter, dan definisikan metode untuk aksi pengguna. Letakkan aturan transaksi dan penulisan data di service.
3. Buat ViewModel di `State` View dan panggil `dispose()` saat layar ditutup. Gunakan `ListenableBuilder` untuk merender perubahan. Layar statis dan widget yang hanya menampilkan data dapat menerima nilai serta callback melalui konstruktor.
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
