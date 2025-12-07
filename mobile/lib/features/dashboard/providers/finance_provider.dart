import 'package:flutter/material.dart';
import '../models/finance_model.dart';
import '../data/finance_repository.dart';

enum FinanceState { initial, loading, loaded, error }

class FinanceProvider extends ChangeNotifier {
  final IFinanceRepository _repository;

  FinanceState _state = FinanceState.initial;
  FinanceDashboardData? _data;
  String? _error;

  FinanceProvider({required IFinanceRepository repository})
    : _repository = repository;

  // Getters
  FinanceState get state => _state;
  FinanceDashboardData? get data => _data;
  String? get error => _error;

  bool get isLoading => _state == FinanceState.loading;
  bool get isLoaded => _state == FinanceState.loaded;
  bool get isError => _state == FinanceState.error;

  /// Load finance dashboard data
  Future<void> loadFinance() async {
    _state = FinanceState.loading;
    notifyListeners();

    try {
      _data = await _repository.getFinanceDashboard();
      _state = FinanceState.loaded;
      _error = null;
    } catch (e) {
      _state = FinanceState.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Refresh finance dashboard data
  Future<void> refreshFinance() async {
    try {
      _data = await _repository.refreshFinanceDashboard();
      _state = FinanceState.loaded;
      _error = null;
    } catch (e) {
      _state = FinanceState.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  /// Reset state
  void reset() {
    _state = FinanceState.initial;
    _data = null;
    _error = null;
    notifyListeners();
  }
}
