import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor_profile.dart';
import '../../domain/usecases/visitor_profile_usecases.dart';

// Events
abstract class VisitorProfileEvent extends Equatable {
  const VisitorProfileEvent();

  @override
  List<Object> get props => [];
}

class GetVisitorProfileEvent extends VisitorProfileEvent {
  final String phoneNumber;

  const GetVisitorProfileEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class SearchVisitorsEvent extends VisitorProfileEvent {
  final String query;

  const SearchVisitorsEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class ClearSearchEvent extends VisitorProfileEvent {
  const ClearSearchEvent();
}

class CreateOrUpdateProfileEvent extends VisitorProfileEvent {
  final VisitorProfile profile;

  const CreateOrUpdateProfileEvent({required this.profile});

  @override
  List<Object> get props => [profile];
}

class AddVisitToProfileEvent extends VisitorProfileEvent {
  final String phoneNumber;
  final Visit visit;

  const AddVisitToProfileEvent({
    required this.phoneNumber,
    required this.visit,
  });

  @override
  List<Object> get props => [phoneNumber, visit];
}

// States
abstract class VisitorProfileState extends Equatable {
  const VisitorProfileState();

  @override
  List<Object> get props => [];
}

class VisitorProfileInitial extends VisitorProfileState {
  const VisitorProfileInitial();
}

class VisitorProfileLoading extends VisitorProfileState {
  const VisitorProfileLoading();
}

class VisitorProfileLoaded extends VisitorProfileState {
  final VisitorProfile? profile;

  const VisitorProfileLoaded({this.profile});

  @override
  List<Object> get props => [profile ?? 'null'];
}

class VisitorSearchResults extends VisitorProfileState {
  final List<VisitorProfile> results;
  final String query;

  const VisitorSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}

class VisitorProfileSuccess extends VisitorProfileState {
  final VisitorProfile profile;
  final String message;

  const VisitorProfileSuccess({
    required this.profile,
    required this.message,
  });

  @override
  List<Object> get props => [profile, message];
}

class VisitorProfileError extends VisitorProfileState {
  final String message;

  const VisitorProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class VisitorProfileBloc extends Bloc<VisitorProfileEvent, VisitorProfileState> {
  final GetVisitorProfile _getVisitorProfile;
  final SearchVisitors _searchVisitors;
  final CreateOrUpdateVisitorProfile _createOrUpdateProfile;
  final AddVisitToProfile _addVisitToProfile;

  VisitorProfileBloc({
    required GetVisitorProfile getVisitorProfile,
    required SearchVisitors searchVisitors,
    required CreateOrUpdateVisitorProfile createOrUpdateProfile,
    required AddVisitToProfile addVisitToProfile,
  })  : _getVisitorProfile = getVisitorProfile,
        _searchVisitors = searchVisitors,
        _createOrUpdateProfile = createOrUpdateProfile,
        _addVisitToProfile = addVisitToProfile,
        super(const VisitorProfileInitial()) {
    on<GetVisitorProfileEvent>(_onGetVisitorProfile);
    on<SearchVisitorsEvent>(_onSearchVisitors);
    on<ClearSearchEvent>(_onClearSearch);
    on<CreateOrUpdateProfileEvent>(_onCreateOrUpdateProfile);
    on<AddVisitToProfileEvent>(_onAddVisitToProfile);
  }

  Future<void> _onGetVisitorProfile(
    GetVisitorProfileEvent event,
    Emitter<VisitorProfileState> emit,
  ) async {
    emit(const VisitorProfileLoading());

    final result = await _getVisitorProfile(
      GetVisitorProfileParams(phoneNumber: event.phoneNumber),
    );

    result.fold(
      (failure) => emit(VisitorProfileError(message: failure.message)),
      (profile) => emit(VisitorProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onSearchVisitors(
    SearchVisitorsEvent event,
    Emitter<VisitorProfileState> emit,
  ) async {
    emit(const VisitorProfileLoading());

    final result = await _searchVisitors(
      SearchVisitorsParams(query: event.query),
    );

    result.fold(
      (failure) => emit(VisitorProfileError(message: failure.message)),
      (profiles) => emit(VisitorSearchResults(
        results: profiles,
        query: event.query,
      )),
    );
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<VisitorProfileState> emit,
  ) {
    emit(const VisitorProfileInitial());
  }

  Future<void> _onCreateOrUpdateProfile(
    CreateOrUpdateProfileEvent event,
    Emitter<VisitorProfileState> emit,
  ) async {
    emit(const VisitorProfileLoading());

    final result = await _createOrUpdateProfile(
      CreateOrUpdateVisitorProfileParams(visitorProfile: event.profile),
    );

    result.fold(
      (failure) => emit(VisitorProfileError(message: failure.message)),
      (profile) => emit(VisitorProfileSuccess(
        profile: profile,
        message: 'Visitor profile saved successfully',
      )),
    );
  }

  Future<void> _onAddVisitToProfile(
    AddVisitToProfileEvent event,
    Emitter<VisitorProfileState> emit,
  ) async {
    emit(const VisitorProfileLoading());

    final result = await _addVisitToProfile(
      AddVisitToProfileParams(
        phoneNumber: event.phoneNumber,
        visit: event.visit,
      ),
    );

    result.fold(
      (failure) => emit(VisitorProfileError(message: failure.message)),
      (profile) => emit(VisitorProfileSuccess(
        profile: profile,
        message: 'Visit added to visitor history',
      )),
    );
  }
}