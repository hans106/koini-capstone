import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/viewmodels/mission_map_viewmodel.dart';
import 'package:koini/features/missions/widgets/mission_trail.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

final _viewModelProvider = ChangeNotifierProvider.autoDispose
    .family<MissionMapViewModel, MissionMapView>(
      (ref, view) => MissionMapViewModel(view.store),
    );

class MissionMapView extends ConsumerStatefulWidget {
  const MissionMapView({super.key, required this.store, required this.onStory});
  final KoiniStore store;
  final VoidCallback onStory;

  @override
  ConsumerState<MissionMapView> createState() => _MissionMapViewState();
}

class _MissionMapViewState extends ConsumerState<MissionMapView> {
  KoiniStore get store => widget.store;
  late final _provider = _viewModelProvider(widget);
  MissionMapViewModel get model => ref.read(_provider);

  @override
  Widget build(BuildContext context) {
    ref.watch(_provider);
    return buildPage(context);
  }

  Widget buildPage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading('Jalur petualangan', size: 19),
        const Gap(6),
        SizedBox(
          height: 355,
          child: CustomPaint(
            painter: MissionTrail(progress: model.completed),
            child: Column(
              children: [
                for (final (index, stop) in model.stops.indexed)
                  Expanded(
                    child: MissionStop(
                      mission: stop.mission,
                      store: store,
                      locked: stop.locked,
                      current: stop.current,
                      reversed: index.isOdd,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(12),
        KCallout(
          '${model.completed} misi selesai',
          'Bintang untuk belajar, bukan uang.',
        ),
        const Gap(10),
        KButton(
          'Main misi',
          onTap: () => openPage(
            context,
            KRoute.quiz,
            pathParameters: {'id': model.next.id},
          ),
        ),
        const Gap(9),
        KButton('Cerita bersama', secondary: true, onTap: widget.onStory),
      ],
    );
  }
}

@Preview(name: 'Peta misi', group: 'Misi', size: koiniPreviewSize)
Widget missionMapPreview() => KoiniPreviewHost(
  page: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.missions),
);

@Preview(name: 'Peta misi - selesai', group: 'Misi', size: koiniPreviewSize)
Widget completedMissionsPreview() => KoiniPreviewHost(
  page: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.missions),
  scenario: PreviewScenario.missionsComplete,
);
