import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Use case for updating visitor status (approve/reject)
class UpdateVisitorStatus extends UseCaseWithParams<Visitor, UpdateVisitorStatusParams> {
  final VisitorRepository repository;

  UpdateVisitorStatus(this.repository);

  @override
  ResultFuture<Visitor> call(UpdateVisitorStatusParams params) {
    return repository.updateVisitorStatus(params.visitorId, params.status);
  }
}

/// Parameters for updating visitor status
class UpdateVisitorStatusParams extends Equatable {
  final String visitorId;
  final VisitorStatus status;

  const UpdateVisitorStatusParams({
    required this.visitorId,
    required this.status,
  });

  @override
  List<Object> get props => [visitorId, status];
}