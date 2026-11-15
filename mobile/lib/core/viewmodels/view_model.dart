import 'package:flutter/foundation.dart';

abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  @protected
  void changed() {
    if (!_disposed) notifyListeners();
  }

  @protected
  void showError(String? message) {
    _error = message;
    changed();
  }

  @protected
  Future<bool> submit(Future<String?> Function() operation) async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    changed();
    try {
      _error = await operation();
      return _error == null;
    } finally {
      _busy = false;
      changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Observes the domain service for the lifetime of a screen.
abstract class StoreViewModel extends ViewModel {
  StoreViewModel(this._source) {
    _source.addListener(changed);
  }

  final Listenable _source;

  @override
  void dispose() {
    _source.removeListener(changed);
    super.dispose();
  }
}
