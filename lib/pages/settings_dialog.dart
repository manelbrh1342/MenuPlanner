import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:menu_planner/services/firestore_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _autoUpdateEnabled = true;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool localAutoUpdate = prefs.getBool('auto_update_enabled') ?? true;

    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userData = await _firestoreService.getUserData(currentUser.uid);
        bool remoteAutoUpdate = userData['autoUpdateEnabled'] ?? localAutoUpdate;

        setState(() {
          _autoUpdateEnabled = remoteAutoUpdate;
        });

        // Sync local prefs with remote values
        await prefs.setBool('auto_update_enabled', remoteAutoUpdate);
      } catch (e) {
        // If error, fallback to local prefs
        setState(() {
          _autoUpdateEnabled = localAutoUpdate;
        });
      }
    } else {
      setState(() {
        _autoUpdateEnabled = localAutoUpdate;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    User? currentUser = _auth.currentUser;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_update_enabled', _autoUpdateEnabled);

      if (currentUser != null) {
        await _firestoreService.updateUserData(currentUser.uid, {
          'autoUpdateEnabled': _autoUpdateEnabled,
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02197D).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                _buildAutoUpdateOption(),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF02197D), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildAutoUpdateOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.update, color: Color(0x990013AD), size: 24),
              SizedBox(width: 10),
              Text("Auto Update", style: TextStyle(fontSize: 16)),
            ],
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: _autoUpdateEnabled,
              activeColor: const Color.fromARGB(255, 22, 50, 175),
              onChanged: (value) {
                setState(() {
                  _autoUpdateEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}