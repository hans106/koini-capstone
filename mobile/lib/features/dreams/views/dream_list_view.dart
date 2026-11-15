import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/viewmodels/dreams_viewmodel.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<DreamsViewModel, DreamListView>(
      (ref, view) => DreamsViewModel(view.store),
    );

class DreamListView extends ConsumerStatefulWidget {
  const DreamListView({super.key, required this.store, this.parentAccess});
  final KoiniStore store;
  final VoidCallback? parentAccess;

  @override
  ConsumerState<DreamListView> createState() => _DreamListViewState();
}

class _DreamListViewState extends ConsumerState<DreamListView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  DreamsViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) => Column(
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
          onTap: () =>
              openPage(context, KRoute.dream, pathParameters: {'id': dream.id}),
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
        onTap: () => openPage(context, KRoute.createDream),
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
