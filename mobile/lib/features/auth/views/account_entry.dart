import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/auth/viewmodels/auth_viewmodel.dart';

class AccountEntry extends ConsumerWidget {
  const AccountEntry({super.key, required this.signUp});

  final bool signUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);
    final model = ref.read(authViewModelProvider.notifier);
    return KPage(
      leading: signUp ? KBack(onTap: () => returnToLogin(context)) : null,
      back: signUp,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KButton(
            signUp ? 'Daftar dalam mode demo' : 'Masuk dalam mode demo',
            white: true,
            onTap: state.busy
                ? null
                : () async {
                    await (signUp ? model.signUp() : model.signIn());
                    if (context.mounted &&
                        ref.read(authViewModelProvider).signedIn) {
                      continueAfterDemoAuth(context);
                    }
                  },
          ),
          const Gap(4),
          TextButton(
            onPressed: state.busy
                ? null
                : () => signUp
                      ? returnToLogin(context)
                      : openPage(context, KRoute.signUp),
            child: Text(
              signUp ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar',
            ),
          ),
        ],
      ),
      children: [
        const Align(alignment: Alignment.centerRight, child: Mascot(size: 96)),
        heading(
          signUp ? 'Daftar untuk Ayah/Bunda' : 'Untuk Ayah/Bunda',
          size: 28,
        ),
        const Gap(6),
        Text(
          signUp ? 'Siapkan Koini untuk anak.' : 'Masuk untuk mengawasi Koini.',
        ),
        const Gap(13),
        KCard(
          child: Text(
            signUp
                ? 'Lanjutkan ke pengaturan profil anak, PIN, dan uang saku dalam mode demo.'
                : 'Gunakan sesi demo di HP ini. Akses pengawasan orang tua memakai PIN 6 digit.',
          ),
        ),
        const Gap(),
        const Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            Pill('Hanya mencatat', color: KColors.mint),
            Pill('Tanpa iklan', color: KColors.mint),
            Pill('Tanpa uang sungguhan', color: KColors.mint),
          ],
        ),
        if (state.error case final error?) ...[
          const Gap(),
          Text(error, style: const TextStyle(color: KColors.error)),
        ],
        if (!signUp)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => openPage(context, KRoute.welcome),
              child: const Text('Kenali Koini'),
            ),
          ),
      ],
    );
  }
}
