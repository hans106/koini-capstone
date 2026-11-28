import 'package:koini/models/badge.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

List<KoiniBadge> badges(KoiniStore store) => [
  KoiniBadge(
    'Penabung pertama',
    'Catat tabungan pertamamu ke toples Tabung',
    store.entries.where((e) => e.kind == EntryKind.save).length,
    1,
  ),
  KoiniBadge(
    'Pencatat cermat',
    'Catat 3 aktivitas uang masuk atau keluar',
    store.entries.length,
    3,
  ),
  KoiniBadge(
    'Rajin 3 hari',
    'Belajar dan mencatat 3 hari beruntun',
    store.longestStreak,
    3,
  ),
  KoiniBadge(
    'Tekun seminggu',
    'Belajar dan mencatat 7 hari beruntun',
    store.longestStreak,
    7,
  ),
  KoiniBadge(
    'Penjelajah misi',
    'Selesaikan 5 misi kuis Koini',
    store.scores.length,
    5,
  ),
  KoiniBadge(
    'Juara literasi',
    'Selesaikan seluruh 10 misi kuis Koini',
    store.scores.length,
    10,
  ),
  KoiniBadge(
    'Peraih impian',
    'Capai 1 target impian pertamamu',
    store.dreams.where((d) => store.remaining(d) == 0).length,
    1,
  ),
  KoiniBadge(
    'Dermawan cilik',
    'Catat aktivitas berbagi pertamamu',
    store.entries.where((e) => e.kind == EntryKind.give).length,
    1,
  ),
  KoiniBadge(
    'Penjaga celengan',
    'Lakukan pengecekan uang fisik celengan pertamamu',
    store.piggyChecks.length,
    1,
  ),
];
