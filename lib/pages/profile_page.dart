import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:menu_planner/pages/change_password_dialog.dart';
import 'package:menu_planner/pages/contact_us_dialog.dart';
import 'package:menu_planner/pages/log_out_dialog.dart';
import 'package:menu_planner/pages/settings_dialog.dart';
import 'package:menu_planner/services/auth.dart';
import 'package:menu_planner/pages/review.dart';
import 'package:menu_planner/pages/favorites.dart';
import 'package:menu_planner/services/firestore_service.dart';
import 'edit_profile_dialog.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Auth _auth = Auth();
  String _displayName = "Loading...";
  String _email = "Loading...";
  String? _photoURL;
  final FirestoreService _firestore = FirestoreService();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _gender = "Not specified";

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // First get Firestore data
        final userData = await _firestore.getUserData(user.uid);

        setState(() {
          _displayName =
              user.displayName ?? userData['displayName'] ?? "No Name";
          _email = user.email ?? "No Email";
          _gender = userData['gender'] ?? "Not specified";

          // Handle photo URL - check both sources
          final authPhoto = user.photoURL;
          final firestorePhoto = userData['photoURL'];

          _photoURL = firestorePhoto != null
              ? firestorePhoto.startsWith('data:image')
                  ? firestorePhoto
                  : 'data:image/jpeg;base64,$firestorePhoto'
              : authPhoto != null
                  ? authPhoto.startsWith('data:image')
                      ? authPhoto
                      : 'data:image/jpeg;base64,$authPhoto'
                  : null;
        });
      } catch (e) {
        // Fallback to auth-only data if Firestore fails
        setState(() {
          _displayName = user.displayName ?? "No Name";
          _email = user.email ?? "No Email";
          _gender = "Not specified";
          _photoURL = user.photoURL != null
              ? user.photoURL!.startsWith('data:image')
                  ? user.photoURL
                  : 'data:image/jpeg;base64,${user.photoURL}'
              : null;
        });
      }
    }
  }

  Future<void> showEditProfileDialog(BuildContext context,
      {required String defaultName,
      required String defaultEmail,
      required String defaultGender}) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return EditProfileDialog(
          defaultName: defaultName,
          defaultGender: defaultGender,
          defaultEmail: defaultEmail,
        );
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      _handleProfileUpdate(result);
      await _refreshUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Update your CircleAvatar widget to handle base64 properly
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color.fromARGB(255, 194, 194, 194),
                backgroundImage: _photoURL != null
                    ? (_photoURL!.startsWith('data:image')
                        ? MemoryImage(base64Decode(_photoURL!.split(',')[1]))
                        : NetworkImage(_photoURL!) as ImageProvider)
                    : null,
                child: _photoURL == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                _displayName,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02197D)),
              ),
              Text(
                _email,
                style: const TextStyle(color: Color(0xFF0013AD)),
              ),
              const SizedBox(height: 10),
              Text(
                _gender,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0013AD)),
              ),
              const SizedBox(height: 20),
              _buildSection("ACCOUNTS"),
              _buildListTile(Icons.edit, "Edit Profile", () {
                showEditProfileDialog(
                  context,
                  defaultName: _displayName,
                  defaultEmail: _email,
                  defaultGender: _gender,
                );
              }),
              _buildDivider(),
              _buildListTile(Icons.lock, "Change Password", () {
                showChangePasswordDialog(context);
              }),
              _buildSection("ACTIVITY"),
              _buildListTile(Icons.star, "My Activity", () {
                _showActivityDialog(context);
              }),
              _buildSection("PREFERENCES"),
              _buildDivider(),
              _buildListTile(Icons.settings, "Settings", () {
                showSettingsDialog(context);
              }),
              _buildDivider(),
              _buildListTile(Icons.contact_mail, "Contact Us", () {
                showContactUsDialog(context);
              }),
              _buildDivider(),
              _buildListTile(Icons.logout, "Log Out", () {
                showLogOutDialog(context);
              }),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.blueGrey, thickness: 0.5),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x1A02197D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF02197D)),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF02197D)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showActivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFECECEC),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'My Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF02197D),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActivityOption(
                      context,
                      'Favorites',
                      Icons.favorite,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FavoritesPage(userId: Auth().firebaseUser!.uid),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildActivityOption(
                      context,
                      'Reviews',
                      Icons.star,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EvaluationScreen(),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 100),
                  ],
                   ),
              ),
              // Close (X) Button in top-right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Color(0xFFB0B0B0), // darker shade of gray
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x1A02197D), // lighter shade of amber
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF02197D)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _handleProfileUpdate(Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reload user to get latest auth data
        final User? firebaseUser = FirebaseAuth.instance.currentUser;
        await firebaseUser?.reload();

        setState(() {
          _displayName = user.displayName ?? _displayName;
          // Handle photo URL carefully
          if (updates.containsKey('photoURL')) {
            final photoUrl = updates['photoURL'];
            _photoURL = photoUrl is String ? photoUrl : null;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating UI: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshUserData() async {
    await _loadUserData();
  }
}

void showChangePasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const ChangePasswordDialog();
    },
  );
}



void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const SettingsDialog();
    },
  );
}

void showContactUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const ContactUsDialog();
    },
  );
}

void showLogOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return const LogoutDialog();
    },
  );
}
