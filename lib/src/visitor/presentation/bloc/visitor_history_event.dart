part of 'visitor_history_bloc.dart';

/// Base event class for visitor history events
abstract class VisitorHistoryEvent extends Equatable {
  const VisitorHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get visitor history by phone number
class GetVisitorHistoryByPhoneEvent extends VisitorHistoryEvent {
  final String phoneNumber;

  const GetVisitorHistoryByPhoneEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

/// Event to get recent visitors (last 30 days)
class GetRecentVisitorsEvent extends VisitorHistoryEvent {
  const GetRecentVisitorsEvent();
}

/// Event to get visitors by date range
class GetVisitorsByDateRangeEvent extends VisitorHistoryEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GetVisitorsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

/// Event to clear visitor history
class ClearVisitorHistoryEvent extends VisitorHistoryEvent {
  const ClearVisitorHistoryEvent();
}