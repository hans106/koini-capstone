import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/app/app_router.dart';
import 'package:koini/core/theme/koini_theme.dart';
import 'package:koini/core/widgets/koini_ui.dart';
import 'package:koini/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:koini/services/supabase_config.dart';

class AccountEntry extends ConsumerStatefulWidget {
  const AccountEntry({super.key, required this.signUp});

  final bool signUp;

  @override
  ConsumerState<AccountEntry> createState() => _AccountEntryState();
}

class _AccountEntryState extends ConsumerState<AccountEntry> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail(AuthViewModel model) async {
    if (widget.signUp) {
      await model.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        name: _nameController.text,
      );
    } else {
      await model.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    }
    if (mounted && ref.read(authViewModelProvider).signedIn) {
      continueAfterDemoAuth(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final model = ref.read(authViewModelProvider.notifier);
    final isLive = model.isLiveBackend;
    final signUp = widget.signUp;

    return KPage(
      leading: signUp ? KBack(onTap: () => returnToLogin(context)) : null,
      back: signUp,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLive) ...[
            if (SupabaseConfig.hasGoogleClientId) ...[
              KButton(
                signUp ? 'Daftar dengan Google' : 'Masuk dengan Google',
                white: true,
                onTap: state.busy
                    ? null
                    : () async {
                        await model.signInWithGoogle();
                        if (context.mounted &&
                            ref.read(authViewModelProvider).signedIn) {
                          continueAfterDemoAuth(context);
                        }
                      },
              ),
              const Gap(8),
            ],
            KButton(
              signUp ? 'Daftar dengan Email' : 'Masuk dengan Email',
              secondary: SupabaseConfig.hasGoogleClientId,
              white: !SupabaseConfig.hasGoogleClientId,
              onTap: state.busy ? null : () => _submitEmail(model),
            ),
          ] else
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
            isLive
                ? (signUp
                      ? 'Buat akun orang tua agar data tabungan anak tersimpan aman di Supabase.'
                      : 'Masuk dengan akun orang tua. Area pengawasan tetap dijaga PIN 6 digit.')
                : (signUp
                      ? 'Lanjutkan ke pengaturan profil anak, PIN, dan uang saku dalam mode demo.'
                      : 'Gunakan sesi demo di HP ini. Akses pengawasan orang tua memakai PIN 6 digit.'),
          ),
        ),
        if (isLive) ...[
          const Gap(12),
          if (signUp) ...[
            KField(
              'Nama Ayah/Bunda',
              _nameController,
              hint: 'Contoh: Bunda Raka',
              length: 60,
            ),
            const Gap(8),
          ],
          KField(
            'Email Ayah/Bunda',
            _emailController,
            email: true,
            hint: 'ayah.bunda@email.com',
          ),
          const Gap(8),
          KField(
            'Kata sandi (minimal 6 karakter)',
            _passwordController,
            secret: true,
            hint: 'Minimal 6 karakter',
          ),
        ],
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
