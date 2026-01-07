part of 'visitor_bloc.dart';

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();

  @override
  List<Object?> get props => [];
}

class RegisterVisitorEvent extends VisitorEvent {
  final String name;
  final String origin;
  final String purpose;
  final String employeeToMeetId;
  final String employeeToMeetName;
  final String gatekeeperId;
  final String gatekeeperName;
  final String? phoneNumber;
  final String? email;
  final String? expectedDuration;
  final String? notes;
  final File? photoFile;

  const RegisterVisitorEvent({
    required this.name,
    required this.origin,
    required this.purpose,
    required this.employeeToMeetId,
    required this.employeeToMeetName,
    required this.gatekeeperId,
    required this.gatekeeperName,
    this.phoneNumber,
    this.email,
    this.expectedDuration,
    this.notes,
    this.photoFile,
  });

  @override
  List<Object?> get props => [
        name,
        origin,
        purpose,
        employeeToMeetId,
        employeeToMeetName,
        gatekeeperId,
        gatekeeperName,
        phoneNumber,
        email,
        expectedDuration,
        notes,
        photoFile,
      ];
}

class GetAllVisitorsEvent extends VisitorEvent {
  const GetAllVisitorsEvent();
}

class GetVisitorsForEmployeeEvent extends VisitorEvent {
  final String employeeId;

  const GetVisitorsForEmployeeEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

class GetVisitorsByStatusEvent extends VisitorEvent {
  final VisitorStatus status;

  const GetVisitorsByStatusEvent({required this.status});

  @override
  List<Object> get props => [status];
}

class UpdateVisitorStatusEvent extends VisitorEvent {
  final String visitorId;
  final VisitorStatus status;

  const UpdateVisitorStatusEvent({
    required this.visitorId,
    required this.status,
  });

  @override
  List<Object> get props => [visitorId, status];
}

class UploadVisitorPhotoEvent extends VisitorEvent {
  final String visitorId;
  final File photoFile;

  const UploadVisitorPhotoEvent({
    required this.visitorId,
    required this.photoFile,
  });

  @override
  List<Object> get props => [visitorId, photoFile];
}