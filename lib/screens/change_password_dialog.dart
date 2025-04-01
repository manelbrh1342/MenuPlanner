import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(20),
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
                      color: Color(0xFF02197D).withOpacity(0.8)),
                ),
                SizedBox(height: 10),
                _buildPasswordField(
                  "Old Password",
                  _oldPasswordController,
                  _obscureOldPassword,
                  () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                  Icons.key_off, // Icône pour le mot de passe actuel
                  hasBorder: false, // Suppression de la bordure sous ce champ
                ),
                _buildPasswordField(
                  "New Password",
                  _newPasswordController,
                  _obscureNewPassword,
                  () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  Icons.key, // Icône pour le nouveau mot de passe
                  hasBorder: false, // Suppression de la bordure sous ce champ
                ),
                _buildPasswordField(
                  "Confirm Password",
                  _confirmPasswordController,
                  _obscureConfirmPassword,
                  () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  Icons.check, // Icône pour confirmer le mot de passe
                  hasBorder: false, // Suppression de la bordure sous ce champ
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 25,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: Color(0xFF02197D).withOpacity(0.8), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility, IconData icon, {bool hasBorder = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0x990013AD)), // Icône pour le champ
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFFACA6A6).withOpacity(0.53)),
          // Suppression de la bordure si `hasBorder` est false
          border: hasBorder 
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.7), width: 1.8),
                )
              : InputBorder.none,  // Pas de bordure si `hasBorder` est false
          focusedBorder: hasBorder 
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                )
              : InputBorder.none,  // Pas de bordure au focus si `hasBorder` est false
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20, // Taille de l'icône
            ),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
