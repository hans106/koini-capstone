import 'package:koini/models/mission.dart';

const missions = [
  Mission('catat', 'Catat jajan', [
    Question(
      'Dina punya Rp10.000 dan membeli roti Rp4.000. Berapa sisa uangnya?',
      ['Rp4.000', 'Rp6.000', 'Rp10.000', 'Rp14.000'],
      1,
      'Rp10.000 dikurangi Rp4.000 adalah Rp6.000.',
    ),
    Question(
      'Raka diberi uang saku oleh Bunda. Catatan apa yang perlu dibuat?',
      ['Uang masuk', 'Jajan', 'Berbagi', 'Belanja'],
      0,
      'Uang saku menambah uang yang kamu pegang.',
    ),
    Question(
      'Mira membeli susu. Toples mana yang bisa dipakai?',
      ['Tabung', 'Berbagi', 'Jajan', 'Semua toples'],
      2,
      'Toples Jajan dipakai untuk kebutuhan sehari-hari.',
    ),
    Question(
      'Sari mencatat beli pensil Rp2.000. Apa manfaat mencatatnya?',
      [
        'Harga pensil berubah',
        'Bisa melihat sisa uang',
        'Jajan jadi gratis',
        'Uang menjadi dua kali lipat',
      ],
      1,
      'Dari catatan, kamu tahu uangnya dipakai untuk apa dan berapa sisanya.',
    ),
    Question(
      'Uang yang sama sudah dicatat pagi ini. Apa yang harus kamu lakukan?',
      ['Catat lagi', 'Hitung dua kali', 'Buang catatan', 'Lihat riwayat'],
      3,
      'Periksa riwayat agar uang yang sama hanya dihitung sekali.',
    ),
  ]),
  Mission('tabungan', 'Sisihkan tabungan', [
    Question(
      'Nina ingin membeli buku Rp20.000. Ia punya Rp12.000. Berapa yang kurang?',
      ['Rp2.000', 'Rp12.000', 'Rp8.000', 'Rp32.000'],
      2,
      'Kurangi harga buku dengan uang yang sudah ditabung.',
    ),
    Question(
      'Andre menabung Rp5.000 tiap minggu. Berapa setelah dua minggu?',
      ['Rp5.000', 'Rp10.000', 'Rp15.000', 'Rp20.000'],
      1,
      'Dua kali Rp5.000 adalah Rp10.000.',
    ),
    Question(
      'Toples mana yang cocok untuk menyimpan uang demi sepeda?',
      ['Tabung', 'Jajan', 'Berbagi', 'Kotak bekal'],
      0,
      'Toples Tabung membantu kamu mencapai impian.',
    ),
    Question(
      'Rina masih butuh Rp15.000 dan bisa menabung Rp5.000 tiap minggu. Berapa lama?',
      ['Satu minggu', 'Dua minggu', 'Lima minggu', 'Tiga minggu'],
      3,
      'Dalam tiga minggu, Rina bisa mengumpulkan Rp15.000.',
    ),
    Question(
      'Apa yang sebaiknya dilakukan saat uang untuk impian sudah cukup?',
      [
        'Jajan semuanya',
        'Ajak Ayah/Bunda melihat catatan',
        'Hapus impian',
        'Pinjam lagi',
      ],
      1,
      'Ajak orang tua merayakan dan memilih langkah berikutnya.',
    ),
  ]),
  Mission('butuh', 'Bedakan butuh & mau', [
    Question(
      'Raka haus setelah olahraga dan punya Rp10.000. Di kantin ada air mineral, es krim, permen cokelat, dan soda. Mana yang sebaiknya dibeli dulu?',
      [
        'Air mineral Rp3.000',
        'Es krim Rp8.000',
        'Permen cokelat Rp5.000',
        'Minuman soda Rp7.000',
      ],
      0,
      'Tubuhmu butuh minum setelah olahraga. Es krim boleh nanti, kalau uangnya masih cukup.',
    ),
    Question(
      'Pensil Naya patah dan besok ada ujian. Mana yang perlu dibeli dulu?',
      ['Boneka', 'Stiker', 'Pensil', 'Mainan'],
      2,
      'Naya perlu pensil untuk mengerjakan ujian.',
    ),
    Question(
      'Bima belum makan siang. Apa yang sebaiknya didahulukan?',
      ['Kartu permainan', 'Nasi dan lauk', 'Aksesori tas', 'Gantungan kunci'],
      1,
      'Makan siang memberi tubuh tenaga. Barang lain bisa menunggu.',
    ),
    Question(
      'Tali sepatu sekolah Dito putus. Apa pilihan yang masuk akal?',
      ['Komik', 'Minuman soda', 'Kelereng', 'Tali sepatu'],
      3,
      'Tali sepatu dibutuhkan supaya sepatu sekolah bisa dipakai dengan aman.',
    ),
    Question(
      'Kebutuhan sekolahmu sudah cukup. Kamu suka mainan baru. Apa langkah yang baik?',
      [
        'Cek harga dan buat rencana tabung',
        'Habiskan semua uang',
        'Ambil dari toples Berbagi',
        'Beli tanpa cek harga',
      ],
      0,
      'Keinginan boleh direncanakan. Menabung bisa membantu kamu membelinya nanti.',
    ),
  ]),
  Mission('impian', 'Cek impian', [
    Question(
      'Target sepeda Raka Rp100.000 dan sudah terkumpul Rp50.000. Berapa persen?',
      ['25%', '50%', '75%', '100%'],
      1,
      'Rp50.000 adalah separuh dari Rp100.000.',
    ),
    Question(
      'Tabunganmu pas dengan harga impianmu. Berapa sisa yang diperlukan?',
      ['Setengah harga', 'Seluruh harga', 'Rp0', 'Dua kali harga'],
      2,
      'Uang yang dicatat sudah cukup untuk targetmu.',
    ),
    Question(
      'Bulan ini uang jajan bertambah. Apa rencana yang masuk akal?',
      [
        'Bagi ekstra ke toples',
        'Selalu habiskan',
        'Jangan dicatat',
        'Tambah harga impian',
      ],
      0,
      'Kamu bisa sisihkan sebagian untuk tabungan atau berbagi.',
    ),
    Question(
      'Targetmu naik Rp10.000. Apa yang harus dicek?',
      [
        'Warna kartu',
        'Bintang teman',
        'Usia profil',
        'Sisa tabungan yang diperlukan',
      ],
      3,
      'Sisa yang harus ditabung bertambah saat harga target naik.',
    ),
    Question(
      'Jika tabunganmu belum cukup, apa yang bisa dilakukan?',
      [
        'Hapus semua catatan',
        'Menabung teratur dan periksa lagi',
        'Anggap sudah cukup',
        'Catat saldo lebih besar',
      ],
      1,
      'Langkah kecil yang rutin membantu impian semakin dekat.',
    ),
  ]),
];
