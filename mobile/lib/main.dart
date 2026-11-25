import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/koini_app.dart';
import 'services/auth_service.dart';
import 'services/device_storage.dart';
import 'services/koini_store.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_config.dart';
import 'services/supabase_koini_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await initializeDateFormatting('id_ID');

  final supabaseReady = await SupabaseConfig.initializeIfConfigured();
  final AuthService? authService = supabaseReady
      ? SupabaseAuthService(Supabase.instance.client)
      : null;
  final KoiniRemoteRepository? remote = supabaseReady
      ? SupabaseKoiniRepository(Supabase.instance.client)
      : null;

  runApp(
    KoiniApp(
      store: KoiniStore(DeviceStorage(), remote: remote),
      authService: authService,
    ),
  );
}
