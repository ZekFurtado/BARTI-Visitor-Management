import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/visitor.dart';
import '../models/visitor_model.dart';
import '../models/visitor_profile_model.dart';

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

  /// Get visitor profile by phone number
  Future<VisitorProfileModel?> getVisitorProfileByPhone(String phoneNumber);

  /// Create or update visitor profile
  Future<VisitorProfileModel> createOrUpdateVisitorProfile(VisitorProfileModel visitorProfile);

  /// Add a new visit to existing visitor profile
  Future<VisitorProfileModel> addVisitToProfile(String phoneNumber, VisitModel visit);

  /// Search visitors by name or phone
  Future<List<VisitorProfileModel>> searchVisitors(String query);

  /// Get real-time stream of visitors for a specific employee
  Stream<List<VisitorModel>> getVisitorsForEmployeeStream(String employeeId);

  /// Get real-time stream of visitors by status
  Stream<List<VisitorModel>> getVisitorsByStatusStream(VisitorStatus status);
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
          .collection('visitor_profiles')
          .orderBy('createdAt', descending: true)
          .get();

      final visitorModels = <VisitorModel>[];
      
      for (final doc in querySnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        
        // Convert each visit in the profile to a VisitorModel
        for (final visit in profile.visits) {
          final visitorModel = VisitorModel(
            id: visit.id,
            name: profile.name,
            origin: visit.origin,
            purpose: visit.purpose,
            employeeToMeetId: visit.employeeToMeetId,
            employeeToMeetName: visit.employeeToMeetName,
            gatekeeperId: visit.gatekeeperId,
            gatekeeperName: visit.gatekeeperName,
            phoneNumber: profile.phoneNumber,
            email: profile.email,
            expectedDuration: visit.expectedDuration,
            notes: visit.notes,
            status: visit.status,
            createdAt: visit.visitDate,
            updatedAt: visit.updatedAt,
            photoUrl: profile.photoUrl,
          );
          visitorModels.add(visitorModel);
        }
      }
      
      // Sort by creation date (most recent first)
      visitorModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visitorModels;
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
      // Get all visitor profiles
      final querySnapshot = await firestore
          .collection('visitor_profiles')
          .orderBy('createdAt', descending: true)
          .get();

      final visitorModels = <VisitorModel>[];
      
      for (final doc in querySnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        
        // Filter visits for this specific employee and convert to VisitorModel
        for (final visit in profile.visits) {
          if (visit.employeeToMeetId == employeeId) {
            final visitorModel = VisitorModel(
              id: visit.id,
              name: profile.name,
              origin: visit.origin,
              purpose: visit.purpose,
              employeeToMeetId: visit.employeeToMeetId,
              employeeToMeetName: visit.employeeToMeetName,
              gatekeeperId: visit.gatekeeperId,
              gatekeeperName: visit.gatekeeperName,
              phoneNumber: profile.phoneNumber,
              email: profile.email,
              expectedDuration: visit.expectedDuration,
              notes: visit.notes,
              status: visit.status,
              createdAt: visit.visitDate,
              updatedAt: visit.updatedAt,
              photoUrl: profile.photoUrl,
            );
            visitorModels.add(visitorModel);
          }
        }
      }
      
      // Sort by visit date (most recent first)
      visitorModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visitorModels;
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
      // Get all visitor profiles
      final querySnapshot = await firestore
          .collection('visitor_profiles')
          .orderBy('createdAt', descending: true)
          .get();

      final visitorModels = <VisitorModel>[];
      
      for (final doc in querySnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        
        // Filter visits by status and convert to VisitorModel
        for (final visit in profile.visits) {
          if (visit.status == status) {
            final visitorModel = VisitorModel(
              id: visit.id,
              name: profile.name,
              origin: visit.origin,
              purpose: visit.purpose,
              employeeToMeetId: visit.employeeToMeetId,
              employeeToMeetName: visit.employeeToMeetName,
              gatekeeperId: visit.gatekeeperId,
              gatekeeperName: visit.gatekeeperName,
              phoneNumber: profile.phoneNumber,
              email: profile.email,
              expectedDuration: visit.expectedDuration,
              notes: visit.notes,
              status: visit.status,
              createdAt: visit.visitDate,
              updatedAt: visit.updatedAt,
              photoUrl: profile.photoUrl,
            );
            visitorModels.add(visitorModel);
          }
        }
      }
      
      // Sort by visit date (most recent first)
      visitorModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visitorModels;
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
      // Find the visitor profile containing this visit
      final allProfilesSnapshot = await firestore
          .collection('visitor_profiles')
          .get();
      
      VisitorProfileModel? targetProfile;
      VisitModel? targetVisit;
      
      // Search through all profiles to find the visit with matching ID
      for (final doc in allProfilesSnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        for (final visit in profile.visits) {
          if (visit.id == visitorId) {
            targetProfile = profile;
            targetVisit = visit as VisitModel;
            break;
          }
        }
        if (targetProfile != null) break;
      }
      
      if (targetProfile == null || targetVisit == null) {
        throw const ServerException(
          statusCode: '404',
          message: 'Visit not found in visitor profiles',
        );
      }
      
      // Update the visit status in the profile
      final updatedVisit = targetVisit.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      
      // Replace the visit in the profile's visits list
      final updatedVisits = targetProfile.visits.map((visit) {
        if (visit.id == visitorId) {
          return updatedVisit;
        }
        return visit;
      }).toList();
      
      final updatedProfile = targetProfile.copyWith(
        visits: updatedVisits,
        updatedAt: DateTime.now(),
      );
      
      // Update the profile in Firestore
      await firestore
          .collection('visitor_profiles')
          .doc(targetProfile.id)
          .update(updatedProfile.toFirestore());
      
      // Return the updated visitor as VisitorModel
      return VisitorModel(
        id: updatedVisit.id,
        name: updatedProfile.name,
        origin: updatedVisit.origin,
        purpose: updatedVisit.purpose,
        employeeToMeetId: updatedVisit.employeeToMeetId,
        employeeToMeetName: updatedVisit.employeeToMeetName,
        gatekeeperId: updatedVisit.gatekeeperId,
        gatekeeperName: updatedVisit.gatekeeperName,
        phoneNumber: updatedProfile.phoneNumber,
        email: updatedProfile.email,
        expectedDuration: updatedVisit.expectedDuration,
        notes: updatedVisit.notes,
        status: updatedVisit.status,
        createdAt: updatedVisit.visitDate,
        updatedAt: updatedVisit.updatedAt,
        photoUrl: updatedProfile.photoUrl,
      );
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
      // Search through all visitor profiles to find the visit with matching ID
      final allProfilesSnapshot = await firestore
          .collection('visitor_profiles')
          .get();
      
      for (final doc in allProfilesSnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        for (final visit in profile.visits) {
          if (visit.id == visitorId) {
            // Found the visit, convert to VisitorModel
            return VisitorModel(
              id: visit.id,
              name: profile.name,
              origin: visit.origin,
              purpose: visit.purpose,
              employeeToMeetId: visit.employeeToMeetId,
              employeeToMeetName: visit.employeeToMeetName,
              gatekeeperId: visit.gatekeeperId,
              gatekeeperName: visit.gatekeeperName,
              phoneNumber: profile.phoneNumber,
              email: profile.email,
              expectedDuration: visit.expectedDuration,
              notes: visit.notes,
              status: visit.status,
              createdAt: visit.visitDate,
              updatedAt: visit.updatedAt,
              photoUrl: profile.photoUrl,
            );
          }
        }
      }
      
      // Visit not found
      throw const ServerException(
        statusCode: '404',
        message: 'Visit not found in visitor profiles',
      );
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
      // Find the visitor profile containing this visit
      final allProfilesSnapshot = await firestore
          .collection('visitor_profiles')
          .get();
      
      VisitorProfileModel? targetProfile;
      
      // Search through all profiles to find the visit with matching ID
      for (final doc in allProfilesSnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        final hasVisit = profile.visits.any((visit) => visit.id == visitor.id);
        if (hasVisit) {
          targetProfile = profile;
          break;
        }
      }
      
      if (targetProfile == null) {
        throw const ServerException(
          statusCode: '404',
          message: 'Visitor profile not found for this visit',
        );
      }
      
      // Update the profile's basic info (name, email, phone) from visitor
      final updatedProfile = targetProfile.copyWith(
        name: visitor.name,
        phoneNumber: visitor.phoneNumber ?? targetProfile.phoneNumber,
        email: visitor.email ?? targetProfile.email,
        photoUrl: visitor.photoUrl ?? targetProfile.photoUrl,
        updatedAt: DateTime.now(),
      );
      
      // Update the specific visit in the profile's visits list
      final updatedVisits = targetProfile.visits.map((visit) {
        if (visit.id == visitor.id) {
          return VisitModel(
            id: visit.id,
            origin: visitor.origin,
            purpose: visitor.purpose,
            employeeToMeetId: visitor.employeeToMeetId,
            employeeToMeetName: visitor.employeeToMeetName,
            status: visitor.status,
            gatekeeperId: visitor.gatekeeperId,
            gatekeeperName: visitor.gatekeeperName,
            visitDate: visitor.createdAt,
            updatedAt: visitor.updatedAt ?? DateTime.now(),
            notes: visitor.notes,
            expectedDuration: visitor.expectedDuration,
          );
        }
        return visit;
      }).toList();
      
      final finalProfile = updatedProfile.copyWith(visits: updatedVisits);
      
      // Update the profile in Firestore
      await firestore
          .collection('visitor_profiles')
          .doc(targetProfile.id)
          .update(finalProfile.toFirestore());
      
      return visitor.copyWith(updatedAt: DateTime.now());
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
      // Find the visitor profile containing this visit
      final allProfilesSnapshot = await firestore
          .collection('visitor_profiles')
          .get();
      
      VisitorProfileModel? targetProfile;
      
      // Search through all profiles to find the visit with matching ID
      for (final doc in allProfilesSnapshot.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        final hasVisit = profile.visits.any((visit) => visit.id == visitorId);
        if (hasVisit) {
          targetProfile = profile;
          break;
        }
      }
      
      if (targetProfile == null) {
        throw const ServerException(
          statusCode: '404',
          message: 'Visit not found in visitor profiles',
        );
      }
      
      // Remove the visit from the profile's visits list
      final updatedVisits = targetProfile.visits
          .where((visit) => visit.id != visitorId)
          .toList();
      
      if (updatedVisits.isEmpty) {
        // If this was the only visit, delete the entire profile
        await firestore
            .collection('visitor_profiles')
            .doc(targetProfile.id)
            .delete();
      } else {
        // Update the profile with remaining visits
        final updatedProfile = targetProfile.copyWith(
          visits: updatedVisits,
          updatedAt: DateTime.now(),
        );
        
        await firestore
            .collection('visitor_profiles')
            .doc(targetProfile.id)
            .update(updatedProfile.toFirestore());
      }
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
      // Get the visitor profile for this phone number
      final profileSnapshot = await firestore
          .collection('visitor_profiles')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (profileSnapshot.docs.isEmpty) {
        return []; // No visitor profile found
      }
      
      final profile = VisitorProfileModel.fromFirestore(profileSnapshot.docs.first);
      final visitorModels = <VisitorModel>[];
      
      // Convert each visit to a VisitorModel
      for (final visit in profile.visits) {
        final visitorModel = VisitorModel(
          id: visit.id,
          name: profile.name,
          origin: visit.origin,
          purpose: visit.purpose,
          employeeToMeetId: visit.employeeToMeetId,
          employeeToMeetName: visit.employeeToMeetName,
          gatekeeperId: visit.gatekeeperId,
          gatekeeperName: visit.gatekeeperName,
          phoneNumber: profile.phoneNumber,
          email: profile.email,
          expectedDuration: visit.expectedDuration,
          notes: visit.notes,
          status: visit.status,
          createdAt: visit.visitDate,
          updatedAt: visit.updatedAt,
          photoUrl: profile.photoUrl,
        );
        visitorModels.add(visitorModel);
      }
      
      // Sort by visit date (most recent first)
      visitorModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return visitorModels;
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

  @override
  Future<VisitorProfileModel?> getVisitorProfileByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await firestore
          .collection('visitor_profiles')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return VisitorProfileModel.fromFirestore(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get visitor profile',
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
  Future<VisitorProfileModel> createOrUpdateVisitorProfile(VisitorProfileModel visitorProfile) async {
    try {
      if (visitorProfile.id == null) {
        // Ensure all visits have unique IDs before creating profile
        final visitsWithIds = visitorProfile.visits.map((visit) {
          if (visit.id == null) {
            final visitId = firestore.collection('visitor_profiles').doc().id;
            return visit is VisitModel
                ? visit.copyWith(id: visitId)
                : VisitModel(
                    id: visitId,
                    origin: visit.origin,
                    purpose: visit.purpose,
                    employeeToMeetId: visit.employeeToMeetId,
                    employeeToMeetName: visit.employeeToMeetName,
                    status: visit.status,
                    gatekeeperId: visit.gatekeeperId,
                    gatekeeperName: visit.gatekeeperName,
                    visitDate: visit.visitDate,
                    updatedAt: visit.updatedAt,
                    notes: visit.notes,
                    expectedDuration: visit.expectedDuration,
                  );
          }
          return visit;
        }).toList();

        final profileWithIds = visitorProfile.copyWith(visits: visitsWithIds);
        
        // Create new profile
        final docRef = await firestore
            .collection('visitor_profiles')
            .add(profileWithIds.toFirestore());
        
        final doc = await docRef.get();
        return VisitorProfileModel.fromFirestore(doc);
      } else {
        // Update existing profile
        await firestore
            .collection('visitor_profiles')
            .doc(visitorProfile.id)
            .update(visitorProfile.toFirestore());
        
        final doc = await firestore
            .collection('visitor_profiles')
            .doc(visitorProfile.id)
            .get();
        return VisitorProfileModel.fromFirestore(doc);
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to save visitor profile',
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
  Future<VisitorProfileModel> addVisitToProfile(String phoneNumber, VisitModel visit) async {
    try {
      // Get existing profile
      final existingProfile = await getVisitorProfileByPhone(phoneNumber);
      
      if (existingProfile == null) {
        throw const ServerException(
          statusCode: '404',
          message: 'Visitor profile not found',
        );
      }

      // Generate unique ID for the visit if it doesn't have one
      final visitWithId = visit.id == null
          ? visit.copyWith(id: firestore.collection('visitor_profiles').doc().id)
          : visit;

      // Add visit to profile
      final updatedProfile = existingProfile.addVisitModel(visitWithId);
      
      // Update in Firestore
      return await createOrUpdateVisitorProfile(updatedProfile);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<List<VisitorProfileModel>> searchVisitors(String query) async {
    try {
      // Search by name (case insensitive)
      final nameQuery = await firestore
          .collection('visitor_profiles')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .limit(20)
          .get();

      // Search by phone number
      final phoneQuery = await firestore
          .collection('visitor_profiles')
          .where('phoneNumber', isGreaterThanOrEqualTo: query)
          .where('phoneNumber', isLessThan: query + 'z')
          .limit(20)
          .get();

      final results = <VisitorProfileModel>[];
      final addedIds = <String>{};

      // Add name search results
      for (final doc in nameQuery.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        if (!addedIds.contains(profile.id)) {
          results.add(profile);
          addedIds.add(profile.id!);
        }
      }

      // Add phone search results (avoiding duplicates)
      for (final doc in phoneQuery.docs) {
        final profile = VisitorProfileModel.fromFirestore(doc);
        if (!addedIds.contains(profile.id)) {
          results.add(profile);
          addedIds.add(profile.id!);
        }
      }

      // Sort by latest visit date
      results.sort((a, b) {
        final aLatest = a.latestVisit?.visitDate ?? a.createdAt;
        final bLatest = b.latestVisit?.visitDate ?? b.createdAt;
        return bLatest.compareTo(aLatest);
      });

      return results;
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to search visitors',
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
  Stream<List<VisitorModel>> getVisitorsForEmployeeStream(String employeeId) {
    try {
      return firestore
          .collection('visitor_profiles')
          .where('visits', arrayContainsAny: [
            {'employeeToMeetId': employeeId}
          ])
          .snapshots()
          .map((snapshot) => snapshot.docs
              .expand((doc) {
                final profile = VisitorProfileModel.fromFirestore(doc);
                return profile.visits
                    .where((visit) => visit.employeeToMeetId == employeeId)
                    .map((visit) => VisitorModel(
                          id: visit.id,
                          name: profile.name,
                          origin: visit.origin,
                          purpose: visit.purpose,
                          employeeToMeetId: visit.employeeToMeetId,
                          employeeToMeetName: visit.employeeToMeetName,
                          status: visit.status,
                          gatekeeperId: visit.gatekeeperId,
                          gatekeeperName: visit.gatekeeperName,
                          phoneNumber: profile.phoneNumber,
                          email: profile.email,
                          photoUrl: profile.photoUrl,
                          expectedDuration: visit.expectedDuration,
                          notes: visit.notes,
                          createdAt: visit.visitDate,
                          updatedAt: visit.updatedAt,
                        ));
              })
              .toList());
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get visitor stream: $e',
      );
    }
  }

  @override
  Stream<List<VisitorModel>> getVisitorsByStatusStream(VisitorStatus status) {
    try {
      return firestore
          .collection('visitor_profiles')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .expand((doc) {
                final profile = VisitorProfileModel.fromFirestore(doc);
                return profile.visits
                    .where((visit) => visit.status == status)
                    .map((visit) => VisitorModel(
                          id: visit.id,
                          name: profile.name,
                          origin: visit.origin,
                          purpose: visit.purpose,
                          employeeToMeetId: visit.employeeToMeetId,
                          employeeToMeetName: visit.employeeToMeetName,
                          status: visit.status,
                          gatekeeperId: visit.gatekeeperId,
                          gatekeeperName: visit.gatekeeperName,
                          phoneNumber: profile.phoneNumber,
                          email: profile.email,
                          photoUrl: profile.photoUrl,
                          expectedDuration: visit.expectedDuration,
                          notes: visit.notes,
                          createdAt: visit.visitDate,
                          updatedAt: visit.updatedAt,
                        ));
              })
              .toList());
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get visitor stream by status: $e',
      );
    }
  }
}
