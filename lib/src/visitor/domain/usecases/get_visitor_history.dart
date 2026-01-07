import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Use case for getting visitor history by phone number
class GetVisitorHistory extends UseCaseWithParams<List<Visitor>, GetVisitorHistoryParams> {
  final VisitorRepository repository;

  GetVisitorHistory(this.repository);

  @override
  ResultFuture<List<Visitor>> call(GetVisitorHistoryParams params) {
    return repository.getVisitorHistoryByPhone(params.phoneNumber);
  }
}

/// Parameters for getting visitor history by phone
class GetVisitorHistoryParams extends Equatable {
  final String phoneNumber;

  const GetVisitorHistoryParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

/// Use case for getting recent visitors
class GetRecentVisitors extends UseCaseWithoutParams<List<Visitor>> {
  final VisitorRepository repository;

  GetRecentVisitors(this.repository);

  @override
  ResultFuture<List<Visitor>> call() {
    return repository.getRecentVisitors();
  }
}

/// Use case for getting visitors by date range
class GetVisitorsByDateRange extends UseCaseWithParams<List<Visitor>, GetVisitorsByDateRangeParams> {
  final VisitorRepository repository;

  GetVisitorsByDateRange(this.repository);

  @override
  ResultFuture<List<Visitor>> call(GetVisitorsByDateRangeParams params) {
    return repository.getVisitorsByDateRange(params.startDate, params.endDate);
  }
}

/// Parameters for getting visitors by date range
class GetVisitorsByDateRangeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetVisitorsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}