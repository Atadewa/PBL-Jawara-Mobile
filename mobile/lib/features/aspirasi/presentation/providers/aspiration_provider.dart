import 'package:flutter/foundation.dart';
import 'package:mobile/features/aspirasi/data/models/aspirasi_model.dart';
import 'package:mobile/features/aspirasi/data/services/aspiration_api_service.dart';

/// Provider for managing aspiration state
class AspirationProvider extends ChangeNotifier {
  final AspirationApiService _apiService = AspirationApiService();

  List<AspirationModel> _items = [];
  bool _loading = false;
  String? _error;

  List<AspirationModel> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  /// Fetch all aspirations (scoped by backend based on roles)
  Future<void> fetchList() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _apiService.list();
      _loading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh list
  Future<void> refresh() async {
    await fetchList();
  }

  /// Get single aspiration by ID (from local cache or fetch from API)
  AspirationModel? getById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch single aspiration from API
  Future<AspirationModel> fetchById(int id) async {
    try {
      final item = await _apiService.getById(id);

      // Update in local cache
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }

      return item;
    } catch (e) {
      rethrow;
    }
  }

  /// Create new aspiration (warga-only)
  Future<AspirationModel> createAspiration({
    required String title,
    required String description,
    String? category,
  }) async {
    try {
      final newItem = await _apiService.create(
        title: title,
        description: description,
        category: category,
      );

      // Add to list
      _items.insert(0, newItem);
      notifyListeners();

      return newItem;
    } catch (e) {
      rethrow;
    }
  }

  /// Update my aspiration content (warga-only)
  Future<AspirationModel> updateMyAspiration({
    required int id,
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final updated = await _apiService.updateMy(
        id: id,
        title: title,
        description: description,
        category: category,
      );

      // Update in list
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = updated;
        notifyListeners();
      }

      return updated;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete my aspiration (warga-only)
  Future<void> deleteMyAspiration(int id) async {
    try {
      await _apiService.deleteMy(id);

      // Remove from list
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Moderate aspiration status (moderator-only)
  Future<AspirationModel> moderateStatus({
    required int id,
    required AspirationStatus status,
    String? decisionNote,
  }) async {
    try {
      final updated = await _apiService.updateStatus(
        id: id,
        status: status.value,
        decisionNote: decisionNote,
      );

      // Update in list
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = updated;
        notifyListeners();
      }

      return updated;
    } catch (e) {
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
