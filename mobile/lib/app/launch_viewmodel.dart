import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koini/core/providers/app_providers.dart';

final launchProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.watch(koiniStoreProvider).load(),
    Future<void>.delayed(const Duration(milliseconds: 850)),
  ]);
}, retry: (_, _) => null);
