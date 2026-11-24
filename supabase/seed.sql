-- Koini: Data awal (seed.sql)
-- 10 Misi (5 topik x 2 level), 50 Soal kuis acuan literasi keuangan OJK tingkat SD, dan daftar Lencana.

-- ---------------------------------------------------------------------------
-- 1. Daftar Lencana (idempoten)
-- ---------------------------------------------------------------------------
INSERT INTO public.lencana (nama, deskripsi, ikon, syarat)
VALUES
  ('Penabung pertama', 'Catat tabungan pertamamu ke toples Tabung', 'savings', 'tabung >= 1'),
  ('Pencatat cermat', 'Catat 3 aktivitas uang masuk atau keluar', 'edit_note', 'catatan >= 3'),
  ('Rajin 3 hari', 'Belajar dan mencatat 3 hari beruntun', 'local_fire_department', 'streak_hari >= 3'),
  ('Tekun seminggu', 'Belajar dan mencatat 7 hari beruntun', 'workspace_premium', 'streak_hari >= 7'),
  ('Penjelajah misi', 'Selesaikan 5 misi kuis Koini', 'explore', 'misi_selesai >= 5'),
  ('Juara literasi', 'Selesaikan seluruh 10 misi kuis Koini', 'emoji_events', 'misi_selesai >= 10'),
  ('Peraih impian', 'Capai 1 target impian pertamamu', 'star', 'impian_tercapai >= 1'),
  ('Dermawan cilik', 'Catat aktivitas berbagi pertamamu', 'volunteer_activism', 'berbagi >= 1'),
  ('Penjaga celengan', 'Lakukan pengecekan uang fisik celengan pertamamu', 'account_balance_wallet', 'cek_celengan >= 1')
ON CONFLICT (nama) DO UPDATE SET
  deskripsi = EXCLUDED.deskripsi,
  ikon = EXCLUDED.ikon,
  syarat = EXCLUDED.syarat;

-- ---------------------------------------------------------------------------
-- 2. Daftar 10 Misi (5 topik x 2 level = 10 misi)
-- ---------------------------------------------------------------------------
INSERT INTO public.misi (topik, level, judul)
VALUES
  ('butuh_mau', 1, 'Kenali Butuh dan Mau'),
  ('butuh_mau', 2, 'Pilih Kebutuhan Sekolah'),
  ('menabung_bertahap', 1, 'Langkah Kecil Menabung'),
  ('menabung_bertahap', 2, 'Meraih Impian di Celengan'),
  ('mengatur_jajan', 1, 'Jajan Pintar di Kantin'),
  ('mengatur_jajan', 2, 'Bagi Uang Saku ke Tiga Toples'),
  ('menahan_keinginan', 1, 'Sabar Sebelum Membeli'),
  ('menahan_keinginan', 2, 'Tunggu Dulu, Cek Impianmu'),
  ('promo', 1, 'Jangan Terjebak Diskon'),
  ('promo', 2, 'Bandingkan Harga dengan Cermat')
ON CONFLICT (topik, level) DO UPDATE SET
  judul = EXCLUDED.judul;

