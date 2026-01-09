import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/get_employees.dart';

// Events
abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object> get props => [];
}

class GetAllEmployeesEvent extends EmployeeEvent {
  const GetAllEmployeesEvent();
}

class SearchEmployeesEvent extends EmployeeEvent {
  final String query;

  const SearchEmployeesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class GetEmployeesByDepartmentEvent extends EmployeeEvent {
  final String department;

  const GetEmployeesByDepartmentEvent({required this.department});

  @override
  List<Object> get props => [department];
}

class ClearEmployeeSearchEvent extends EmployeeEvent {
  const ClearEmployeeSearchEvent();
}

// States
abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeesLoaded extends EmployeeState {
  final List<Employee> employees;

  const EmployeesLoaded({required this.employees});

  @override
  List<Object> get props => [employees];
}

class EmployeeSearchResults extends EmployeeState {
  final List<Employee> results;
  final String query;

  const EmployeeSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetAllEmployees _getAllEmployees;
  final SearchEmployees _searchEmployees;
  final GetEmployeesByDepartment _getEmployeesByDepartment;

  EmployeeBloc({
    required GetAllEmployees getAllEmployees,
    required SearchEmployees searchEmployees,
    required GetEmployeesByDepartment getEmployeesByDepartment,
  })  : _getAllEmployees = getAllEmployees,
        _searchEmployees = searchEmployees,
        _getEmployeesByDepartment = getEmployeesByDepartment,
        super(const EmployeeInitial()) {
    on<GetAllEmployeesEvent>(_onGetAllEmployees);
    on<SearchEmployeesEvent>(_onSearchEmployees);
    on<GetEmployeesByDepartmentEvent>(_onGetEmployeesByDepartment);
    on<ClearEmployeeSearchEvent>(_onClearEmployeeSearch);
  }

  Future<void> _onGetAllEmployees(
    GetAllEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());

    final result = await _getAllEmployees();

    result.fold(
      (failure) => emit(EmployeeError(message: failure.message)),
      (employees) => emit(EmployeesLoaded(employees: employees)),
    );
  }

  Future<void> _onSearchEmployees(
    SearchEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());

    final result = await _searchEmployees(
      SearchEmployeesParams(query: event.query),
    );

    result.fold(
      (failure) => emit(EmployeeError(message: failure.message)),
      (employees) => emit(EmployeeSearchResults(
        results: employees,
        query: event.query,
      )),
    );
  }

  Future<void> _onGetEmployeesByDepartment(
    GetEmployeesByDepartmentEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());

    final result = await _getEmployeesByDepartment(
      GetEmployeesByDepartmentParams(department: event.department),
    );

    result.fold(
      (failure) => emit(EmployeeError(message: failure.message)),
      (employees) => emit(EmployeesLoaded(employees: employees)),
    );
  }

  void _onClearEmployeeSearch(
    ClearEmployeeSearchEvent event,
    Emitter<EmployeeState> emit,
  ) {
    emit(const EmployeeInitial());
  }
}