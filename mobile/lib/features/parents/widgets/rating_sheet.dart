import 'package:flutter/material.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/services/koini_store.dart';

Future<void> rate(BuildContext context, KoiniStore store) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (sheet) {
        var rating = store.rating;
        var busy = false;
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: KCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  heading('Beri nilai Koini', color: KColors.gold),
                  caption('Bantu kami menjadi lebih baik.'),
                  const Gap(12),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        Expanded(
                          child: IconButton(
                            tooltip: 'Beri nilai $i',
                            onPressed: busy
                                ? null
                                : () => setState(() => rating = i),
                            icon: Icon(
                              Icons.star_rounded,
                              color: i <= rating ? KColors.gold : KColors.line,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(12),
                  KButton(
                    'Kirim nilai',
                    onTap: rating == 0 || busy
                        ? null
                        : () async {
                            setState(() => busy = true);
                            final error = await store.settings(rating: rating);
                            if (!context.mounted) return;
                            if (error == null) {
                              Navigator.pop(sheet);
                            } else {
                              setState(() => busy = false);
                              note(context, error);
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
