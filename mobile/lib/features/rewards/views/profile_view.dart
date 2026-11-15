import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/rewards/viewmodels/rewards_viewmodel.dart';
import 'package:koini/features/rewards/views/badge_gallery_view.dart';
import 'package:koini/features/rewards/widgets/badge_icon.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({
    super.key,
    required this.store,
    required this.parentAccess,
  });
  final KoiniStore store;
  final VoidCallback parentAccess;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  KoiniStore get store => widget.store;
  late final model = RewardsViewModel(store);

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
    void gallery() => openPage(context, BadgeGalleryView(store: store));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: Mascot(size: 108, glow: true)),
        const Gap(7),
        heading(model.name, size: 26, align: TextAlign.center),
        caption('${model.age} tahun', align: TextAlign.center),
        const Gap(),
        Row(
          children: [
            Expanded(
              child: Stat(
                'Streak belajar',
                '${model.streak} hari',
                color: KColors.peach,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Stat('Poin belajar', '${model.stars} bintang')),
          ],
        ),
        const Gap(9),
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('${earned.length} lencana kamu', size: 17),
              const Gap(8),
              if (earned.isEmpty)
                caption(
                  'Selesaikan tantangan untuk memperoleh lencana pertamamu.',
                ),
              if (earned.isNotEmpty)
                Wrap(
                  spacing: 13,
                  runSpacing: 7,
                  children: [
                    for (final badge in earned.take(3))
                      SizedBox(
                        width: 76,
                        child: InkWell(
                          onTap: () => showBadge(context, badge),
                          child: Column(
                            children: [
                              const BadgeIcon(true),
                              const Gap(4),
                              caption(badge.name, align: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const Gap(9),
        KRow(
          'Galeri lencana',
          'Lihat pencapaian dan tantangan baru',
          onTap: gallery,
        ),
        const Gap(8),
        KRow(
          'Akses orang tua',
          'Serahkan HP ke Ayah/Bunda',
          onTap: widget.parentAccess,
          trailing: const Icon(Icons.lock_outline_rounded, color: KColors.gold),
        ),
        const Gap(),
        KButton('Galeri lencana', onTap: gallery),
      ],
    );
  }
}

@Preview(name: 'Profil anak', group: 'Penghargaan', size: koiniPreviewSize)
Widget profilePreview() => KoiniPreviewHost(
  page: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.profile),
  scenario: PreviewScenario.missionsComplete,
);
