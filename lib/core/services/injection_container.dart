import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/src/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:visitor_management/src/authentication/data/repositories/auth_repository_impl.dart';
import 'package:visitor_management/src/authentication/domain/repositories/auth_repository.dart';
import 'package:visitor_management/src/authentication/domain/usecases/create_email_user.dart';
import 'package:visitor_management/src/authentication/domain/usecases/create_user_with_role.dart';
import 'package:visitor_management/src/authentication/domain/usecases/email_sign_in.dart';
import 'package:visitor_management/src/authentication/domain/usecases/get_user_session.dart';
import 'package:visitor_management/src/authentication/domain/usecases/sign_out.dart';
import 'package:visitor_management/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:visitor_management/src/visitor/data/datasources/visitor_remote_data_source.dart';
import 'package:visitor_management/src/visitor/data/repositories/visitor_repository_impl.dart';
import 'package:visitor_management/src/visitor/domain/repositories/visitor_repository.dart';
import 'package:visitor_management/src/visitor/domain/usecases/get_visitors.dart';
import 'package:visitor_management/src/visitor/domain/usecases/get_visitors_stream.dart';
import 'package:visitor_management/src/visitor/domain/usecases/get_visitor_history.dart';
import 'package:visitor_management/src/visitor/domain/usecases/register_visitor.dart';
import 'package:visitor_management/src/visitor/domain/usecases/update_visitor_status.dart';
import 'package:visitor_management/src/visitor/domain/usecases/visitor_profile_usecases.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_history_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_profile_bloc.dart';
import 'package:visitor_management/src/employee/data/datasources/employee_remote_data_source.dart';
import 'package:visitor_management/src/employee/data/repositories/employee_repository_impl.dart';
import 'package:visitor_management/src/employee/domain/repositories/employee_repository.dart';
import 'package:visitor_management/src/employee/domain/usecases/get_employees.dart';
import 'package:visitor_management/src/employee/presentation/bloc/employee_bloc.dart';
import 'package:visitor_management/src/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:visitor_management/src/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:visitor_management/src/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:visitor_management/src/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:visitor_management/src/dashboard/domain/usecases/get_dashboard_stats_stream.dart';
import 'package:visitor_management/src/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:visitor_management/src/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:visitor_management/src/notifications/presentation/bloc/notifications_bloc.dart';
import 'notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl
    /// APP LOGIC
    /// Authentication
    ..registerFactory(
      () => AuthenticationBloc(
        createUser: sl(),
        createUserWithRole: sl(),
        emailSignIn: sl(),
        getUserSession: sl(),
        signOutUser: sl(),
      ),
    )
    /// Visitor Management
    ..registerFactory(
      () => VisitorBloc(
        getVisitors: sl(),
        getVisitorsForEmployee: sl(),
        getVisitorsForEmployeeStream: sl(),
        getVisitorsByStatus: sl(),
        updateVisitorStatus: sl(),
        smartVisitorRegistration: sl(),
        remoteDataSource: sl(),
        notificationService: sl(),
      ),
    )
    /// Visitor History
    ..registerFactory(
      () => VisitorHistoryBloc(
        getVisitorHistory: sl(),
        getRecentVisitors: sl(),
        getVisitorsByDateRange: sl(),
      ),
    )
    /// Visitor Profile
    ..registerFactory(
      () => VisitorProfileBloc(
        getVisitorProfile: sl(),
        searchVisitors: sl(),
        createOrUpdateProfile: sl(),
        addVisitToProfile: sl(),
      ),
    )
    /// Employee Management
    ..registerFactory(
      () => EmployeeBloc(
        getAllEmployees: sl(),
        searchEmployees: sl(),
        getEmployeesByDepartment: sl(),
      ),
    )
    /// Dashboard Statistics
    ..registerFactory(
      () => DashboardBloc(
        getGatekeeperStats: sl(),
        getEmployeeStats: sl(),
        getGatekeeperStatsStream: sl(),
        getEmployeeStatsStream: sl(),
      ),
    )
    /// Notifications
    ..registerFactory(
      () => NotificationsBloc(
        dataSource: sl(),
      ),
    )
    /// USE CASES
    /// Authentication
    ..registerLazySingleton(() => CreateUser(sl()))
    ..registerLazySingleton(() => CreateUserWithRole(sl()))
    ..registerLazySingleton(() => EmailSignIn(sl()))
    ..registerLazySingleton(() => GetUserSession(sl()))
    ..registerLazySingleton(() => SignOutUseCase(sl()))
    /// Visitor Management
    ..registerLazySingleton(() => RegisterVisitor(sl()))
    ..registerLazySingleton(() => GetVisitors(sl()))
    ..registerLazySingleton(() => GetVisitorsForEmployee(sl()))
    ..registerLazySingleton(() => GetVisitorsForEmployeeStream(sl()))
    ..registerLazySingleton(() => GetVisitorsByStatus(sl()))
    ..registerLazySingleton(() => UpdateVisitorStatus(sl()))
    /// Visitor History
    ..registerLazySingleton(() => GetVisitorHistory(sl()))
    ..registerLazySingleton(() => GetRecentVisitors(sl()))
    ..registerLazySingleton(() => GetVisitorsByDateRange(sl()))
    /// Visitor Profile
    ..registerLazySingleton(() => GetVisitorProfile(sl()))
    ..registerLazySingleton(() => SearchVisitors(sl()))
    ..registerLazySingleton(() => CreateOrUpdateVisitorProfile(sl()))
    ..registerLazySingleton(() => AddVisitToProfile(sl()))
    ..registerLazySingleton(() => SmartVisitorRegistration(sl()))
    /// Employee Management
    ..registerLazySingleton(() => GetAllEmployees(sl()))
    ..registerLazySingleton(() => GetEmployeeById(sl()))
    ..registerLazySingleton(() => SearchEmployees(sl()))
    ..registerLazySingleton(() => GetEmployeesByDepartment(sl()))
    /// Dashboard Statistics
    ..registerLazySingleton(() => GetGatekeeperStats(sl()))
    ..registerLazySingleton(() => GetEmployeeStats(sl()))
    ..registerLazySingleton(() => GetGatekeeperStatsStream(sl()))
    ..registerLazySingleton(() => GetEmployeeStatsStream(sl()))
    ..registerLazySingleton(() => GetTodayVisitorCount(sl()))
    ..registerLazySingleton(() => GetPendingApprovalsCount(sl()))
    ..registerLazySingleton(() => GetTotalPendingApprovals(sl()))
    /// REPOSITORIES
    /// Authentication
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()),
    )
    /// Visitor Management
    ..registerLazySingleton<VisitorRepository>(
      () => VisitorRepositoryImpl(sl()),
    )
    /// Employee Management
    ..registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepositoryImpl(sl()),
    )
    /// Dashboard Statistics
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl()),
    )
    /// DATA SOURCES
    /// Authentication
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl(), sl(), sl()),
    )
    /// Visitor Management
    ..registerLazySingleton<VisitorRemoteDataSource>(
      () => VisitorRemoteDataSourceImpl(
        firestore: sl(),
        storage: sl(),
        httpClient: sl(),
      ),
    )
    /// Employee Management
    ..registerLazySingleton<EmployeeRemoteDataSource>(
      () => EmployeeRemoteDataSourceImpl(
        firestore: sl(),
      ),
    )
    /// Dashboard Statistics
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(
        firestore: sl(),
      ),
    )
    /// Notifications
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        firestore: sl(),
      ),
    )
    /// EXTERNAL DEPENDENCIES
    ..registerLazySingleton(http.Client.new)
    ..registerLazySingleton(() => sharedPreferences)
    /// Services
    ..registerLazySingleton(() => NotificationService())
    /// Firebase
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton(() => GoogleSignIn());
}
