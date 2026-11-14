abstract interface class KoiniStorage {
  Future<String?> read();
  Future<void> write(String value);
}
