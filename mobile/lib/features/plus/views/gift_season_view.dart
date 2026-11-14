import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/views/gift_release_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class GiftSeasonView extends StatefulWidget {
  const GiftSeasonView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<GiftSeasonView> createState() => _GiftSeasonViewState();
}

class _GiftSeasonViewState extends State<GiftSeasonView> {
  final memo = TextEditingController();
  final total = TextEditingController();
  final parts = {for (final jar in Jar.values) jar: TextEditingController()};
  final held = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    for (final controller in [memo, total, held, ...parts.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  int number(TextEditingController controller) =>
      int.tryParse(controller.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final remainder =
        number(total) -
        number(held) -
        parts.values.fold<int>(0, (a, b) => a + number(b));
    return KPage(
      title: 'Musim uang hadiah',
      footer: KButton(
        'Simpan rencana',
        onTap: busy
            ? null
            : () async {
                FocusScope.of(context).unfocus();
                final approved = await showDialog<bool>(
                  context: context,
                  useRootNavigator: false,
                  builder: (dialog) => AlertDialog(
                    title: heading('Catat uang hadiah?'),
                    content: const Text(
                      'Pastikan uangnya sudah diterima sebelum menyimpan pembagian.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialog, false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialog, true),
                        child: const Text('Catat hadiah'),
                      ),
                    ],
                  ),
                );
                if (!mounted || !context.mounted || approved != true) return;
                setState(() => busy = true);
                final error = await widget.store.recordGift(
                  number(total),
                  parts.map((jar, data) => MapEntry(jar, number(data))),
                  number(held),
                  memo.text.trim().isEmpty ? 'Uang hadiah' : memo.text.trim(),
                );
                if (!mounted || !context.mounted) return;
                if (error == null) {
                  Navigator.pop(context);
                  note(context, 'Uang hadiah tercatat.');
                } else {
                  setState(() => busy = false);
                  note(context, error);
                }
              },
      ),
      children: [
        KCard(
          bright: true,
          child: Column(
            children: [
              KField('Nama hadiah', memo, hint: 'Uang Lebaran atau angpao'),
              const Gap(9),
              KField(
                'Uang hadiah diterima',
                total,
                numeric: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        for (final jar in Jar.values) ...[
          const Gap(7),
          KCard(
            child: Row(
              children: [
                Illustration(jarArt(jar), size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: KField(
                    jar.label,
                    parts[jar]!,
                    numeric: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Gap(7),
        KCard(
          border: KColors.gold,
          child: KField(
            'Dititip ke Ayah/Bunda',
            held,
            numeric: true,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const Gap(8),
        caption(
          'Sisa belum dibagi ${rupiah(remainder)}',
          color: remainder == 0 ? KColors.mint : KColors.peach,
        ),
        if (widget.store.heldGift > 0) ...[
          const Gap(6),
          caption(
            'Titipan yang sudah tercatat ${rupiah(widget.store.heldGift)}.',
          ),
          const Gap(7),
          KRow(
            'Kembalikan uang titipan',
            'Catat uang yang sudah dikembalikan ke salah satu toples.',
            onTap: () =>
                openPage(context, GiftReleaseView(store: widget.store)),
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Musim uang hadiah', group: 'Plus', size: koiniPreviewSize)
Widget giftSeasonPreview() => KoiniPreviewHost(
  page: (context, store) => GiftSeasonView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
