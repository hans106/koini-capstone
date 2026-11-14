import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/widgets/dream_image.dart';
import 'package:koini/features/parents/views/parent_dashboard_view.dart';
import 'package:koini/models/koini_data.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class ChooseDatedDreamView extends StatelessWidget {
  const ChooseDatedDreamView({super.key, required this.store});
  final KoiniStore store;

  @override
  Widget build(BuildContext context) {
    final dreams = store.dreams
        .where((dream) => store.remaining(dream) > 0)
        .toList();
    return KPage(
      title: 'Target bertanggal',
      children: [
        for (final dream in dreams) ...[
          KRow(
            dream.name,
            'Kurang ${rupiah(store.remaining(dream))}',
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
