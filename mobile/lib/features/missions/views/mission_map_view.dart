import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/features/missions/views/mission_quiz_view.dart';
import 'package:koini/features/missions/widgets/mission_trail.dart';
import 'package:koini/previews/preview_data.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class MissionMapView extends StatelessWidget {
  const MissionMapView({super.key, required this.store, required this.onStory});
  final KoiniStore store;
  final VoidCallback onStory;

  @override
  Widget build(BuildContext context) {
    final nextIndex = missions.indexWhere(
      (mission) => !store.scores.containsKey(mission.id),
    );
    final next = nextIndex < 0 ? missions.last : missions[nextIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading('Jalur petualangan', size: 19),
        const Gap(6),
        SizedBox(
          height: 355,
          child: CustomPaint(
            painter: MissionTrail(progress: store.scores.length),
            child: Column(
              children: [
                for (var index = 0; index < missions.length; index++)
                  Expanded(
                    child: MissionStop(
                      mission: missions[index],
                      store: store,
                      locked: nextIndex >= 0 && index > nextIndex,
                      current: index == nextIndex,
                      reversed: index.isOdd,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(12),
        KCallout(
          '${store.scores.length} misi selesai',
          'Bintang untuk belajar, bukan uang.',
        ),
        const Gap(10),
        KButton(
          'Main misi',
          onTap: () =>
              openPage(context, MissionQuizView(store: store, mission: next)),
        ),
        const Gap(9),
        KButton('Cerita bersama', secondary: true, onTap: onStory),
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
