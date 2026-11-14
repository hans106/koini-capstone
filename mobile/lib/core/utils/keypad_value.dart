String keypadValue(String value, String key, int maxLength) {
  if (key == 'Hapus') {
    return value.isEmpty ? '' : value.substring(0, value.length - 1);
  }
  final result = '$value$key';
  return result.length > maxLength ? value : result;
}
