import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileDialog extends StatefulWidget {
  // Paramètres pour passer les valeurs par défaut
  final String defaultName;
  final String defaultGender;
  final String defaultEmail;

  EditProfileDialog({
    required this.defaultName,
    required this.defaultGender,
    required this.defaultEmail,
  });

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? _profileImage;

  // Contrôleurs pour les champs de texte
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs par défaut
    _nameController = TextEditingController(text: widget.defaultName);
    _genderController = TextEditingController(text: widget.defaultGender);
    _emailController = TextEditingController(text: widget.defaultEmail);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs
    _nameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    super.dispose();
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
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Profile",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02197D).withOpacity(0.8)),
                ),
                SizedBox(height: 10),
                _buildInfoField(Icons.person, "Name", _nameController),
                _buildInfoField(Icons.wc, "Gender", _genderController),
                _buildInfoField(Icons.email, "Email", _emailController),
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
          // Flèche de retour
          Positioned(
            top: 20,
            left: 40,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: Color(0xFF02197D).withOpacity(0.8), size: 28),
            ),
          ),
          Positioned(
            top: -50,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[300],
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: _pickImage, // Permet d'ouvrir la galerie en cliquant sur l'icône
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modification pour utiliser TextEditingController
  Widget _buildInfoField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0x990013AD)),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller, // Utiliser le contrôleur pour chaque champ
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Color.fromARGB(255, 42, 45, 60).withOpacity(0.53)),
                border: InputBorder.none, // Pas de bordure sous le champ
                focusedBorder: InputBorder.none, // Pas de bordure quand le champ est sélectionné
              ),
            ),
          ),
        ],
      ),
    );
  }
}
