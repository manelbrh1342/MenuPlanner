import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:menu_planner/services/auth.dart';
import 'package:menu_planner/services/firestore_service.dart';
import 'dart:convert';

class EditProfileDialog extends StatefulWidget {
  // Paramètres pour passer les valeurs par défaut
  final String defaultName;
  final String defaultGender;
  final String defaultEmail;

  const EditProfileDialog({
    super.key,
    required this.defaultName,
    required this.defaultGender,
    required this.defaultEmail,
  });

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? _profileImage;
  final Auth _auth = Auth();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = false;
  final String _errorMessage = '';

  // Contrôleurs pour les champs de texte
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs par défaut
    _nameController = TextEditingController(text: widget.defaultName);
    _genderController = TextEditingController(text: widget.defaultGender);
    _emailController = TextEditingController(text: widget.defaultEmail);
    _selectedGender = widget.defaultGender;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_profileImage != null) {
        await _auth.updateProfileWithImageFile(
          displayName: _nameController.text,
          imageFile: _profileImage!,
          gender: _selectedGender,
        );
      } else {
        await _auth.updateProfileData(
          displayName: _nameController.text,
          gender: _selectedGender,
        );
      }

      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'displayName': _nameController.text,
          'photoURL': _auth.firebaseUser?.photoURL,
          'gender': _selectedGender,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
                      color: const Color(0xFF02197D).withOpacity(0.8)),
                ),
                const SizedBox(height: 10),
                _buildInfoField(Icons.person, "Name", _nameController),
                // Replace gender TextField with DropdownButtonFormField
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wc, color: Color(0x990013AD)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender == "Not specified" ? null : _selectedGender,
                          items: const [
                            DropdownMenuItem(
                              value: 'Not specified',
                              child: Text('Not specified'),
                            ),
                            DropdownMenuItem(
                              value: 'male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'female',
                              child: Text('Female'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 42, 45, 60)
                                    .withOpacity(0.53)),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInfoField(Icons.email, "Email", _emailController,
                    enabled: false),
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
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Save",
                            style: TextStyle(color: Colors.white)),
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
              child: Icon(Icons.arrow_back,
                  color: const Color(0xFF02197D).withOpacity(0.8), size: 28),
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
                        ? const Icon(Icons.person,
                            size: 50, color: Colors.white)
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
                    onTap: _pickImage,
                    child: const CircleAvatar(
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
  Widget _buildInfoField(
      IconData icon, String label, TextEditingController controller,
      {bool enabled = true, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0x990013AD)),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              readOnly: readOnly,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                    color: const Color.fromARGB(255, 42, 45, 60)
                        .withOpacity(0.53)),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
