import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/viewmodels/dreams_viewmodel.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ChooseDatedDreamView extends StatefulWidget {
  const ChooseDatedDreamView({super.key, required this.store});
  final KoiniStore store;

  @override
  State<ChooseDatedDreamView> createState() => _ChooseDatedDreamViewState();
}

class _ChooseDatedDreamViewState extends State<ChooseDatedDreamView> {
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

  Widget buildPage(BuildContext context, Widget? child) {
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
