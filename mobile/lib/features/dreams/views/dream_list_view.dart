import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/viewmodels/dreams_viewmodel.dart';
import 'package:koini/features/dreams/views/create_dream_view.dart';
import 'package:koini/features/dreams/views/dream_detail_view.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class DreamListView extends StatefulWidget {
  const DreamListView({super.key, required this.store, this.parentAccess});
  final KoiniStore store;
  final VoidCallback? parentAccess;

  @override
  State<DreamListView> createState() => _DreamListViewState();
}

class _DreamListViewState extends State<DreamListView> {
  KoiniStore get store => widget.store;
  late final model = DreamsViewModel(store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (model.dreams.isEmpty) ...[
        const Gap(23),
        const Center(child: Mascot(glow: true, size: 128)),
        const Gap(20),
        const KCallout(
          'Belum ada impian',
          'Pilih barang impianmu dan nyalakan bintang dengan menabung.',
        ),
        const Gap(18),
      ],
      for (final dream in model.dreams) ...[
        KCard(
          border: dream == model.featured ? KColors.gold : null,
          onTap: () => openPage(
            context,
            DreamDetailView(
              store: store,
              id: dream.id,
              parentAccess: widget.parentAccess,
            ),
          ),
          child: Row(
            children: [
              dreamImage(dream),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading(dream.name, size: 21),
                    caption(
                      '${rupiah(model.savedFor(dream))} / ${rupiah(dream.target)}',
                    ),
                    const Gap(8),
                    GoalProgress(model.progress(dream)),
                    const Gap(5),
                    Row(
                      children: [
                        heading(
                          '${(model.progress(dream) * 100).round()}%',
                          size: 19,
                          color: KColors.gold,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: caption(
                            model.remaining(dream) == 0
                                ? 'Impian tercapai'
                                : 'Terus menabung',
                            align: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(11),
      ],
      const Gap(9),
      KButton(
        'Buat impian',
        onTap: () => openPage(context, CreateDreamView(store: store)),
      ),
    ],
  );
}

@Preview(name: 'Daftar impian', group: 'Impian', size: koiniPreviewSize)
Widget dreamListPreview() => KoiniPreviewHost(
  page: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.dreams),
  scenario: PreviewScenario.dream,
);
