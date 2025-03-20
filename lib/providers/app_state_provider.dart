import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool _isSyncing = false;

  AppStateProvider() {
    _initConnectivityListener();
  }

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  void _initConnectivityListener() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((result) => result != ConnectivityResult.none);

      // If we just came back online, trigger sync
      if (!wasOnline && _isOnline) {
        syncData();
      }

      notifyListeners();
    });
  }

  Future<void> syncData() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // Sync local data with remote
      // This would call various repository sync methods
      await Future.delayed(Duration(seconds: 2)); // Simulate sync
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
