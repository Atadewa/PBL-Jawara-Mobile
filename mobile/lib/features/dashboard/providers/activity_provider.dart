import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../data/activity_repository.dart';

enum ActivityState { initial, loading, loaded, error }

class ActivityProvider extends ChangeNotifier {
  final IActivityRepository _repository;

  ActivityState _state = ActivityState.initial;
  ActivityDashboardData? _data;
  String? _error;

  ActivityProvider({required IActivityRepository repository})
    : _repository = repository;

  // Getters
  ActivityState get state => _state;
  ActivityDashboardData? get data => _data;
  String? get error => _error;

  bool get isLoading => _state == ActivityState.loading;
  bool get isLoaded => _state == ActivityState.loaded;
  bool get isError => _state == ActivityState.error;

  /// Load activity dashboard data
  Future<void> loadActivity() async {
    _state = ActivityState.loading;
    notifyListeners();

    try {
      _data = await _repository.getActivityDashboard();
      _state = ActivityState.loaded;
      _error = null;
    } catch (e) {
      _state = ActivityState.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Refresh activity dashboard data
  Future<void> refreshActivity() async {
    try {
      _data = await _repository.refreshActivityDashboard();
      _state = ActivityState.loaded;
      _error = null;
    } catch (e) {
      _state = ActivityState.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = ActivityState.initial;
    _data = null;
    _error = null;
    notifyListeners();
  }
}
