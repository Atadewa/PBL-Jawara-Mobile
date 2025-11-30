import '../models/finance_model.dart';
import '../services/finance_service.dart';

/// Interface untuk finance repository
abstract class IFinanceRepository {
  Future<FinanceDashboardData> getFinanceDashboard();
  Future<FinanceDashboardData> refreshFinanceDashboard();
}

/// Implementasi finance repository
class FinanceRepository implements IFinanceRepository {
  final FinanceService _financeService;

  FinanceRepository({required FinanceService financeService})
    : _financeService = financeService;

  @override
  Future<FinanceDashboardData> getFinanceDashboard() async {
    try {
      return await _financeService.getFinanceDashboard();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<FinanceDashboardData> refreshFinanceDashboard() async {
    try {
      return await _financeService.refreshFinanceDashboard();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Handle different types of errors
  void _handleError(dynamic error) {
    if (error is Exception) {
      print('Finance Repository Error: $error');
    } else {
      print('Finance Repository Unknown Error: $error');
    }
  }
}
