import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../data/dashboard_repository.dart';

/// State untuk dashboard
enum DashboardState { initial, loading, loaded, error }

/// Provider untuk dashboard - menggunakan ChangeNotifier
///
/// Best practices:
/// - Pisahkan UI logic dari business logic
/// - Gunakan enum untuk state management yang lebih type-safe
/// - Implementasikan error handling yang robust
/// - Support refresh/retry functionality

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardState _state = DashboardState.initial;
  DashboardData? _data;
  String? _error;

  DashboardState get state => _state;
  DashboardData? get data => _data;
  String? get error => _error;

  bool get isLoading => _state == DashboardState.loading;
  bool get isError => _state == DashboardState.error;
  bool get isLoaded => _state == DashboardState.loaded;

  DashboardProvider({required DashboardRepository repository})
    : _repository = repository;

  /// Load dashboard data
  Future<void> loadDashboard() async {
    _setLoading();
    try {
      _data = await _repository.getDashboardData();
      _setLoaded();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      _data = await _repository.refreshDashboardData();
      _setLoaded();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Set state to loading
  void _setLoading() {
    _state = DashboardState.loading;
    _error = null;
    notifyListeners();
  }

  /// Set state to loaded
  void _setLoaded() {
    _state = DashboardState.loaded;
    _error = null;
    notifyListeners();
  }

  /// Set state to error
  void _setError(String error) {
    _state = DashboardState.error;
    _error = error;
    _data = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
