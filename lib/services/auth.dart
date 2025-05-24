import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:menu_planner/models/user.dart';
import 'package:menu_planner/services/firestore_service.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  FirestoreService get firestoreService => _firestore;
  // Returns a stream of Firebase User objects
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Returns a stream of our custom AppUser objects
  Stream<AppUser?> get userStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );
    });
  }

  // Current user stream that maps Firebase User to our AppUser
  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
      );
    });
  }

  // Get the current user as a AppUser
  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  // Get the Firebase User object
  User? get firebaseUser => _firebaseAuth.currentUser;

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Perform basic Firebase auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Get fresh user data directly from Firebase
      final user = userCredential.user!;
      await user.reload();
      final currentUser = _firebaseAuth.currentUser!;

      // 3. Manually create AppUser object
      return AppUser(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName,
      );
    } catch (e) {
      debugPrint('Raw auth error: ${e.toString()}');
      rethrow;
    }
  }

  Future<AppUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update display name immediately
      await userCredential.user?.updateDisplayName(displayName);

      // 3. Create user object
      final user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );

      // 4. Create Firestore document SYNCHRONOUSLY
      await _firestore.createUserProfile(user);
      debugPrint('Firestore user created successfully');

      return user;
    } catch (e) {
      debugPrint('Error during signup: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> reauthenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(authExceptionHandler(e));
    }
  }

  // Helper method to handle auth exceptions
  static String? authExceptionHandler(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found for the provided email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      default:
        return 'An undefined error occurred.';
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      final userData = await _firestore.getUserData(uid);
      return userData;
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  Future<void> createUserProfile(AppUser user) async {
    try {
      await _firestore.createUserProfile(user);
      debugPrint('User profile created in Firestore for uid: ${user.uid}');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore.updateUserProfile(user);
      debugPrint('User profile updated in Firestore for uid: ${user.uid}');
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Reloads the current user's auth data
  Future<void> reloadCurrentUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
      rethrow;
    }
  }

  /// Gets the raw Firebase User object with fresh data
  Future<User?> getFreshFirebaseUser() async {
    await reloadCurrentUser();
    return _firebaseAuth.currentUser;
  }

  Future<void> updateProfileData({
    required String displayName,
    String? photoUrl,
    String? gender,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update Firebase Auth profile directly
      await user.updateDisplayName(displayName);
      if (photoUrl != null && !photoUrl.startsWith('data:image')) {
        // Only update photoURL if it is a valid URL, not base64 string
        await user.updatePhotoURL(photoUrl);
      }

      // Force a reload to sync changes
      await user.reload();

      // Update Firestore (if you're using it)
      await _firestore.updateUserData(user.uid, {
        'displayName': displayName,
        if (photoUrl != null) 'photoURL': photoUrl,
        if (gender != null) 'gender': gender,
      });
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfileWithImageFile({
    required String displayName,
    required File imageFile,
    String? gender,
  }) async {
    try {
      // Resize/compress the image first (optional)
      final compressedImage = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 200,
        minHeight: 200,
        quality: 70,
      );

      // Convert to Base64
      final base64Image = base64Encode(compressedImage!);
      final photoUrl = 'data:image/jpeg;base64,$base64Image';

      // Update profile - do NOT update Firebase Auth photoURL with base64 string
      await updateProfileData(
        displayName: displayName,
        photoUrl: null, // skip updating Firebase Auth photoURL
        gender: gender,
      );

      // Update Firestore with base64 image string
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.updateUserData(user.uid, {
          'photoURL': photoUrl,
        });
      }
    } catch (e) {
      print('Error updating profile with image: $e');
      rethrow;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    // Fetch user profile from Firestore
    return await _firestore.getUserProfile(user.uid);
  }
}
