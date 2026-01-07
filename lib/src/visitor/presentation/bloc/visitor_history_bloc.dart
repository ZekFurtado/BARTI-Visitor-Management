import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/usecases/get_visitor_history.dart';

part 'visitor_history_event.dart';
part 'visitor_history_state.dart';

/// BLoC for managing visitor history functionality
class VisitorHistoryBloc extends Bloc<VisitorHistoryEvent, VisitorHistoryState> {
  final GetVisitorHistory _getVisitorHistory;
  final GetRecentVisitors _getRecentVisitors;
  final GetVisitorsByDateRange _getVisitorsByDateRange;

  VisitorHistoryBloc({
    required GetVisitorHistory getVisitorHistory,
    required GetRecentVisitors getRecentVisitors,
    required GetVisitorsByDateRange getVisitorsByDateRange,
  })  : _getVisitorHistory = getVisitorHistory,
        _getRecentVisitors = getRecentVisitors,
        _getVisitorsByDateRange = getVisitorsByDateRange,
        super(const VisitorHistoryInitial()) {
    on<GetVisitorHistoryByPhoneEvent>(_onGetVisitorHistoryByPhone);
    on<GetRecentVisitorsEvent>(_onGetRecentVisitors);
    on<GetVisitorsByDateRangeEvent>(_onGetVisitorsByDateRange);
    on<ClearVisitorHistoryEvent>(_onClearVisitorHistory);
  }

  Future<void> _onGetVisitorHistoryByPhone(
    GetVisitorHistoryByPhoneEvent event,
    Emitter<VisitorHistoryState> emit,
  ) async {
    emit(const VisitorHistoryLoading());

    final result = await _getVisitorHistory(
      GetVisitorHistoryParams(phoneNumber: event.phoneNumber),
    );

    result.fold(
      (failure) => emit(VisitorHistoryError(message: failure.message)),
      (visitors) => emit(VisitorHistoryLoaded(
        visitors: visitors,
        searchQuery: event.phoneNumber,
      )),
    );
  }

  Future<void> _onGetRecentVisitors(
    GetRecentVisitorsEvent event,
    Emitter<VisitorHistoryState> emit,
  ) async {
    emit(const VisitorHistoryLoading());

    final result = await _getRecentVisitors();

    result.fold(
      (failure) => emit(VisitorHistoryError(message: failure.message)),
      (visitors) => emit(VisitorHistoryLoaded(
        visitors: visitors,
        searchQuery: 'Recent visits (last 30 days)',
      )),
    );
  }

  Future<void> _onGetVisitorsByDateRange(
    GetVisitorsByDateRangeEvent event,
    Emitter<VisitorHistoryState> emit,
  ) async {
    emit(const VisitorHistoryLoading());

    final result = await _getVisitorsByDateRange(
      GetVisitorsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(VisitorHistoryError(message: failure.message)),
      (visitors) => emit(VisitorHistoryLoaded(
        visitors: visitors,
        searchQuery: 'Custom date range',
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  void _onClearVisitorHistory(
    ClearVisitorHistoryEvent event,
    Emitter<VisitorHistoryState> emit,
  ) {
    emit(const VisitorHistoryInitial());
  }
}