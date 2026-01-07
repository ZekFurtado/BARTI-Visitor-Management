import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// BLoC for managing dashboard functionality
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetGatekeeperStats _getGatekeeperStats;
  final GetEmployeeStats _getEmployeeStats;

  DashboardBloc({
    required GetGatekeeperStats getGatekeeperStats,
    required GetEmployeeStats getEmployeeStats,
  })  : _getGatekeeperStats = getGatekeeperStats,
        _getEmployeeStats = getEmployeeStats,
        super(const DashboardInitial()) {
    on<GetGatekeeperStatsEvent>(_onGetGatekeeperStats);
    on<GetEmployeeStatsEvent>(_onGetEmployeeStats);
    on<RefreshStatsEvent>(_onRefreshStats);
  }

  Future<void> _onGetGatekeeperStats(
    GetGatekeeperStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await _getGatekeeperStats();

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (stats) => emit(DashboardLoaded(
        stats: stats,
        userRole: 'gatekeeper',
      )),
    );
  }

  Future<void> _onGetEmployeeStats(
    GetEmployeeStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await _getEmployeeStats(
      GetEmployeeStatsParams(employeeId: event.employeeId),
    );

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (stats) => emit(DashboardLoaded(
        stats: stats,
        userRole: 'employee',
        employeeId: event.employeeId,
      )),
    );
  }

  Future<void> _onRefreshStats(
    RefreshStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      // Keep current data while refreshing
      emit(DashboardLoading());

      if (currentState.userRole == 'gatekeeper') {
        final result = await _getGatekeeperStats();
        result.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (stats) => emit(DashboardLoaded(
            stats: stats,
            userRole: 'gatekeeper',
          )),
        );
      } else if (currentState.employeeId != null) {
        final result = await _getEmployeeStats(
          GetEmployeeStatsParams(employeeId: currentState.employeeId!),
        );
        result.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (stats) => emit(DashboardLoaded(
            stats: stats,
            userRole: 'employee',
            employeeId: currentState.employeeId,
          )),
        );
      }
    }
  }
}