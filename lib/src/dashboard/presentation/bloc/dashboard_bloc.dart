import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats_stream.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// BLoC for managing dashboard functionality
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetGatekeeperStats _getGatekeeperStats;
  final GetEmployeeStats _getEmployeeStats;
  final GetGatekeeperStatsStream _getGatekeeperStatsStream;
  final GetEmployeeStatsStream _getEmployeeStatsStream;

  DashboardBloc({
    required GetGatekeeperStats getGatekeeperStats,
    required GetEmployeeStats getEmployeeStats,
    required GetGatekeeperStatsStream getGatekeeperStatsStream,
    required GetEmployeeStatsStream getEmployeeStatsStream,
  })  : _getGatekeeperStats = getGatekeeperStats,
        _getEmployeeStats = getEmployeeStats,
        _getGatekeeperStatsStream = getGatekeeperStatsStream,
        _getEmployeeStatsStream = getEmployeeStatsStream,
        super(const DashboardInitial()) {
    on<GetGatekeeperStatsEvent>(_onGetGatekeeperStats);
    on<GetEmployeeStatsEvent>(_onGetEmployeeStats);
    on<RefreshStatsEvent>(_onRefreshStats);
    on<SubscribeToGatekeeperStatsEvent>(_onSubscribeToGatekeeperStats);
    on<SubscribeToEmployeeStatsEvent>(_onSubscribeToEmployeeStats);
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

  Future<void> _onSubscribeToGatekeeperStats(
    SubscribeToGatekeeperStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    await emit.forEach<DashboardStats>(
      _getGatekeeperStatsStream(NoParams()),
      onData: (stats) => DashboardLoaded(
        stats: stats,
        userRole: 'gatekeeper',
      ),
      onError: (error, stackTrace) => DashboardError(
        message: error.toString(),
      ),
    );
  }

  Future<void> _onSubscribeToEmployeeStats(
    SubscribeToEmployeeStatsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    await emit.forEach<DashboardStats>(
      _getEmployeeStatsStream(GetEmployeeStatsStreamParams(employeeId: event.employeeId)),
      onData: (stats) => DashboardLoaded(
        stats: stats,
        userRole: 'employee',
        employeeId: event.employeeId,
      ),
      onError: (error, stackTrace) => DashboardError(
        message: error.toString(),
      ),
    );
  }
}