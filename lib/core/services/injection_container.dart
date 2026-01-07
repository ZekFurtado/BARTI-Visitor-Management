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
import 'package:visitor_management/src/visitor/domain/usecases/register_visitor.dart';
import 'package:visitor_management/src/visitor/domain/usecases/update_visitor_status.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';

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
        registerVisitor: sl(),
        getVisitors: sl(),
        getVisitorsForEmployee: sl(),
        getVisitorsByStatus: sl(),
        updateVisitorStatus: sl(),
        remoteDataSource: sl(),
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
    ..registerLazySingleton(() => GetVisitorsByStatus(sl()))
    ..registerLazySingleton(() => UpdateVisitorStatus(sl()))
    /// REPOSITORIES
    /// Authentication
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl()),
    )
    /// Visitor Management
    ..registerLazySingleton<VisitorRepository>(
      () => VisitorRepositoryImpl(sl()),
    )
    /// DATA SOURCES
    /// Authentication
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl(), sl()),
    )
    /// Visitor Management
    ..registerLazySingleton<VisitorRemoteDataSource>(
      () => VisitorRemoteDataSourceImpl(
        firestore: sl(),
        storage: sl(),
        httpClient: sl(),
      ),
    )
    /// EXTERNAL DEPENDENCIES
    ..registerLazySingleton(http.Client.new)
    ..registerLazySingleton(() => sharedPreferences)
    /// Firebase
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton(() => GoogleSignIn());
}
