import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/models/meal.dart';
import 'package:menu_planner/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user profile
  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  // Update an existing user profile
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get a user profile

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        debugPrint('No document found for uid: $uid');
        return null;
      }
      final data = doc.data();
      debugPrint('Retrieved user data for uid $uid: $data');
      return AppUser.fromMap(data!);
    } catch (e) {
      debugPrint('Firestore read error: $e');
      return null;
    }
  }

  // Meal Operations (Basic)
  Future<void> addMeal(Meal meal) async {
    try {
      await _firestore.collection('meals').doc(meal.id).set(meal.toMap());
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  // Update specific user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      if (data.isEmpty) {
        throw Exception('No data provided to update.');
      }
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return {};
      }

      final data = doc.data();
      if (data == null) {
        throw Exception('Invalid user data format.');
      }

      return data;
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  // Add other CRUD operations as needed
}
