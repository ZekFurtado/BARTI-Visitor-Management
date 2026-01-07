part of 'visitor_bloc.dart';

abstract class VisitorState extends Equatable {
  const VisitorState();

  @override
  List<Object?> get props => [];
}

class VisitorInitial extends VisitorState {
  const VisitorInitial();
}

class VisitorLoading extends VisitorState {
  const VisitorLoading();
}

class VisitorRegistered extends VisitorState {
  final Visitor visitor;

  const VisitorRegistered(this.visitor);

  @override
  List<Object> get props => [visitor];
}

class VisitorsLoaded extends VisitorState {
  final List<Visitor> visitors;

  const VisitorsLoaded(this.visitors);

  @override
  List<Object> get props => [visitors];
}

class VisitorStatusUpdated extends VisitorState {
  final Visitor visitor;

  const VisitorStatusUpdated(this.visitor);

  @override
  List<Object> get props => [visitor];
}

class VisitorPhotoUploading extends VisitorState {
  const VisitorPhotoUploading();
}

class VisitorPhotoUploaded extends VisitorState {
  final String photoUrl;

  const VisitorPhotoUploaded(this.photoUrl);

  @override
  List<Object> get props => [photoUrl];
}

class VisitorError extends VisitorState {
  final String message;

  const VisitorError(this.message);

  @override
  List<Object> get props => [message];
}