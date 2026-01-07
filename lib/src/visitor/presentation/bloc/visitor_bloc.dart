import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/usecases/register_visitor.dart';
import '../../domain/usecases/get_visitors.dart';
import '../../domain/usecases/update_visitor_status.dart';
import '../../../visitor/data/models/visitor_model.dart';
import '../../../visitor/data/datasources/visitor_remote_data_source.dart';

part 'visitor_event.dart';
part 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final RegisterVisitor _registerVisitor;
  final GetVisitors _getVisitors;
  final GetVisitorsForEmployee _getVisitorsForEmployee;
  final GetVisitorsByStatus _getVisitorsByStatus;
  final UpdateVisitorStatus _updateVisitorStatus;
  final VisitorRemoteDataSource _remoteDataSource;

  VisitorBloc({
    required RegisterVisitor registerVisitor,
    required GetVisitors getVisitors,
    required GetVisitorsForEmployee getVisitorsForEmployee,
    required GetVisitorsByStatus getVisitorsByStatus,
    required UpdateVisitorStatus updateVisitorStatus,
    required VisitorRemoteDataSource remoteDataSource,
  })  : _registerVisitor = registerVisitor,
        _getVisitors = getVisitors,
        _getVisitorsForEmployee = getVisitorsForEmployee,
        _getVisitorsByStatus = getVisitorsByStatus,
        _updateVisitorStatus = updateVisitorStatus,
        _remoteDataSource = remoteDataSource,
        super(VisitorInitial()) {
    on<RegisterVisitorEvent>(_onRegisterVisitor);
    on<GetAllVisitorsEvent>(_onGetAllVisitors);
    on<GetVisitorsForEmployeeEvent>(_onGetVisitorsForEmployee);
    on<GetVisitorsByStatusEvent>(_onGetVisitorsByStatus);
    on<UpdateVisitorStatusEvent>(_onUpdateVisitorStatus);
    on<UploadVisitorPhotoEvent>(_onUploadVisitorPhoto);
  }

  Future<void> _onRegisterVisitor(
    RegisterVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());

    try {
      // Create visitor model from the event data
      final visitor = VisitorModel(
        name: event.name,
        origin: event.origin,
        purpose: event.purpose,
        employeeToMeetId: event.employeeToMeetId,
        employeeToMeetName: event.employeeToMeetName,
        gatekeeperId: event.gatekeeperId,
        gatekeeperName: event.gatekeeperName,
        phoneNumber: event.phoneNumber,
        email: event.email,
        expectedDuration: event.expectedDuration,
        notes: event.notes,
        status: VisitorStatus.pending,
        createdAt: DateTime.now(),
      );

      // Register the visitor
      final registeredVisitor = await _remoteDataSource.registerVisitor(visitor);

      // Upload photo if provided
      String? photoUrl;
      if (event.photoFile != null && registeredVisitor.id != null) {
        photoUrl = await _remoteDataSource.uploadVisitorPhoto(
          registeredVisitor.id!,
          event.photoFile!,
        );

        // Update visitor with photo URL
        final updatedVisitor = registeredVisitor.copyWith(photoUrl: photoUrl);
        await _remoteDataSource.updateVisitor(updatedVisitor);
      }

      // Send notification to employee
      await _remoteDataSource.notifyEmployee(
        event.employeeToMeetId,
        registeredVisitor.id!,
        'New visitor request from ${event.name}',
      );

      emit(VisitorRegistered(registeredVisitor));
      log('Visitor registered successfully: ${registeredVisitor.id}');
    } catch (e) {
      emit(VisitorError('Failed to register visitor: ${e.toString()}'));
      log('Error registering visitor: $e');
    }
  }

  Future<void> _onGetAllVisitors(
    GetAllVisitorsEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());

    final result = await _getVisitors();
    result.fold(
      (failure) => emit(VisitorError(failure.message)),
      (visitors) => emit(VisitorsLoaded(visitors)),
    );
  }

  Future<void> _onGetVisitorsForEmployee(
    GetVisitorsForEmployeeEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());

    final result = await _getVisitorsForEmployee(
      GetVisitorsForEmployeeParams(employeeId: event.employeeId),
    );
    result.fold(
      (failure) => emit(VisitorError(failure.message)),
      (visitors) => emit(VisitorsLoaded(visitors)),
    );
  }

  Future<void> _onGetVisitorsByStatus(
    GetVisitorsByStatusEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());

    final result = await _getVisitorsByStatus(
      GetVisitorsByStatusParams(status: event.status),
    );
    result.fold(
      (failure) => emit(VisitorError(failure.message)),
      (visitors) => emit(VisitorsLoaded(visitors)),
    );
  }

  Future<void> _onUpdateVisitorStatus(
    UpdateVisitorStatusEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());

    final result = await _updateVisitorStatus(
      UpdateVisitorStatusParams(
        visitorId: event.visitorId,
        status: event.status,
      ),
    );
    result.fold(
      (failure) => emit(VisitorError(failure.message)),
      (visitor) => emit(VisitorStatusUpdated(visitor)),
    );
  }

  Future<void> _onUploadVisitorPhoto(
    UploadVisitorPhotoEvent event,
    Emitter<VisitorState> emit,
  ) async {
    try {
      emit(VisitorPhotoUploading());
      
      final photoUrl = await _remoteDataSource.uploadVisitorPhoto(
        event.visitorId,
        event.photoFile,
      );
      
      emit(VisitorPhotoUploaded(photoUrl));
    } catch (e) {
      emit(VisitorError('Failed to upload photo: ${e.toString()}'));
    }
  }
}