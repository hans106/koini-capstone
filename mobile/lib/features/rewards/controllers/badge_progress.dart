import 'package:koini/models/badge.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/services/koini_store.dart';

List<KoiniBadge> badges(KoiniStore store) => [
  KoiniBadge(
    'Penabung pertama',
    'Catat tabungan pertamamu',
    store.entries.where((e) => e.kind == EntryKind.save).length,
    1,
  ),
  KoiniBadge(
    'Pencatat cermat',
    'Catat 3 aktivitas uang',
    store.entries.length,
    3,
  ),
  KoiniBadge('Rajin 3 hari', 'Belajar 3 hari beruntun', store.longestStreak, 3),
  KoiniBadge(
    'Tekun seminggu',
    'Belajar 7 hari beruntun',
    store.longestStreak,
    7,
  ),
  KoiniBadge('Penjelajah misi', 'Selesaikan 4 misi', store.scores.length, 4),
  KoiniBadge(
    'Peraih impian',
    'Capai 1 target impian',
    store.dreams.where((d) => store.remaining(d) == 0).length,
    1,
  ),
];
