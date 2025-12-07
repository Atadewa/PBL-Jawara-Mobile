import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/dashboard/services/dashboard_service.dart';
import '../../features/dashboard/services/finance_service.dart';
import '../../features/dashboard/services/activity_service.dart';
import '../../features/dashboard/services/population_service.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/dashboard/data/finance_repository.dart';
import '../../features/dashboard/data/activity_repository.dart';
import '../../features/dashboard/data/population_repository.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';
import '../../features/dashboard/providers/finance_provider.dart';
import '../../features/dashboard/providers/activity_provider.dart';
import '../../features/dashboard/providers/population_provider.dart';

/// List of all application providers
class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Dashboard dependencies
    Provider(create: (_) => DashboardService()),
    ProxyProvider<DashboardService, DashboardRepository>(
      update: (_, service, __) =>
          DashboardRepository(dashboardService: service),
    ),
    ChangeNotifierProxyProvider<DashboardRepository, DashboardProvider>(
      create: (context) {
        final service = context.read<DashboardService>();
        final repository = DashboardRepository(dashboardService: service);
        return DashboardProvider(repository: repository);
      },
      update: (_, repository, __) => DashboardProvider(repository: repository),
    ),

    // Finance dependencies
    Provider(create: (_) => FinanceService()),
    ProxyProvider<FinanceService, FinanceRepository>(
      update: (_, service, __) => FinanceRepository(financeService: service),
    ),
    ChangeNotifierProxyProvider<FinanceRepository, FinanceProvider>(
      create: (context) {
        final service = context.read<FinanceService>();
        final repository = FinanceRepository(financeService: service);
        return FinanceProvider(repository: repository);
      },
      update: (_, repository, __) => FinanceProvider(repository: repository),
    ),

    // Activity dependencies
    Provider(create: (_) => ActivityService()),
    ProxyProvider<ActivityService, ActivityRepository>(
      update: (_, service, __) => ActivityRepository(activityService: service),
    ),
    ChangeNotifierProxyProvider<ActivityRepository, ActivityProvider>(
      create: (context) {
        final service = context.read<ActivityService>();
        final repository = ActivityRepository(activityService: service);
        return ActivityProvider(repository: repository);
      },
      update: (_, repository, __) => ActivityProvider(repository: repository),
    ),

    // Population dependencies
    Provider(create: (_) => PopulationService()),
    ProxyProvider<PopulationService, PopulationRepository>(
      update: (_, service, __) =>
          PopulationRepository(populationService: service),
    ),
    ChangeNotifierProxyProvider<PopulationRepository, PopulationProvider>(
      create: (context) {
        final service = context.read<PopulationService>();
        final repository = PopulationRepository(populationService: service);
        return PopulationProvider(repository: repository);
      },
      update: (_, repository, __) => PopulationProvider(repository: repository),
    ),
  ];
}
