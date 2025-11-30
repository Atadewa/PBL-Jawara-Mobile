import 'package:flutter/material.dart';
import '../models/population_model.dart';
import '../data/population_repository.dart';

/// Enum untuk state management
enum PopulationState { initial, loading, loaded, error }

/// Provider untuk Population Dashboard menggunakan ChangeNotifier
class PopulationProvider extends ChangeNotifier {
  final PopulationRepository _repository;

  // State variables
  PopulationState _state = PopulationState.initial;
  PopulationDashboardData? _data;
  String _error = '';

  PopulationProvider({required PopulationRepository repository})
    : _repository = repository;

  // Getters
  PopulationState get state => _state;
  PopulationDashboardData? get data => _data;
  String get error => _error;

  bool get isLoading => _state == PopulationState.loading;
  bool get isLoaded => _state == PopulationState.loaded;
  bool get isError => _state == PopulationState.error;

  /// Load population dashboard data
  Future<void> loadPopulationDashboard() async {
    if (_state == PopulationState.loading) return;

    _state = PopulationState.loading;
    _error = '';
    notifyListeners();

    try {
      _data = await _repository.getPopulationDashboard();
      _state = PopulationState.loaded;
      _error = '';
    } catch (e) {
      _state = PopulationState.error;
      _error = e.toString();
      _data = null;
    }

    notifyListeners();
  }

  /// Refresh population dashboard data
  Future<void> refreshPopulationDashboard() async {
    await loadPopulationDashboard();
  }
}
