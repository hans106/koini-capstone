import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
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
  Jar destination = Jar.tabung;
  bool busy = false;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KPage(
    title: 'Kembalikan uang titipan',
    footer: KButton(
      'Catat pengembalian',
      onTap: busy
          ? null
          : () async {
              setState(() => busy = true);
              final error = await widget.store.releaseGift(
                int.tryParse(amount.text) ?? 0,
                destination,
              );
              if (!context.mounted) return;
              if (error == null) {
                Navigator.pop(context);
              } else {
                setState(() => busy = false);
                note(context, error);
              }
            },
    ),
    children: [
      Stat('Uang yang dititipkan', rupiah(widget.store.heldGift)),
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
              selected: destination == jar,
              onTap: () => setState(() => destination = jar),
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
