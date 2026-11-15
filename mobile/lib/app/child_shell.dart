import 'package:flutter/material.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell_viewmodel.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/dreams/views/dream_list_view.dart';
import 'package:koini/features/home/views/home_view.dart';
import 'package:koini/features/home/widgets/child_navigation_bar.dart';
import 'package:koini/features/missions/views/koini_story_view.dart';
import 'package:koini/features/missions/views/mission_map_view.dart';
import 'package:koini/features/rewards/views/badge_gallery_view.dart';
import 'package:koini/features/rewards/views/profile_view.dart';
import 'package:koini/features/transactions/views/structured_history_view.dart';
import 'package:koini/features/transactions/views/transaction_history_view.dart';
import 'package:koini/services/koini_store.dart';

enum ChildTab { home, dreams, history, missions, profile }

class ChildShell extends StatefulWidget {
  const ChildShell({
    super.key,
    required this.store,
    this.initialTab = ChildTab.home,
  });
  final KoiniStore store;
  final ChildTab initialTab;

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  late int index = widget.initialTab.index;
  late final model = ChildShellViewModel(widget.store);
  bool parentOpening = false;
  KoiniStore get store => widget.store;

  void select(int tab) => setState(() => index = tab);

  Future<void> parentAccess() async {
    if (parentOpening) return;
    parentOpening = true;
    try {
      await openParentArea(context, store);
    } finally {
      parentOpening = false;
    }
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      final title = [
        'Hai, ${model.name}!',
        'Impian kamu',
        'Catatan uangku',
        'Peta misi',
        'Profil kamu',
      ][index];
      final subtitle = [
        'Rencana uang sakumu hari ini.',
        '${model.dreamCount} impian sedang ditabung.',
        '',
        '${model.completedMissions} dari ${model.missionCount} misi',
        '',
      ][index];
      final content = switch (ChildTab.values[index]) {
        ChildTab.home => HomeView(store: store, parentAccess: parentAccess),
        ChildTab.dreams => DreamListView(
          store: store,
          parentAccess: parentAccess,
        ),
        ChildTab.history => TransactionHistoryView(
          store: store,
          onStructured: () {
            if (model.hasPlus) {
              openPage(context, StructuredHistoryView(store: store));
            } else {
              plusGate(context, yearly: false, parentAccess: parentAccess);
            }
          },
        ),
        ChildTab.missions => MissionMapView(
          store: store,
          onStory: () => openPage(
            context,
            KoiniStoryView(store: store, parentAccess: parentAccess),
          ),
        ),
        ChildTab.profile => ProfileView(
          store: store,
          parentAccess: parentAccess,
        ),
      };
      return Scaffold(
        body: Sky(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 11, 24, 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              if (index == 0) ...[
                                InkWell(
                                  onTap: () => select(4),
                                  customBorder: const CircleBorder(),
                                  child: const Tooltip(
                                    message: 'Profil kamu',
                                    child: Mascot(size: 32),
                                  ),
                                ),
                                const SizedBox(width: 7),
                              ],
                              Expanded(child: heading(title, size: 26)),
                              if (index == 0) ...[
                                Pill(
                                  '${model.streak} hari',
                                  icon: Icons.local_fire_department_rounded,
                                  color: KColors.peach,
                                  onTap: () => select(4),
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (index == 0 || index == 3)
                                Pill(
                                  '${model.stars}',
                                  icon: Icons.star_rounded,
                                  color: KColors.gold,
                                  onTap: () => openPage(
                                    context,
                                    BadgeGalleryView(store: store),
                                  ),
                                ),
                              if (index == 1)
                                Pill(
                                  '${model.dreamCount} impian',
                                  color: KColors.gold,
                                ),
                            ],
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: KColors.text,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        key: ValueKey(index),
                        padding: const EdgeInsets.fromLTRB(24, 3, 24, 16),
                        children: [content],
                      ),
                    ),
                    ChildNavigationBar(index: index, onSelect: select),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
