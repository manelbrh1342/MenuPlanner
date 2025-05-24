import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? gender;
  final bool notificationsEnabled;
  final bool autoUpdateEnabled;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.gender,
    this.notificationsEnabled = true,
    this.autoUpdateEnabled = true,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '', // Handle null email if needed
      displayName: user.displayName,
      photoURL: user.photoURL,
      gender: null, // Assuming gender is not available in FirebaseUser
      notificationsEnabled: true,
      autoUpdateEnabled: true,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      gender: map['gender'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      autoUpdateEnabled: map['autoUpdateEnabled'] ?? true,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'gender': gender,
      'notificationsEnabled': notificationsEnabled,
      'autoUpdateEnabled': autoUpdateEnabled,
    };
  }
}
