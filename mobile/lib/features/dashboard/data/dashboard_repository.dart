import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

/// Abstract interface untuk DashboardRepository
/// Ini memungkinkan mudah testing dengan mock dan switching data source
abstract class IDashboardRepository {
  Future<DashboardData> getDashboardData();
  Future<DashboardData> refreshDashboardData();
}

/// Concrete implementation dari IDashboardRepository
class DashboardRepository implements IDashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository({DashboardService? dashboardService})
    : _dashboardService = dashboardService ?? DashboardService();

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      return await _dashboardService.getDashboardData();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<DashboardData> refreshDashboardData() async {
    try {
      return await _dashboardService.refreshDashboardData();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle dan normalize error dari service
  /// TODO: Map error ke custom exception types untuk better error handling
  Exception _handleError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    return Exception('Unknown error occurred: $error');
  }
}
