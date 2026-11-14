import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/app/child_shell.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/missions/controllers/mission_quiz_controller.dart';
import 'package:koini/features/missions/mission_content.dart';
import 'package:koini/models/mission.dart';
import 'package:koini/previews/preview_host.dart';
import 'package:koini/services/koini_store.dart';

class MissionQuizView extends StatefulWidget {
  const MissionQuizView({
    super.key,
    required this.store,
    required this.mission,
  });
  final KoiniStore store;
  final Mission mission;

  @override
  State<MissionQuizView> createState() => _MissionQuizViewState();
}

class _MissionQuizViewState extends State<MissionQuizView> {
  late final quiz = MissionQuizController(widget.store, widget.mission);

  @override
  void dispose() {
    quiz.dispose();
    super.dispose();
  }

  Future<void> next() async {
    final result = await quiz.next();
    if (!mounted || result == null) return;
    if (result.error != null) {
      note(context, result.error!);
      return;
    }
    final (:score, :awarded, error: _) = result;
    await openPage<void>(
      context,
      Celebration(
        header: 'Misi selesai',
        title: 'Kamu makin pintar!',
        message:
            '${widget.mission.name} · $score dari 5 benar pada percobaan pertama',
        button: 'Kembali ke misi',
        details: [
          KRow(
            '+$awarded bintang',
            'Total kamu sekarang ${widget.store.stars} bintang.',
            color: KColors.gold,
            icon: const Icon(Icons.star, color: KColors.gold, size: 37),
          ),
          const Gap(9),
          KCallout(
            'Streak ${widget.store.streak} hari',
            'Langkah kecil hari ini membuatmu makin siap mengatur uang saku.',
          ),
          const Gap(9),
          caption(
            'Bintang adalah poin belajar dan tidak dapat ditukar dengan uang.',
            align: TextAlign.center,
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: quiz, builder: buildPage);

  Widget buildPage(BuildContext context, Widget? child) {
    final question = quiz.question;
    final correctAnswer = quiz.correctAnswer;
    final selected = quiz.selected;
    final index = quiz.index;
    return KPage(
      leading: const KBack(),
      trailing: SizedBox(
        width: 218,
        child: Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GoalProgress(
                    1,
                    color: i <= index ? KColors.gold : KColors.line,
                  ),
                ),
              ),
            const SizedBox(width: 5),
            caption('${index + 1} dari 5'),
          ],
        ),
      ),
      footer: selected == null
          ? null
          : KButton(
              correctAnswer ? 'Lanjut' : 'Coba lagi',
              onTap: quiz.saving ? null : next,
            ),
      children: [
        KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              caption(
                'Soal cerita · ${widget.mission.name}',
                color: KColors.gold,
              ),
              const Gap(5),
              heading(question.story, size: 20),
            ],
          ),
        ),
        const Gap(14),
        for (var i = 0; i < question.options.length; i++) ...[
          KCard(
            bright: true,
            border: selected == i
                ? correctAnswer
                      ? KColors.gold
                      : KColors.error
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            onTap: selected == null ? () => quiz.answer(i) : null,
            child: Center(
              child: heading(
                question.options[i],
                size: 19,
                align: TextAlign.center,
              ),
            ),
          ),
          const Gap(8),
        ],
        if (selected == null)
          caption('Ketuk salah satu, ya.', align: TextAlign.center)
        else
          KCallout(
            correctAnswer
                ? 'Benar! ${question.options[question.correct]}'
                : 'Belum tepat.',
            correctAnswer
                ? question.explanation
                : 'Baca ceritanya sekali lagi dan coba pilihan lain.',
            color: correctAnswer ? KColors.mint : KColors.error,
          ),
      ],
    );
  }
}

@Preview(name: 'Kuis butuh atau mau', group: 'Misi', size: koiniPreviewSize)
Widget missionQuizPreview() => KoiniPreviewHost(
  page: (context, store) => MissionQuizView(
    store: store,
    mission: missions.firstWhere((mission) => mission.id == 'butuh'),
  ),
  returnPage: (context, store) =>
      ChildShell(store: store, initialTab: ChildTab.missions),
);