-- ---------------------------------------------------------------------------
-- 3. 50 Soal Kuis (5 topik x 10 soal = 50 soal; 5 soal per misi)
--    Acuan: Buku Literasi Keuangan OJK SD "Mengenal Jasa Keuangan" & SikapiUangmu
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.soal LIMIT 1) THEN
    INSERT INTO public.soal (
      misi_id,
      cerita,
      opsi_a,
      opsi_b,
      opsi_c,
      opsi_d,
      jawaban,
      penjelasan_benar,
      penjelasan_salah,
      sumber
    )
    SELECT
      m.misi_id,
      v.cerita,
      v.opsi_a,
      v.opsi_b,
      v.opsi_c,
      v.opsi_d,
      v.jawaban,
      v.penjelasan_benar,
      v.penjelasan_salah,
      v.sumber
    FROM (
      VALUES
        -- ===================================================================
        -- TOPIK 1: butuh_mau (Level 1: soal 1-5, Level 2: soal 6-10)
        -- ===================================================================
        (
          'butuh_mau', 1,
          'Raka baru selesai pelajaran olahraga dan sangat haus. Di kantin ada air mineral Rp3.000 dan es krim cokelat Rp8.000. Uang jajannya Rp10.000. Apa yang sebaiknya dibeli dulu?',
          'Air mineral Rp3.000 karena tubuh butuh minum',
          'Es krim cokelat Rp8.000 karena manis',
          'Dua gelas es krim sekaligus',
          'Mainan stiker di koperasi',
          'a',
          'Tepat! Air minum adalah kebutuhan utama saat tubuh haus setelah olahraga.',
          'Belum tepat. Es krim itu keinginan, sedangkan tubuh yang haus lebih membutuhkan air mineral dulu.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'butuh_mau', 1,
          'Besok ada ulangan matematika, tetapi pensil Naya patah dan penghapusnya hilang. Di toko ada pensil baru dan gantungan kunci lucu. Mana yang merupakan kebutuhan?',
          'Gantungan kunci lucu untuk tas',
          'Pensil baru dan penghapus untuk ujian',
          'Stiker karakter kesukaan',
          'Permen warna-warni',
          'b',
          'Benar! Alat tulis diperlukan Naya supaya bisa mengerjakan ulangan besok dengan lancar.',
          'Kurang tepat. Gantungan kunci atau stiker adalah keinginan, bukan keperluan mendesak untuk ujian.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'butuh_mau', 1,
          'Bima lupa membawa bekal makan siang dan perutnya keroncongan saat istirahat. Uang sakunya Rp12.000. Pilihan mana yang paling bijak?',
          'Membeli kartu koleksi mainan',
          'Membeli balon tiup dan kelereng',
          'Membeli nasi dan lauk secukupnya',
          'Membeli mainan pesawat kertas',
          'c',
          'Pintar! Makanan bergizi memberi tenaga untuk belajar di sekolah.',
          'Coba pikirkan lagi: mainan tidak bisa menghilangkan rasa lapar saat istirahat sekolah.',
          'OJK SikapiUangmu - Kebutuhan vs Keinginan (SD)'
        ),
        (
          'butuh_mau', 1,
          'Tali sepatu sekolah Dito putus sehingga sepatunya sulit dipakai berjalan ke kelas. Mana yang termasuk kebutuhan saat ini?',
          'Buku komik edisi baru',
          'Minuman bersoda dingin',
          'Topi bergambar pahlawan',
          'Tali sepatu pengganti agar aman dipakai',
          'd',
          'Hebat! Tali sepatu dibutuhkan agar Dito bisa bersekolah dengan aman dan nyaman.',
          'Belum tepat. Komik, soda, dan topi hanya keinginan; tali sepatu lebih penting untuk sekolah.',
          'OJK SikapiUangmu - Kebutuhan vs Keinginan (SD)'
        ),
        (
          'butuh_mau', 1,
          'Sari sudah punya tas sekolah yang masih bagus dan bersih. Saat jalan di mal, ia melihat tas baru bergambar lucu. Tas baru itu termasuk apa?',
          'Keinginan, karena tas lama masih bisa dipakai',
          'Kebutuhan pokok setiap minggu',
          'Kewajiban yang harus dibayar hari ini',
          'Tagihan wajib sekolah',
          'a',
          'Benar sekali! Karena tas yang lama masih layak pakai, membeli tas baru termasuk keinginan.',
          'Belum tepat. Sesuatu yang sudah kita miliki dan masih berfungsi baik membuat barang barunya jadi keinginan.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'butuh_mau', 2,
          'Lani mendapat tugas menggambar dari guru kesenian untuk besok pagi, tetapi buku gambarnya sudah habis. Apa yang harus didahulukan Lani?',
          'Membeli boneka kecil di warung',
          'Membeli buku gambar sesuai keperluan tugas',
          'Membeli jajanan kemasan lima bungkus',
          'Menghabiskan uang untuk main game',
          'b',
          'Tepat! Buku gambar adalah kebutuhan belajar agar tugas sekolah Lani selesai tepat waktu.',
          'Kurang tepat. Tugas sekolah harus didahulukan sebelum membeli jajan atau mainan.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'butuh_mau', 2,
          'Ibu memberi Edo Rp20.000 untuk membeli buku tulis baru Rp12.000 dan sisanya boleh ditabung atau jajan. Apa langkah pertama yang benar?',
          'Beli es boba dulu baru cek harga buku',
          'Pinjam buku teman terus dan beli mainan',
          'Beli buku tulis Rp12.000 terlebih dahulu',
          'Habiskan Rp20.000 untuk camilan',
          'c',
          'Bagus! Utamakan kebutuhan utama (buku tulis) terlebih dahulu, baru kelola sisa uangnya.',
          'Belum tepat. Jika uang dipakai jajan duluan, uangnya bisa tidak cukup untuk membeli buku tulis.',
          'OJK SikapiUangmu - Mengelola Uang Saku (SD)'
        ),
        (
          'butuh_mau', 2,
          'Hujan deras turun saat pulang sekolah dan jas hujan Tono robek besar. Di koperasi sekolah dijual jas hujan Rp15.000 dan komik Rp15.000. Mana kebutuhan mendesak Tono?',
          'Komik agar tidak bosan di jalan',
          'Camilan keripik pedas',
          'Gelang warna-warni',
          'Jas hujan agar tidak basah kehujanan',
          'd',
          'Tepat! Jas hujan melindungi kesehatan Tono supaya tidak kehujanan di perjalanan pulang.',
          'Belum tepat. Menjaga kesehatan dengan jas hujan jauh lebih penting daripada membeli komik saat hujan.',
          'OJK SikapiUangmu - Kebutuhan vs Keinginan (SD)'
        ),
        (
          'butuh_mau', 2,
          'Semua perlengkapan sekolah Kiki sudah lengkap dan bekal makan siangnya sudah tersedia. Kiki ingin membeli bola basket baru. Apa cara yang tepat untuk mendapatkan keinginan itu?',
          'Mencatat target bola basket di Impian dan menabung rutin',
          'Meminta semua uang jajan teman',
          'Mengambil uang dari toples Berbagi tanpa izin',
          'Membeli tanpa memeriksa harganya',
          'a',
          'Benar! Keinginan boleh dicapai dengan cara membuat rencana dan menabung sedikit demi sedikit.',
          'Kurang tepat. Keinginan sebaiknya direncanakan lewat tabungan, bukan menghabiskan pos lain.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'butuh_mau', 2,
          'Manakah pasangan barang yang KEDUANYA termasuk kebutuhan anak sekolah sehari-hari?',
          'Mainan robot dan permen lolipop',
          'Buku tulis dan bekal air minum',
          'Stiker hologram dan kartu koleksi',
          'Kembang api dan es krim',
          'b',
          'Betul! Buku tulis untuk belajar dan air minum untuk kesehatan tubuh adalah kebutuhan.',
          'Coba periksa lagi: pilih pasangan barang yang benar-benar diperlukan untuk belajar dan kesehatan.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),

        -- ===================================================================
        -- TOPIK 2: menabung_bertahap (Level 1: soal 11-15, Level 2: soal 16-20)
        -- ===================================================================
        (
          'menabung_bertahap', 1,
          'Nadia ingin membeli buku cerita seharga Rp30.000. Ia sudah menabung Rp18.000 di toples Tabung. Berapa lagi uang yang perlu dikumpulkan Nadia?',
          'Rp12.000 lagi',
          'Rp18.000 lagi',
          'Rp30.000 lagi',
          'Rp48.000 lagi',
          'a',
          'Tepat! Rp30.000 dikurangi Rp18.000 sama dengan Rp12.000.',
          'Kurang tepat. Coba kurangkan harga buku Rp30.000 dengan tabungan Rp18.000.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menabung_bertahap', 1,
          'Andre menyisihkan Rp5.000 setiap minggu ke celengannya secara teratur. Setelah 4 minggu, berapa jumlah tabungan Andre?',
          'Rp15.000',
          'Rp20.000',
          'Rp25.000',
          'Rp10.000',
          'b',
          'Hebat! 4 minggu dikali Rp5.000 menghasilkan Rp20.000.',
          'Hitung pelan-pelan ya: Rp5.000 + Rp5.000 + Rp5.000 + Rp5.000 = Rp20.000.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menabung_bertahap', 1,
          'Kapan waktu terbaik untuk menyisihkan uang tabungan dari uang saku yang baru diterima?',
          'Jika ingat saja di akhir bulan',
          'Setelah semua uang dipakai jajan mainan',
          'Di awal saat baru menerima uang saku',
          'Tidak perlu disisihkan sama sekali',
          'c',
          'Benar sekali! Prinsip menabung yang baik adalah menyisihkan di awal, bukan menunggu sisa.',
          'Belum tepat. Kalau menunggu sisa di akhir, uang saku sering kali sudah habis duluan.',
          'OJK SikapiUangmu - Kebiasaan Menabung (SD)'
        ),
        (
          'menabung_bertahap', 1,
          'Rina butuh Rp40.000 untuk membeli sepatu olahraga. Setiap minggu ia menabung Rp10.000. Berapa minggu waktu yang dibutuhkan Rina?',
          '2 minggu',
          '3 minggu',
          '5 minggu',
          '4 minggu',
          'd',
          'Pintar! Rp10.000 selama 4 minggu terkumpul pas Rp40.000.',
          'Belum tepat. Hitung kelipatan Rp10.000 hingga mencapai Rp40.000 ya.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menabung_bertahap', 1,
          'Menurut program OJK, selain memakai celengan di rumah, anak SD juga bisa menabung aman di bank melalui tabungan khusus pelajar bernama apa?',
          'SimPel (Simpanan Pelajar)',
          'Kartu kredit dewasa',
          'Pinjaman online',
          'Undian berhadiah',
          'a',
          'Betul! SimPel (Simpanan Pelajar) adalah tabungan bank resmi untuk siswa agar terbiasa menabung aman.',
          'Belum tepat. Program resmi bank untuk pelajar SD–SMA dari OJK bernama SimPel (Simpanan Pelajar).',
          'OJK - Mengenal Jasa Keuangan Bab 2 Bank (SD)'
        ),
        (
          'menabung_bertahap', 2,
          'Target sepeda Raka Rp1.000.000 dan tabungannya sekarang Rp400.000. Berapa persen progres tabungan Raka menuju impiannya?',
          '25%',
          '40%',
          '50%',
          '60%',
          'b',
          'Tepat! Rp400.000 dari Rp1.000.000 adalah 40%. Sedikit demi sedikit pasti tercapai!',
          'Coba hitung lagi: 400.000 dibagi 1.000.000 sama dengan 40 dari 100, yaitu 40%.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menabung_bertahap', 2,
          'Sinta punya celengan fisik di rumah, tetapi lupa berapa isi pastinya. Apa manfaat rutin mencocokkan isi celengan fisik dengan catatan di Koini?',
          'Agar uang kertas berubah jadi koin',
          'Agar bisa jajan tanpa izin',
          'Memastikan jumlah uang tunai sama dengan catatan',
          'Membuat harga barang menjadi turun',
          'c',
          'Bagus! Cek celengan memastikan catatanmu jujur dan sesuai dengan uang fisik yang ada.',
          'Belum tepat. Cek celengan bertujuan memastikan uang tunai fisik cocok dengan catatan kita.',
          'OJK SikapiUangmu - Mengelola Uang Tunai (SD)'
        ),
        (
          'menabung_bertahap', 2,
          'Uang tabungan Dani untuk membeli tas baru Rp150.000 sudah genap Rp150.000 di celengan. Apa langkah yang paling baik dilakukan Dani?',
          'Langsung belanjakan semuanya untuk jajan permen',
          'Buang catatan tabungannya',
          'Sembunyikan dari orang tua',
          'Ajak Ayah/Bunda melihat catatan dan merayakan pencapaiannya',
          'd',
          'Hebat! Melibatkan Ayah/Bunda saat impian tercapai membuat proses membeli lebih aman dan menyenangkan.',
          'Kurang tepat. Impian yang sudah tercapai sebaiknya dicek bersama Ayah/Bunda.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menabung_bertahap', 2,
          'Mengapa memiliki satu impian yang jelas (seperti buku atau sepeda) membuat anak lebih semangat menabung?',
          'Karena kita tahu tujuan yang ingin dicapai dan progresnya',
          'Karena celengan jadi bisa bicara sendiri',
          'Karena uang bertambah tanpa perlu diisi',
          'Karena semua barang menjadi gratis',
          'a',
          'Benar! Tujuan yang jelas membuat setiap rupiah yang ditabung terasa bermakna.',
          'Belum tepat. Impian memberi arah dan semangat supaya kita konsisten menyisihkan uang.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'menabung_bertahap', 2,
          'Hari ini Kiki hanya bisa menyisihkan Rp2.000 ke celengan, tidak sebesar minggu lalu Rp10.000. Bagaimana sikap yang tepat?',
          'Berhenti menabung karena jumlahnya kecil',
          'Tetap catat dan lanjut menabung rutin meski sedikit',
          'Habiskan Rp2.000 itu supaya tidak repot',
          'Catat seolah-olah menabung Rp20.000',
          'b',
          'Mantap! Menabung secara rutin meski sedikit jauh lebih baik daripada tidak menabung sama sekali.',
          'Jangan menyerah! Sedikit demi sedikit lama-lama menjadi bukit, dan catatan harus tetap jujur.',
          'OJK SikapiUangmu - Kebiasaan Menabung (SD)'
        ),

        -- ===================================================================
        -- TOPIK 3: mengatur_jajan (Level 1: soal 21-25, Level 2: soal 26-30)
        -- ===================================================================
        (
          'mengatur_jajan', 1,
          'Dina menerima jatah uang jajan Rp10.000 hari ini. Ia membeli roti Rp4.000 di kantin. Berapa sisa uang jajan Dina?',
          'Rp4.000',
          'Rp6.000',
          'Rp10.000',
          'Rp14.000',
          'b',
          'Benar! Rp10.000 dikurangi Rp4.000 adalah Rp6.000.',
          'Coba hitung pengurangannya lagi: 10.000 - 4.000 = 6.000.',
          'OJK SikapiUangmu - Mengelola Uang Saku (SD)'
        ),
        (
          'mengatur_jajan', 1,
          'Mengapa membawa bekal makanan dan botol minum dari rumah baik untuk keuangan kita?',
          'Uang saku lebih hemat dan bisa ditabung lebih banyak',
          'Tidak perlu belajar di kelas',
          'Kantong celengan jadi bolong',
          'Semua jajan di kantin jadi milik kita',
          'a',
          'Tepat! Membawa bekal dari rumah mengurangi jajan berlebih sekaligus lebih sehat.',
          'Belum tepat. Bekal dari rumah membantu kita berhemat sehingga lebih banyak uang bisa ditabung.',
          'OJK SikapiUangmu - Hidup Hemat di Sekolah (SD)'
        ),
        (
          'mengatur_jajan', 1,
          'Sari membeli susu kotak Rp5.000 dan mencatatnya di Koini. Apa manfaat mencatat setiap jajan?',
          'Membuat susu terasa lebih manis',
          'Membuat uang saku bertambah otomatis',
          'Tahu ke mana uang dipakai dan berapa sisanya',
          'Menghapus catatan hari kemarin',
          'c',
          'Pintar! Catatan membantumu melihat pengeluaran dengan jujur dan menjaga sisa uang jajan.',
          'Belum tepat. Mencatat berguna agar kamu dan orang tua tahu uang dipakai untuk apa dan berapa sisanya.',
          'OJK SikapiUangmu - Mengelola Uang Saku (SD)'
        ),
        (
          'mengatur_jajan', 1,
          'Di Koini ada tiga toples: Tabung, Jajan, dan Berbagi. Jika Bayu membeli jajanan pasar di sekolah, dari toples mana ia mencatat?',
          'Tabung',
          'Berbagi',
          'Kotak pensil',
          'Jajan',
          'd',
          'Betul! Pengeluaran jajan sehari-hari dicatat dari toples Jajan.',
          'Kurang tepat. Toples Tabung untuk impian dan Berbagi untuk sumbangan, sedangkan jajan memakai toples Jajan.',
          'OJK SikapiUangmu - Pos Keuangan Sederhana (SD)'
        ),
        (
          'mengatur_jajan', 1,
          'Pagi ini Raka sudah mencatat pembelian penghapus Rp2.000. Sore harinya ia ragu apakah sudah dicatat. Apa yang harus dilakukan?',
          'Periksa riwayat catatan agar tidak tercatat dua kali',
          'Catat lagi Rp2.000 supaya makin banyak',
          'Hapus semua catatan minggu ini',
          'Tambahkan ke toples Berbagi',
          'a',
          'Cermat sekali! Cek riwayat terlebih dahulu supaya saldo catatan tetap akurat.',
          'Belum tepat. Mencatat barang yang sama dua kali akan membuat catatan saldomu keliru.',
          'OJK SikapiUangmu - Pencatatan Keuangan (SD)'
        ),
        (
          'mengatur_jajan', 2,
          'Ayah memberi uang saku mingguan Rp100.000 yang dibagi: Rp40.000 Tabung, Rp50.000 Jajan, dan Rp10.000 Berbagi. Apakah pembagian ini sudah seimbang?',
          'Belum, karena semuanya harus dipakai jajan',
          'Ya, sudah memisahkan pos tabungan, jajan, dan berbagi',
          'Belum, karena tidak boleh ada pos berbagi',
          'Salah, karena totalnya lebih dari Rp100.000',
          'b',
          'Benar! Membagi uang ke pos Tabung, Jajan, dan Berbagi adalah kebiasaan finansial yang sehat.',
          'Coba jumlahkan lagi: 40.000 + 50.000 + 10.000 = 100.000, sudah rapi dibagi ke tiga pos!',
          'OJK SikapiUangmu - Pos Keuangan Sederhana (SD)'
        ),
        (
          'mengatur_jajan', 2,
          'Di akhir minggu, jatah jajan Rani masih tersisa Rp15.000 karena ia membawa bekal dari rumah. Apa langkah paling baik untuk sisa jajan itu?',
          'Dipaksa habis hari Minggu untuk beli permen',
          'Dibiarkan tercecer di tas sekolah',
          'Dipindahkan ke toples Tabung untuk mendekatkan impian',
          'Dibuang catatannya',
          'c',
          'Hebat! Memindahkan sisa jajan ke Tabung mempercepat impianmu tercapai.',
          'Sayang kalau langsung dihabiskan! Sisa jajan yang dipindah ke Tabung akan memperbesar tabunganmu.',
          'OJK SikapiUangmu - Mengelola Uang Saku (SD)'
        ),
        (
          'mengatur_jajan', 2,
          'Di kelas ada penggalangan sumbangan sukarela untuk teman yang sedang sakit. Dari toples mana sebaiknya Doni mengambil uang?',
          'Toples Jajan dengan menghabiskan semuanya',
          'Meminjam uang kas kelas',
          'Menjual buku pelajaran',
          'Toples Berbagi yang memang disiapkan untuk menolong sesama',
          'd',
          'Mulia dan tepat! Toples Berbagi disiapkan untuk kegiatan sosial, sedekah, atau membantu teman.',
          'Belum tepat. Itulah guna toples Berbagi, supaya kamu siap membantu tanpa mengganggu tabunganmu.',
          'OJK SikapiUangmu - Pos Keuangan Sederhana (SD)'
        ),
        (
          'mengatur_jajan', 2,
          'Jatah jajan harian Tari Rp8.000. Hari ini ia ingin beli minuman Rp6.000 dan kue Rp5.000 (total Rp11.000). Apa keputusan yang bijak?',
          'Pilih salah satu yang sesuai batas Rp8.000',
          'Tetap beli keduanya walau uang tidak cukup',
          'Mengambil diam-diam dari dompet orang tua',
          'Mencatat harga kue jadi Rp2.000',
          'a',
          'Bijak sekali! Membeli sesuai batas uang jajan melatih kita disiplin dan jujur.',
          'Belum tepat. Jika uangnya Rp8.000, kita harus menyesuaikan pilihan agar tidak melebihi batas.',
          'OJK SikapiUangmu - Mengelola Uang Saku (SD)'
        ),
        (
          'mengatur_jajan', 2,
          'Setelah ikut lomba mewarnai, Mira mendapat hadiah uang Rp50.000 dari nenek. Di mana sebaiknya Mira mencatat uang tersebut?',
          'Tidak usah dicatat dan habiskan hari ini',
          'Catat sebagai Uang Masuk ke Tabung untuk impian',
          'Catat sebagai pengeluaran jajan',
          'Masukkan ke buku absen sekolah',
          'b',
          'Tepat! Uang hadiah di luar uang saku dicatat sebagai uang masuk ke Tabung agar impian cepat terwujud.',
          'Kurang tepat. Hadiah dari keluarga adalah uang masuk yang sangat bagus disimpan ke Tabung.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),

        -- ===================================================================
        -- TOPIK 4: menahan_keinginan (Level 1: soal 31-35, Level 2: soal 36-40)
        -- ===================================================================
        (
          'menahan_keinginan', 1,
          'Saat istirahat, teman-teman banyak membeli mainan kartu baru. Bima sebenarnya sedang menabung untuk membeli sepeda. Apa sikap terbaik Bima?',
          'Menahan diri dan tetap fokus pada target sepedanya',
          'Ikut membeli kartu agar tidak ketinggalan meski uang habis',
          'Membuang rencana menabung sepeda',
          'Meminjam uang ke teman sekelas',
          'a',
          'Hebat! Menahan diri dari ikut-ikutan teman menjaga impian besar kita tetap aman.',
          'Belum tepat. Mengikuti gaya teman bisa membuat tabungan untuk impian utama jadi habis.',
          'OJK SikapiUangmu - Pengendalian Diri Finansial (SD)'
        ),
        (
          'menahan_keinginan', 1,
          'Kamu melihat mainan lucu di etalase toko, padahal kemarin kamu belum berencana membelinya. Apa aturan sederhana sebelum membeli?',
          'Langsung beli detik itu juga sebelum kehabisan',
          'Tunggu beberapa hari dan pikirkan apakah benar-benar perlu',
          'Minta orang tua membelikan dengan marah',
          'Ambil uang tabungan sekolah',
          'b',
          'Cerdas! Menunggu beberapa hari membantu kita membedakan keinginan sesaat dan kebutuhan nyata.',
          'Hati-hati belanja impulsif! Menunggu dan berpikir dulu sering membuat kita sadar barang itu tidak perlu.',
          'OJK SikapiUangmu - Pengendalian Diri Finansial (SD)'
        ),
        (
          'menahan_keinginan', 1,
          'Ayah berjanji memberi bonus Rp5.000 jika tabungan Budi sebesar Rp50.000 tidak diambil sampai akhir bulan. Apa pelajaran dari janji ini?',
          'Uang harus segera dibelanjakan sebelum akhir bulan',
          'Menabung tidak ada gunanya',
          'Kesabaran menahan keinginan membawa hasil lebih besar',
          'Bonus bisa didapat tanpa menabung',
          'c',
          'Tepat! Menahan diri untuk tidak mengambil tabungan melatih kesabaran dan memberi manfaat lebih.',
          'Belum tepat. Bonus tabungan mengajarkan bahwa bersabar menjaga tabungan menghasilkan nilai lebih.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menahan_keinginan', 1,
          'Di kantin dijual jajanan warna-warni mencolok yang kurang sehat. Uang jajan Fajar masih utuh Rp10.000. Apa pilihan yang paling sehat dan hemat?',
          'Beli tiga bungkus jajanan itu',
          'Beli semua warna supaya lengkap',
          'Tukarkan semua uang dengan permen',
          'Simpan uangnya dan makan bekal sehat dari rumah',
          'd',
          'Mantap! Tubuh tetap sehat dan uang jajan pun aman masuk tabungan.',
          'Coba pikirkan lagi: menahan diri dari jajanan kurang sehat membuat badan sehat dan tabungan bertambah.',
          'OJK SikapiUangmu - Hidup Hemat dan Sehat (SD)'
        ),
        (
          'menahan_keinginan', 1,
          'Nia mendapat uang THR Lebaran Rp100.000. Ia ingin membeli sepatu impian seharga Rp120.000. Apa langkah paling bijak untuk uang THR tersebut?',
          'Simpan di tabungan agar tinggal kurang Rp20.000',
          'Habiskan untuk membeli mainan kecil di pasar malam',
          'Belikan semua teman es krim',
          'Biarkan hilang di saku baju',
          'a',
          'Pintar sekali! Mengarahkan uang hadiah ke tabungan membuat sepatu impian Nia hampir tercapai.',
          'Belum tepat. Uang THR sangat membantu mempercepat impian besar jika tidak langsung habis untuk keinginan kecil.',
          'OJK SikapiUangmu - Mengelola Uang Hadiah (SD)'
        ),
        (
          'menahan_keinginan', 2,
          'Saat merasa bosan di rumah, tiba-tiba kita ingin membeli sesuatu padahal tidak butuh. Apa cara baik mengalihkan rasa ingin jajan karena bosan?',
          'Belanja terus sampai uang habis',
          'Membaca buku, bermain di rumah, atau mengerjakan hobi gratis',
          'Membuka celengan setiap jam untuk jajan',
          'Meminta uang jajan tambahan terus-menerus',
          'b',
          'Keren! Melakukan aktivitas seru tanpa biaya menjaga uang saku tetap aman.',
          'Belum tepat. Rasa bosan tidak harus diobati dengan belanja; banyak kegiatan menyenangkan yang gratis!',
          'OJK SikapiUangmu - Pengendalian Diri Finansial (SD)'
        ),
        (
          'menahan_keinginan', 2,
          'Rafi sudah menabung Rp80.000 dari target Rp100.000 untuk tas baru. Tiba-tiba ia tergoda membeli mainan Rp30.000. Apa akibatnya jika ia mengambil tabungan itu?',
          'Tas baru langsung terbeli besok',
          'Tabungannya bertambah jadi Rp110.000',
          'Tabungannya berkurang jadi Rp50.000 dan tas makin lama tercapai',
          'Harga tas otomatis turun Rp30.000',
          'c',
          'Betul! Mengambil tabungan untuk keinginan sesaat membuat target impian utama jadi mundur lagi.',
          'Hitung ulang ya: Rp80.000 - Rp30.000 = Rp50.000, artinya jarak ke target Rp100.000 justru makin jauh.',
          'OJK SikapiUangmu - Menabung Mewujudkan Impianku (SD)'
        ),
        (
          'menahan_keinginan', 2,
          'Mengapa tidak semua keinginan yang muncul harus dibeli saat itu juga?',
          'Karena toko akan tutup selamanya',
          'Karena uang saku tidak punya batas',
          'Karena menabung tidak boleh dilakukan anak SD',
          'Karena uang kita terbatas dan ada kebutuhan lebih penting',
          'd',
          'Tepat! Uang yang kita miliki jumlahnya terbatas sehingga kita harus memilih yang paling penting.',
          'Belum tepat. Memahami bahwa uang terbatas membuat kita bijak memilih prioritas.',
          'OJK SikapiUangmu - Mengenal Jasa Keuangan (SD)'
        ),
        (
          'menahan_keinginan', 2,
          'Tante memberi uang hadiah Rp50.000 karena nilai ujian Adi bagus. Adi ingin langsung membeli es krim mahal Rp45.000. Bagaimana cara yang lebih seimbang?',
          'Sisihkan sebagian besar ke Tabung, dan pakai sedikit saja untuk jajan wajar',
          'Habiskan Rp50.000 sekaligus sebelum pulang',
          'Jangan ucapkan terima kasih kepada Tante',
          'Pinjam lagi Rp50.000 ke teman',
          'a',
          'Seimbang dan dewasa! Boleh merayakan secukupnya, tetapi sebagian besar tetap diamankan ke tabungan.',
          'Kurang tepat. Uang hadiah akan jauh lebih bermanfaat jika porsi terbesarnya ditabung untuk masa depan.',
          'OJK SikapiUangmu - Mengelola Uang Hadiah (SD)'
        ),
        (
          'menahan_keinginan', 2,
          'Apa tanda bahwa kamu sudah berhasil menahan keinginan dengan baik?',
          'Semua uang jajan habis sebelum hari Selasa',
          'Bisa melewati godaan jajan tidak perlu demi impian yang lebih besar',
          'Membeli barang mahal yang tidak dipakai',
          'Selalu iri dengan barang baru teman',
          'b',
          'Mantap! Mampu berkata "nanti dulu" pada godaan kecil adalah tanda kecerdasan finansial.',
          'Belum tepat. Keberhasilan menahan keinginan terlihat saat kita tetap setia pada tujuan tabungan kita.',
          'OJK SikapiUangmu - Pengendalian Diri Finansial (SD)'
        ),

        -- ===================================================================
        -- TOPIK 5: promo (Level 1: soal 41-45, Level 2: soal 46-50)
        -- ===================================================================
        (
          'promo', 1,
          'Di toko ada promo "Diskon 50% topi robot!" dari Rp40.000 jadi Rp20.000. Padahal Tono tidak butuh topi dan sedang menabung buku. Apakah Tono untung jika membelinya?',
          'Tidak, ia justru keluar uang Rp20.000 untuk barang yang tidak dibutuhkan',
          'Ya, karena ia langsung untung Rp20.000 tunai',
          'Ya, karena semua barang diskon wajib dibeli',
          'Tidak, kecuali ia membeli lima topi sekaligus',
          'a',
          'Cerdas sekali! Membeli barang yang tidak dibutuhkan meski diskon tetap mengurangi uangmu.',
          'Hati-hati jebakan diskon! Diskon hanya hemat kalau kamu memang sudah berencana membeli barang itu.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        ),
        (
          'promo', 1,
          'Kantin memasang promo "Beli 2 gratis 1" untuk minuman manis seharga Rp6.000 per botol. Siska sebenarnya hanya haus dan cukup 1 botol. Apa pilihan paling hemat?',
          'Beli 2 botol seharga Rp12.000 agar dapat bonus',
          'Beli 1 botol saja Rp6.000 sesuai kebutuhan',
          'Beli 4 botol agar dapat 2 gratis',
          'Habiskan seluruh uang saku Rp20.000 untuk promo',
          'b',
          'Tepat! Membeli 1 botol hanya keluar Rp6.000, lebih hemat Rp6.000 dibanding mengejar bonus yang tidak perlu.',
          'Coba hitung: membeli 2 botol berarti keluar Rp12.000, lebih mahal daripada membeli 1 botol Rp6.000 yang cukup untukmu.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        ),
        (
          'promo', 1,
          'Iklan di televisi berkata: "Mainan ini membuatmu paling keren di kelas!" Apa sikap kritis yang harus dimiliki anak cerdas?',
          'Langsung percaya semua kata iklan',
          'Menangis sampai orang tua membelikan',
          'Sadari bahwa iklan bertujuan mengajak membeli, lalu cek kebutuhan sendiri',
          'Membeli barang itu tanpa melihat harganya',
          'c',
          'Pintar! Iklan dibuat agar menarik, jadi kita harus tetap mengecek apakah barangnya benar-benar dibutuhkan.',
          'Jangan mudah terbujuk iklan! Selalu tanya pada diri sendiri: "Apakah aku benar-benar butuh barang ini?"',
          'OJK SikapiUangmu - Literasi Konsumen Anak (SD)'
        ),
        (
          'promo', 1,
          'Toko A menjual pensil warna yang dibutuhkan Rina seharga Rp15.000 dengan diskon menjadi Rp12.000. Kapan diskon ini benar-benar menguntungkan Rina?',
          'Saat Rina sudah punya tiga kotak pensil warna baru',
          'Saat Rina membelinya hanya karena warna kemasannya lucu',
          'Saat Rina meminjam uang teman untuk memborongnya',
          'Saat Rina memang sedang membutuhkan pensil warna untuk tugas sekolah',
          'd',
          'Benar! Promo dan diskon sangat bagus dimanfaatkan untuk barang yang memang kita butuhkan.',
          'Kurang tepat. Diskon hanya bermanfaat jika barangnya memang masuk dalam daftar kebutuhan kita.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        ),
        (
          'promo', 1,
          'Di warung tertulis "Paket Hemat: Buku + Stiker Rp15.000". Jika membeli buku saja harganya Rp10.000, sedangkan Dika tidak butuh stiker. Mana yang lebih hemat?',
          'Beli buku saja Rp10.000 sehingga hemat Rp5.000',
          'Beli paket Rp15.000 karena ada kata hemat',
          'Beli dua paket sekaligus',
          'Tidak jadi membeli buku padahal butuh',
          'a',
          'Jeli sekali! Jangan terkecoh tulisan "Paket Hemat"; pilih yang benar-benar dibutuhkan agar hemat Rp5.000.',
          'Periksa harganya baik-baik: Rp10.000 lebih murah daripada Rp15.000 jika kamu hanya butuh bukunya.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        ),
        (
          'promo', 2,
          'Toko X menjual penghapus Rp3.000 tanpa diskon. Toko Y menaikkan harga jadi Rp6.000 lalu menulis "Diskon 50% jadi Rp3.000". Bagaimana perbandingan harganya?',
          'Toko Y jauh lebih murah',
          'Harganya sama saja Rp3.000, jadi jangan tertipu tulisan diskon besar',
          'Toko X lebih mahal dua kali lipat',
          'Toko Y gratis untuk pelajar',
          'b',
          'Hebat! Membandingkan harga akhir membantumu melihat bahwa 50% dari Rp6.000 tetap sama Rp3.000.',
          'Hitung harga akhirnya ya: 50% dari Rp6.000 adalah Rp3.000, sama persis dengan harga normal di Toko X.',
          'OJK SikapiUangmu - Literasi Konsumen Anak (SD)'
        ),
        (
          'promo', 2,
          'Bima melihat tulisan "Promo hanya hari ini! Sisa 1 jam!" di toko mainan. Mengapa penjual sering menulis batas waktu singkat seperti itu?',
          'Karena besok semua toko uangnya hilang',
          'Supaya pembeli sempat menabung dulu',
          'Agar pembeli terburu-buru membeli tanpa berpikir panjang',
          'Karena mainan akan rusak besok pagi',
          'c',
          'Tepat! Promo kilat membuat orang terburu-buru. Tetap tenang dan cek apakah itu kebutuhanmu.',
          'Belum tepat. Batas waktu singkat sering dipakai agar pembeli tergoda membeli sebelum sempat berpikir tenang.',
          'OJK SikapiUangmu - Literasi Konsumen Anak (SD)'
        ),
        (
          'promo', 2,
          'Ibu mengajak Sari membeli buku tulis untuk semester baru. Toko Merah menjual Rp24.000 untuk 6 buku, Toko Biru menjual Rp4.500 per buku. Mana yang lebih murah per buku?',
          'Toko Biru Rp4.500 per buku',
          'Harganya sama persis',
          'Tidak bisa dibandingkan',
          'Toko Merah Rp4.000 per buku',
          'd',
          'Pintar berhitung! Rp24.000 dibagi 6 buku adalah Rp4.000 per buku, lebih murah Rp500 per buku dari Toko Biru.',
          'Coba bagi Rp24.000 dengan 6 buku: hasilnya Rp4.000 per buku, lebih murah daripada Rp4.500 di Toko Biru.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        ),
        (
          'promo', 2,
          'Di kemasan camilan tertulis "Gratis stiker hadiah di dalam!" sehingga harganya Rp4.000 lebih mahal dari camilan biasa. Apa yang perlu dicek sebelum membeli?',
          'Apakah kita benar-benar butuh camilan seharga itu atau hanya tergoda hadiahnya',
          'Apakah stikernya bisa dimakan',
          'Apakah teman sekelas akan iri',
          'Apakah kemasannya paling besar di rak',
          'a',
          'Benar! Hadiah kecil di kemasan sering membuat harga lebih mahal; fokuslah pada kebutuhan utamanya.',
          'Belum tepat. Anak cerdas selalu memeriksa apakah harga tambahannya sepadan dengan kebutuhannya.',
          'OJK SikapiUangmu - Literasi Konsumen Anak (SD)'
        ),
        (
          'promo', 2,
          'Apa tiga pertanyaan cerdas sebelum membeli barang yang sedang promo?',
          'Warnanya apa, siapa penjualnya, dan bisa dipamerkan tidak?',
          'Apakah aku butuh, apakah uangnya cukup tanpa mengganggu tabungan, dan apakah harganya wajar?',
          'Apakah iklannya lucu, apakah teman punya, dan apakah ada stikernya?',
          'Apakah belinya bisa buru-buru tanpa izin orang tua?',
          'b',
          'Sempurna! Mengecek kebutuhan, kecukupan uang, dan kewajaran harga membuatmu menjadi pembeli bijak.',
          'Belum tepat. Pembeli cerdas selalu mengecek kebutuhan, batas uang, dan kewajaran harga sebelum membayar.',
          'OJK SikapiUangmu - Cermat Berbelanja (SD)'
        )
    ) AS v(
      topik,
      level,
      cerita,
      opsi_a,
      opsi_b,
      opsi_c,
      opsi_d,
      jawaban,
      penjelasan_benar,
      penjelasan_salah,
      sumber
    )
    JOIN public.misi m
      ON m.topik = v.topik
     AND m.level = v.level;
  END IF;
END $$;
