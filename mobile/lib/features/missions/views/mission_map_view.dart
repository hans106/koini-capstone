import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/viewmodels/mission_map_viewmodel.dart';
import 'package:koini/features/missions/views/mission_quiz_view.dart';
import 'package:koini/features/missions/widgets/mission_trail.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class MissionMapView extends StatefulWidget {
  const MissionMapView({super.key, required this.store, required this.onStory});
  final KoiniStore store;
  final VoidCallback onStory;

  @override
  State<MissionMapView> createState() => _MissionMapViewState();
}

class _MissionMapViewState extends State<MissionMapView> {
  KoiniStore get store => widget.store;
  late final model = MissionMapViewModel(store);

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: model, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
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
            MissionQuizView(store: store, mission: model.next),
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
