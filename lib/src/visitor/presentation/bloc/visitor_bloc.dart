import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_profile.dart';
import '../../domain/usecases/get_visitors.dart';
import '../../domain/usecases/get_visitors_stream.dart';
import '../../domain/usecases/update_visitor_status.dart';
import '../../domain/usecases/visitor_profile_usecases.dart';
import '../../../visitor/data/models/visitor_model.dart';
import '../../../visitor/data/datasources/visitor_remote_data_source.dart';
import '../../../../core/services/notification_service.dart';

part 'visitor_event.dart';
part 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final GetVisitors _getVisitors;
  final GetVisitorsForEmployee _getVisitorsForEmployee;
  final GetVisitorsForEmployeeStream _getVisitorsForEmployeeStream;
  final GetVisitorsByStatus _getVisitorsByStatus;
  final UpdateVisitorStatus _updateVisitorStatus;
  final SmartVisitorRegistration _smartVisitorRegistration;
  final VisitorRemoteDataSource _remoteDataSource;
  final NotificationService _notificationService;

  VisitorBloc({
    required GetVisitors getVisitors,
    required GetVisitorsForEmployee getVisitorsForEmployee,
    required GetVisitorsForEmployeeStream getVisitorsForEmployeeStream,
    required GetVisitorsByStatus getVisitorsByStatus,
    required UpdateVisitorStatus updateVisitorStatus,
    required SmartVisitorRegistration smartVisitorRegistration,
    required VisitorRemoteDataSource remoteDataSource,
    required NotificationService notificationService,
  })  : _getVisitors = getVisitors,
        _getVisitorsForEmployee = getVisitorsForEmployee,
        _getVisitorsForEmployeeStream = getVisitorsForEmployeeStream,
        _getVisitorsByStatus = getVisitorsByStatus,
        _updateVisitorStatus = updateVisitorStatus,
        _smartVisitorRegistration = smartVisitorRegistration,
        _remoteDataSource = remoteDataSource,
        _notificationService = notificationService,
        super(VisitorInitial()) {
    on<RegisterVisitorEvent>(_onRegisterVisitor);
    on<SmartRegisterVisitorEvent>(_onSmartRegisterVisitor);
    on<GetAllVisitorsEvent>(_onGetAllVisitors);
    on<GetVisitorsForEmployeeEvent>(_onGetVisitorsForEmployee);
    on<SubscribeToVisitorsForEmployeeEvent>(_onSubscribeToVisitorsForEmployee);
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
    
    await result.fold(
      (failure) async => emit(VisitorError(failure.message)),
      (visitor) async {
        // Check if emitter is still active before proceeding
        if (emit.isDone) return;
        
        // Send notification to gatekeeper about status update
        try {
          final isApproved = event.status == VisitorStatus.approved;
          if (isApproved) {
            await _notificationService.sendVisitorApprovalNotification(
              gatekeeperId: visitor.gatekeeperId,
              visitorName: visitor.name,
              employeeName: visitor.employeeToMeetName,
              visitorId: visitor.id,
            );
            log('✅ Approval notification sent to gatekeeper: ${visitor.gatekeeperName}');
          } else {
            await _notificationService.sendVisitorRejectionNotification(
              gatekeeperId: visitor.gatekeeperId,
              visitorName: visitor.name,
              employeeName: visitor.employeeToMeetName,
              visitorId: visitor.id,
            );
            log('✅ Rejection notification sent to gatekeeper: ${visitor.gatekeeperName}');
          }
        } catch (e) {
          log('❌ Failed to send status notification to gatekeeper: $e');
        }
        
        // Check again before emitting to ensure event handler hasn't completed
        if (!emit.isDone) {
          emit(VisitorStatusUpdated(visitor));
        }
      },
    );
  }

  Future<void> _onSubscribeToVisitorsForEmployee(
    SubscribeToVisitorsForEmployeeEvent event,
    Emitter<VisitorState> emit,
  ) async {
    log('🎯 Starting visitor stream subscription for employee: ${event.employeeId}');
    
    await emit.forEach(
      _getVisitorsForEmployeeStream(
        GetVisitorsForEmployeeStreamParams(employeeId: event.employeeId),
      ),
      onData: (visitors) {
        log('📡 Stream data received: ${visitors.length} visitors for employee ${event.employeeId}');
        for (final visitor in visitors) {
          log('  - ${visitor.name} (Status: ${visitor.status}, Employee: ${visitor.employeeToMeetId})');
        }
        return VisitorsLoaded(visitors);
      },
      onError: (error, stackTrace) {
        log('❌ Stream error for employee ${event.employeeId}: $error');
        log('Stack trace: $stackTrace');
        return VisitorError(error.toString());
      },
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

  Future<void> _onSmartRegisterVisitor(
    SmartRegisterVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());
    
    try {
      // Create visitor entity from the event data
      final visitor = Visitor(
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

      // Use smart registration to handle visitor profiles
      final result = await _smartVisitorRegistration(
        SmartVisitorRegistrationParams(visitor: visitor),
      );

      await result.fold(
        (failure) async => emit(VisitorError(failure.message)),
        (visitorProfile) async {
          // Check if emitter is still active
          if (emit.isDone) return;
          
          // Upload photo if provided
          if (event.photoFile != null && visitorProfile.id != null) {
            _uploadPhotoForProfile(visitorProfile.id!, event.photoFile!);
          }
          
          // Send notification to employee
          try {
            log('🔔 Attempting to send notification to employee: ${event.employeeToMeetId}');
            
            // Debug notification system first
            await _notificationService.debugNotificationSystem(event.employeeToMeetId);
            
            // Get the latest visit ID safely
            String? latestVisitId;
            if (visitorProfile.visits.isNotEmpty) {
              final sortedVisits = visitorProfile.visits.toList()
                ..sort((a, b) => b.visitDate.compareTo(a.visitDate));
              latestVisitId = sortedVisits.first.id;
            }
            
            final notificationSent = await _notificationService.sendVisitorNotification(
              employeeId: event.employeeToMeetId,
              visitorName: event.name,
              visitorOrigin: event.origin,
              visitorPurpose: event.purpose,
              gatekeeperName: event.gatekeeperName,
              visitorId: latestVisitId,
            );
            
            if (notificationSent) {
              log('✅ Visitor notification sent successfully to employee: ${event.employeeToMeetName}');
            } else {
              log('❌ Failed to send visitor notification to employee: ${event.employeeToMeetName}');
              log('❌ This usually means FCM token not found, service account misconfigured, or network issue');
            }
          } catch (e) {
            log('❌ Exception sending visitor notification: $e');
            log('❌ Stack trace: ${StackTrace.current}');
            // Don't fail the registration if notification fails
          }
          
          // Check again before emitting
          if (!emit.isDone) {
            emit(VisitorProfileRegistered(visitorProfile));
          }
        },
      );
    } catch (e) {
      log('Error in smart visitor registration: $e');
      emit(VisitorError('Failed to register visitor: ${e.toString()}'));
    }
  }

  void _uploadPhotoForProfile(String profileId, File photoFile) async {
    try {
      final photoUrl = await _remoteDataSource.uploadVisitorPhoto(
        profileId,
        photoFile,
      );
      
      // TODO: Update visitor profile with photo URL
      log('Photo uploaded successfully: $photoUrl');
    } catch (e) {
      log('Failed to upload photo: $e');
    }
  }
}