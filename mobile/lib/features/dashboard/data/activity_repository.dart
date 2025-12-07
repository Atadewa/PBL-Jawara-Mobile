import '../models/activity_model.dart';
import '../services/activity_service.dart';

/// Interface untuk activity repository
abstract class IActivityRepository {
  Future<ActivityDashboardData> getActivityDashboard();
  Future<ActivityDashboardData> refreshActivityDashboard();
}

/// Implementasi activity repository
class ActivityRepository implements IActivityRepository {
  final ActivityService _activityService;

  ActivityRepository({required ActivityService activityService})
    : _activityService = activityService;

  @override
  Future<ActivityDashboardData> getActivityDashboard() async {
    try {
      return await _activityService.getActivityDashboard();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<ActivityDashboardData> refreshActivityDashboard() async {
    try {
      return await _activityService.refreshActivityDashboard();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Handle different types of errors
  void _handleError(dynamic error) {
    if (error is Exception) {
      print('Activity Repository Error: $error');
    } else {
      print('Activity Repository Unknown Error: $error');
    }
  }
}
