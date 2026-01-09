import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../entities/visitor_profile.dart';
import '../repositories/visitor_repository.dart';

/// Use case for getting visitor profile by phone number
class GetVisitorProfile extends UseCaseWithParams<VisitorProfile?, GetVisitorProfileParams> {
  final VisitorRepository repository;

  GetVisitorProfile(this.repository);

  @override
  ResultFuture<VisitorProfile?> call(GetVisitorProfileParams params) {
    return repository.getVisitorProfileByPhone(params.phoneNumber);
  }
}

/// Parameters for getting visitor profile by phone
class GetVisitorProfileParams extends Equatable {
  final String phoneNumber;

  const GetVisitorProfileParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

/// Use case for creating or updating visitor profile
class CreateOrUpdateVisitorProfile extends UseCaseWithParams<VisitorProfile, CreateOrUpdateVisitorProfileParams> {
  final VisitorRepository repository;

  CreateOrUpdateVisitorProfile(this.repository);

  @override
  ResultFuture<VisitorProfile> call(CreateOrUpdateVisitorProfileParams params) {
    return repository.createOrUpdateVisitorProfile(params.visitorProfile);
  }
}

/// Parameters for creating or updating visitor profile
class CreateOrUpdateVisitorProfileParams extends Equatable {
  final VisitorProfile visitorProfile;

  const CreateOrUpdateVisitorProfileParams({required this.visitorProfile});

  @override
  List<Object> get props => [visitorProfile];
}

/// Use case for adding a new visit to existing visitor profile
class AddVisitToProfile extends UseCaseWithParams<VisitorProfile, AddVisitToProfileParams> {
  final VisitorRepository repository;

  AddVisitToProfile(this.repository);

  @override
  ResultFuture<VisitorProfile> call(AddVisitToProfileParams params) {
    return repository.addVisitToProfile(params.phoneNumber, params.visit);
  }
}

/// Parameters for adding visit to profile
class AddVisitToProfileParams extends Equatable {
  final String phoneNumber;
  final Visit visit;

  const AddVisitToProfileParams({
    required this.phoneNumber,
    required this.visit,
  });

  @override
  List<Object> get props => [phoneNumber, visit];
}

/// Use case for searching visitors by name or phone
class SearchVisitors extends UseCaseWithParams<List<VisitorProfile>, SearchVisitorsParams> {
  final VisitorRepository repository;

  SearchVisitors(this.repository);

  @override
  ResultFuture<List<VisitorProfile>> call(SearchVisitorsParams params) {
    return repository.searchVisitors(params.query);
  }
}

/// Parameters for searching visitors
class SearchVisitorsParams extends Equatable {
  final String query;

  const SearchVisitorsParams({required this.query});

  @override
  List<Object> get props => [query];
}

/// Use case for registering a new visitor or adding visit to existing profile
class SmartVisitorRegistration extends UseCaseWithParams<VisitorProfile, SmartVisitorRegistrationParams> {
  final VisitorRepository repository;

  SmartVisitorRegistration(this.repository);

  @override
  ResultFuture<VisitorProfile> call(SmartVisitorRegistrationParams params) async {
    // First check if visitor profile exists
    final existingProfileResult = await repository.getVisitorProfileByPhone(params.visitor.phoneNumber ?? '');
    
    return existingProfileResult.fold(
      (failure) => Left(failure),
      (existingProfile) async {
        if (existingProfile != null) {
          // Visitor exists, add new visit to their profile
          final visit = Visit.fromVisitor(params.visitor);
          return await repository.addVisitToProfile(params.visitor.phoneNumber!, visit);
        } else {
          // New visitor, create new profile
          final newProfile = VisitorProfile.fromVisitor(params.visitor);
          return await repository.createOrUpdateVisitorProfile(newProfile);
        }
      },
    );
  }
}

/// Parameters for smart visitor registration
class SmartVisitorRegistrationParams extends Equatable {
  final Visitor visitor;

  const SmartVisitorRegistrationParams({required this.visitor});

  @override
  List<Object> get props => [visitor];
}