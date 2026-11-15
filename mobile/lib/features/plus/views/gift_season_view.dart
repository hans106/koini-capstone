import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/gift_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<GiftSeasonViewModel, GiftSeasonView>(
      (ref, view) => GiftSeasonViewModel(view.store),
    );

class GiftSeasonView extends ConsumerStatefulWidget {
  const GiftSeasonView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<GiftSeasonView> createState() => _GiftSeasonViewState();
}

class _GiftSeasonViewState extends ConsumerState<GiftSeasonView> {
  final memo = TextEditingController();
  final total = TextEditingController();
  final parts = {for (final jar in Jar.values) jar: TextEditingController()};
  final held = TextEditingController();

  @override
  void dispose() {
    for (final controller in [memo, total, held, ...parts.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  late final _provider = _viewModelProvider(widget);
  GiftSeasonViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    final remainder = model.remainder;
    return KPage(
      title: 'Musim uang hadiah',
      footer: KButton(
        'Simpan rencana',
        onTap: model.busy
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
                if (model.busy) return;
                final saved = await model.save(memo.text);
                if (!mounted || !context.mounted) return;
                if (saved) {
                  Navigator.pop(context);
                  note(context, 'Uang hadiah tercatat.');
                } else {
                  note(context, model.error!);
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
                onChanged: model.changeTotal,
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
                    onChanged: (value) => model.changePart(jar, value),
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
            onChanged: model.changeHeld,
          ),
        ),
        const Gap(8),
        caption(
          'Sisa belum dibagi ${rupiah(remainder)}',
          color: remainder == 0 ? KColors.mint : KColors.peach,
        ),
        if (model.heldGift > 0) ...[
          const Gap(6),
          caption('Titipan yang sudah tercatat ${rupiah(model.heldGift)}.'),
          const Gap(7),
          KRow(
            'Kembalikan uang titipan',
            'Catat uang yang sudah dikembalikan ke salah satu toples.',
            onTap: () => openPage(context, KRoute.releaseGift),
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
