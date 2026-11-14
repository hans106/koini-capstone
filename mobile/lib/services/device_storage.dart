import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:koini/services/koini_storage.dart';

class DeviceStorage implements KoiniStorage {
  static const _key = 'koini-local-v1';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}
