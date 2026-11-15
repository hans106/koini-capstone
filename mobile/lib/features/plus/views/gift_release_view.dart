import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/features/plus/viewmodels/gift_viewmodel.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class GiftReleaseView extends StatefulWidget {
  const GiftReleaseView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<GiftReleaseView> createState() => _GiftReleaseViewState();
}

class _GiftReleaseViewState extends State<GiftReleaseView> {
  final amount = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    model.dispose();
    super.dispose();
  }

  late final model = GiftReleaseViewModel(widget.store);

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => KPage(
    title: 'Kembalikan uang titipan',
    footer: KButton(
      'Catat pengembalian',
      onTap: model.busy
          ? null
          : () async {
              if (model.busy) return;
              final saved = await model.save(amount.text);
              if (!context.mounted) return;
              if (saved) {
                Navigator.pop(context);
              } else {
                note(context, model.error!);
              }
            },
    ),
    children: [
      Stat('Uang yang dititipkan', rupiah(model.heldGift)),
      const Gap(),
      KField('Uang yang dikembalikan', amount, numeric: true),
      const Gap(),
      caption('Ke toples'),
      const Gap(6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final jar in Jar.values)
            Pill(
              jar.label,
              selected: model.destination == jar,
              onTap: () => model.selectDestination(jar),
            ),
        ],
      ),
    ],
  );
}

@Preview(
  name: 'Pengembalian uang titipan',
  group: 'Plus',
  size: koiniPreviewSize,
)
Widget giftReleasePreview() => KoiniPreviewHost(
  page: (context, store) => GiftReleaseView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
