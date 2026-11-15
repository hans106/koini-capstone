import 'package:koini/core/viewmodels/view_model.dart';
import 'package:koini/services/koini_store.dart';

class KoiniStoryViewModel extends StoreViewModel {
  KoiniStoryViewModel(this._store) : super(_store);
  final KoiniStore _store;

  static const topics = [
    (
      'Butuh atau mau?',
      'Belajar memilih sebelum membeli.',
      'Bayu haus setelah bermain. Ia ingin es krim, tapi memilih air putih dulu. Apa yang kamu pilih saat uangmu cukup untuk satu barang?',
    ),
    (
      'Menabung sedikit-sedikit',
      'Kenali kebiasaan kecil yang baik.',
      'Mira menaruh Rp5.000 di toples setiap minggu. Empat minggu kemudian, tabungannya jadi Rp20.000! Apa yang ingin kamu tabung?',
    ),
    (
      'Rencanakan impianmu',
      'Tentukan langkah yang realistis.',
      'Dito ingin membeli buku Rp50.000. Ia sudah punya Rp20.000. Berapa yang perlu ia tabung berikutnya?',
    ),
  ];

  int _current = 0;
  bool _revealed = false;

  bool get hasPlus => _store.hasPlus;
  bool get permitted => hasPlus && _store.stories;
  int get current => _current;
  String get message => !permitted
      ? 'Ayah/Bunda bisa mengaktifkan Cerita Koini di Setelan.'
      : _revealed
      ? topics[current].$3
      : 'Pilih salah satu topik di bawah untuk mulai.';

  void reveal() {
    if (!permitted) return;
    _revealed = true;
    changed();
  }

  void select(int value) {
    _current = value;
    _revealed = false;
    changed();
  }
}
