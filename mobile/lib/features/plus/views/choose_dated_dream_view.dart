import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/viewmodels/dreams_viewmodel.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<DreamsViewModel, ChooseDatedDreamView>(
      (ref, view) => DreamsViewModel(view.store),
    );

class ChooseDatedDreamView extends ConsumerStatefulWidget {
  const ChooseDatedDreamView({super.key, required this.store});
  final KoiniStore store;

  @override
  ConsumerState<ChooseDatedDreamView> createState() =>
      _ChooseDatedDreamViewState();
}

class _ChooseDatedDreamViewState extends ConsumerState<ChooseDatedDreamView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  DreamsViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    final dreams = model.activeDreams;
    return KPage(
      title: 'Target bertanggal',
      children: [
        for (final dream in dreams) ...[
          KRow(
            dream.name,
            'Kurang ${rupiah(model.remaining(dream))}',
            icon: dreamImage(dream, size: 40),
            onTap: () => openDatedGoal(context, store, dream),
          ),
          const Gap(7),
        ],
      ],
    );
  }
}

@Preview(name: 'Pilih impian bertanggal', group: 'Plus', size: koiniPreviewSize)
Widget chooseDatedDreamPreview() => KoiniPreviewHost(
  page: (context, store) => ChooseDatedDreamView(store: store),
  scenario: PreviewScenario.plus,
  returnPage: (context, store) => ParentDashboardView(store: store),
);
