import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class KoiniStoryView extends StatefulWidget {
  const KoiniStoryView({
    super.key,
    required this.store,
    required this.parentAccess,
  });
  final KoiniStore store;
  final VoidCallback parentAccess;

  @override
  State<KoiniStoryView> createState() => _KoiniStoryViewState();
}

class _KoiniStoryViewState extends State<KoiniStoryView> {
  int current = 0;
  bool revealed = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final permitted = widget.store.stories && widget.store.hasPlus;
      const topics = [
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
      return KPage(
        title: 'Cerita dengan Koini',
        subtitle: 'Pilih topik, belajar bersama',
        footer: KButton(
          permitted ? 'Baca cerita' : 'Ajak Ayah/Bunda',
          onTap: () {
            if (permitted) {
              setState(() => revealed = true);
            } else if (!widget.store.hasPlus) {
              plusGate(
                context,
                yearly: false,
                parentAccess: widget.parentAccess,
              );
            } else {
              widget.parentAccess();
            }
          },
        ),
        children: [
          KCallout(
            'Koini',
            !permitted
                ? 'Ayah/Bunda bisa mengaktifkan Cerita Koini di Setelan.'
                : revealed
                ? topics[current].$3
                : 'Pilih salah satu topik di bawah untuk mulai.',
          ),
          const Gap(),
          heading('Topik cerita', size: 19),
          const Gap(7),
          for (var i = 0; i < topics.length; i++) ...[
            KRow(
              topics[i].$1,
              topics[i].$2,
              color: current == i ? KColors.gold : null,
              onTap: () => setState(() {
                current = i;
                revealed = false;
              }),
            ),
            const Gap(7),
          ],
          caption('Cerita dalam mode demo mengikuti topik pilihanmu.'),
        ],
      );
    },
  );
}

@Preview(name: 'Cerita dengan Koini', group: 'Misi', size: koiniPreviewSize)
Widget storyPreview() => KoiniPreviewHost(
  page: (context, store) => KoiniStoryView(
    store: store,
    parentAccess: () => openParentArea(context, store),
  ),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.missions),
);
