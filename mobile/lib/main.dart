import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/koini_app.dart';
import 'services/device_storage.dart';
import 'services/koini_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(KoiniApp(store: KoiniStore(DeviceStorage())));
}
