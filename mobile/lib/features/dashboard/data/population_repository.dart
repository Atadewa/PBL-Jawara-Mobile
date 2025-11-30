import '../models/population_model.dart';
import '../services/population_service.dart';

/// Abstract repository untuk Population Dashboard
abstract class IPopulationRepository {
  Future<PopulationDashboardData> getPopulationDashboard();
}

/// Implementasi repository dengan error handling
class PopulationRepository implements IPopulationRepository {
  final PopulationService _populationService;

  PopulationRepository({required PopulationService populationService})
    : _populationService = populationService;

  @override
  Future<PopulationDashboardData> getPopulationDashboard() async {
    try {
      print('[PopulationRepository] Fetching population dashboard data...');
      final data = await _populationService.getPopulationDashboard();
      print('[PopulationRepository] Successfully loaded population data');
      return data;
    } catch (e) {
      print('[PopulationRepository] Error: $e');

      // Provide specific error messages based on error type
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        throw Exception(
          'Request timeout. Please check your connection and try again.',
        );
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid data format received from server.');
      } else {
        throw Exception('Failed to load population data. Error: $e');
      }
    }
  }
}
