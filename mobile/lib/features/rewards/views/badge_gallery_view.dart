import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/rewards/viewmodels/rewards_viewmodel.dart';
import 'package:koini/features/rewards/widgets/badge_icon.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class BadgeGalleryView extends StatefulWidget {
  const BadgeGalleryView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<BadgeGalleryView> createState() => _BadgeGalleryViewState();
}

class _BadgeGalleryViewState extends State<BadgeGalleryView> {
  int filter = 0;
  late final model = RewardsViewModel(widget.store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final earned = model.earned.toList();
    final locked = model.locked.toList();
    return KPage(
      title: 'Galeri lencana',
      subtitle: '${earned.length} lencana sudah kamu peroleh',
      footer: KButton('Kembali ke Profil', onTap: () => Navigator.pop(context)),
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 6,
          children: [
            for (final (index, label) in [
              'Semua',
              'Diperoleh',
              'Tantangan',
            ].indexed)
              Pill(
                label,
                selected: index == filter,
                onTap: () => setState(() => filter = index),
              ),
          ],
        ),
        const Gap(),
        const Text(
          'Setiap lencana adalah jejak belajarmu. Pelan-pelan, kamu pasti bisa!',
        ),
        for (final (show, label, items) in [
          (filter != 2, 'Sudah diperoleh', earned),
          (filter != 1, 'Tantangan berikutnya', locked),
        ])
          if (show) ...[
            const Gap(12),
            heading(
              label,
              size: 17,
              color: items == earned ? KColors.mint : KColors.gold,
            ),
            const Gap(5),
            if (items.isEmpty) const KRow('Belum ada lencana di sini', ''),
            if (items.isNotEmpty)
              KCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    for (final badge in items)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        onTap: () => showBadge(context, badge),
                        leading: BadgeIcon(badge.earned),
                        title: heading(badge.name, size: 16),
                        subtitle: caption(
                          '${badge.description} · ${badge.earned ? 'Diperoleh' : '${badge.progress} dari ${badge.target}'}',
                        ),
                      ),
                  ],
                ),
              ),
          ],
        const Gap(),
        caption(
          'Lencana tidak bisa ditukar dengan uang.',
          align: TextAlign.center,
        ),
      ],
    );
  }
}

@Preview(name: 'Galeri lencana', group: 'Penghargaan', size: koiniPreviewSize)
Widget badgeGalleryPreview() => KoiniPreviewHost(
  page: (context, store) => BadgeGalleryView(store: store),
  scenario: PreviewScenario.missionsComplete,
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.profile),
);
