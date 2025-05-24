import 'package:flutter/material.dart';
import 'package:menu_planner/services/auth.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final String _errorMessage = ''; // Variable pour stocker le message d'erreur
  bool _isLoading = false;
  final Auth _auth = Auth();

  Future<void> _changePassword() async {
    String newPassword = _newPasswordController.text;

    if (_oldPasswordController.text.isEmpty ||
        newPassword.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Password strength validation
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters long')),
      );
      return;
    }
    // Add more validation rules here if needed

    setState(() => _isLoading = true);

    try {
      final user = _auth.firebaseUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Reauthenticate user first
      await _auth.reauthenticateUser(
        email: user.email!,
        password: _oldPasswordController.text,
      );

      // Update password using Firebase Auth
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        // Clear password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error updating password';
        if (e.toString().contains('wrong-password')) {
          errorMessage = 'Old password is incorrect';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'The new password is too weak';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF02197D).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPasswordField(
                  "Old Password",
                  _oldPasswordController,
                  _obscureOldPassword,
                  () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                  Icons.key_off, 
                  hasBorder: false,
                ),
                _buildPasswordField(
                  "New Password",
                  _newPasswordController,
                  _obscureNewPassword,
                  () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  Icons.key, 
                  hasBorder: false,
                ),
                _buildPasswordField(
                  "Confirm Password",
                  _confirmPasswordController,
                  _obscureConfirmPassword,
                  () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  Icons.check, 
                  hasBorder: false,
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 20),
                _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changePassword,
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
              child: Icon(Icons.arrow_back, color: const Color(0xFF02197D).withOpacity(0.8), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility, IconData icon, {bool hasBorder = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0x990013AD)),
          labelText: label,
          labelStyle: TextStyle(color: const Color(0xFFACA6A6).withOpacity(0.53)),
          border: hasBorder 
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.8),
                )
              : InputBorder.none,
          focusedBorder: hasBorder 
              ? const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                )
              : InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}