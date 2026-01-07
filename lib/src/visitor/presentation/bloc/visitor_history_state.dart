part of 'visitor_history_bloc.dart';

/// Base state class for visitor history states
abstract class VisitorHistoryState extends Equatable {
  const VisitorHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state for visitor history
class VisitorHistoryInitial extends VisitorHistoryState {
  const VisitorHistoryInitial();
}

/// Loading state for visitor history
class VisitorHistoryLoading extends VisitorHistoryState {
  const VisitorHistoryLoading();
}

/// State when visitor history is successfully loaded
class VisitorHistoryLoaded extends VisitorHistoryState {
  final List<Visitor> visitors;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const VisitorHistoryLoaded({
    required this.visitors,
    required this.searchQuery,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [visitors, searchQuery, startDate, endDate];

  /// Returns true if this is a phone number search
  bool get isPhoneSearch => searchQuery.contains(RegExp(r'^[\+]?[0-9]+$'));

  /// Returns true if this is a date range search
  bool get isDateRangeSearch => startDate != null && endDate != null;

  /// Returns formatted search description
  String get searchDescription {
    if (isPhoneSearch) {
      return 'History for $searchQuery';
    } else if (isDateRangeSearch) {
      return 'From ${_formatDate(startDate!)} to ${_formatDate(endDate!)}';
    } else {
      return searchQuery;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Error state for visitor history
class VisitorHistoryError extends VisitorHistoryState {
  final String message;

  const VisitorHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}