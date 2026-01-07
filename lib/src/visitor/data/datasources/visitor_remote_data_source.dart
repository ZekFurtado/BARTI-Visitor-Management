import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/visitor.dart';
import '../models/visitor_model.dart';

abstract class VisitorRemoteDataSource {
  /// Register a new visitor
  Future<VisitorModel> registerVisitor(VisitorModel visitor);

  /// Upload visitor photo to Firebase Storage
  Future<String> uploadVisitorPhoto(String visitorId, File photoFile);

  /// Get all visitors
  Future<List<VisitorModel>> getAllVisitors();

  /// Get visitors for a specific employee
  Future<List<VisitorModel>> getVisitorsForEmployee(String employeeId);

  /// Get visitors by status
  Future<List<VisitorModel>> getVisitorsByStatus(VisitorStatus status);

  /// Update visitor status
  Future<VisitorModel> updateVisitorStatus(
    String visitorId,
    VisitorStatus status,
  );

  /// Get visitor by ID
  Future<VisitorModel> getVisitorById(String visitorId);

  /// Update visitor information
  Future<VisitorModel> updateVisitor(VisitorModel visitor);

  /// Delete visitor record
  Future<void> deleteVisitor(String visitorId);

  /// Send notification to employee (via REST API)
  Future<void> notifyEmployee(
    String employeeId,
    String visitorId,
    String message,
  );

  /// Get visitor history by phone number
  Future<List<VisitorModel>> getVisitorHistoryByPhone(String phoneNumber);
}

class VisitorRemoteDataSourceImpl implements VisitorRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final http.Client httpClient;

  VisitorRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.httpClient,
  });

  @override
  Future<VisitorModel> registerVisitor(VisitorModel visitor) async {
    try {
      // Add visitor to Firestore
      final docRef = await firestore
          .collection('visitors')
          .add(visitor.toFirestore());

      // Get the created visitor with ID
      final doc = await docRef.get();
      return VisitorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to register visitor',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<String> uploadVisitorPhoto(String visitorId, File photoFile) async {
    try {
      final ref = storage.ref().child('visitor_photos/$visitorId.jpg');
      final uploadTask = await ref.putFile(photoFile);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to upload photo',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred while uploading photo: $e',
      );
    }
  }

  @override
  Future<List<VisitorModel>> getAllVisitors() async {
    try {
      final querySnapshot = await firestore
          .collection('visitors')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitorModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitors',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<List<VisitorModel>> getVisitorsForEmployee(String employeeId) async {
    try {
      final querySnapshot = await firestore
          .collection('visitors')
          .where('employeeToMeetId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitorModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitors for employee',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<List<VisitorModel>> getVisitorsByStatus(VisitorStatus status) async {
    try {
      final querySnapshot = await firestore
          .collection('visitors')
          .where('status', isEqualTo: status.value)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitorModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitors by status',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<VisitorModel> updateVisitorStatus(
    String visitorId,
    VisitorStatus status,
  ) async {
    try {
      await firestore.collection('visitors').doc(visitorId).update({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get updated visitor
      final doc = await firestore.collection('visitors').doc(visitorId).get();
      return VisitorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to update visitor status',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<VisitorModel> getVisitorById(String visitorId) async {
    try {
      final doc = await firestore.collection('visitors').doc(visitorId).get();

      if (!doc.exists) {
        throw const ServerException(
          statusCode: '404',
          message: 'Visitor not found',
        );
      }

      return VisitorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitor',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    try {
      await firestore
          .collection('visitors')
          .doc(visitor.id)
          .update(visitor.toFirestore());

      final doc = await firestore.collection('visitors').doc(visitor.id).get();
      return VisitorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to update visitor',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<void> deleteVisitor(String visitorId) async {
    try {
      await firestore.collection('visitors').doc(visitorId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to delete visitor',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<void> notifyEmployee(
    String employeeId,
    String visitorId,
    String message,
  ) async {
    try {
      // This would typically call a REST API endpoint for notifications
      // For now, we'll simulate with a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Implement actual REST API call for notifications
      // Example:
      // final response = await httpClient.post(
      //   Uri.parse('https://your-api.com/notify'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'employeeId': employeeId,
      //     'visitorId': visitorId,
      //     'message': message,
      //   }),
      // );
      //
      // if (response.statusCode != 200) {
      //   throw ServerException(
      //     statusCode: response.statusCode.toString(),
      //     message: 'Failed to send notification',
      //   );
      // }
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred while sending notification: $e',
      );
    }
  }

  @override
  Future<List<VisitorModel>> getVisitorHistoryByPhone(
    String phoneNumber,
  ) async {
    try {
      final querySnapshot = await firestore
          .collection('visitors')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => VisitorModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitor history',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }
}
