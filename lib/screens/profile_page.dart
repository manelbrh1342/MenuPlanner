import 'package:flutter/material.dart';
import 'package:my_new_app/screens/change_password_dialog.dart';
import 'package:my_new_app/screens/contact_us_dialog.dart';
import 'package:my_new_app/screens/language_dialog.dart';
import 'package:my_new_app/screens/log_out_dialog.dart';
import 'package:my_new_app/screens/settings_dialog.dart';
import 'edit_profile_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Correction de la couleur
      body: SingleChildScrollView( // Permet le scroll si nécessaire
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color.fromARGB(255, 194, 194, 194),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                "John Carteer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF02197D)),
              ),
              const Text(
                "JohnCarteer@gmail.com",
                style: TextStyle(color: Color(0xFF0013AD)),
              ),
              const SizedBox(height: 20),
              _buildSection("ACCOUNTS"),
              _buildListTile(Icons.edit, "Edit Profile", () { showEditProfileDialog(context); }),
              _buildDivider(),
              _buildListTile(Icons.lock, "Change Password", () {showChangePasswordDialog(context);}),
              _buildSection("PREFERENCES"),
              _buildListTile(Icons.language, "Language", () {showLanguageDialog(context);}),
              _buildDivider(),
              _buildListTile(Icons.settings, "Settings" , () {showSettingsDialog(context);}),
              _buildDivider(),
              _buildListTile(Icons.contact_mail, "Contact Us",() {showContactUsDialog(context);}),
              _buildDivider(),
              _buildListTile(Icons.logout, "Log Out",() {showLogOutDialog(context);}),
              const SizedBox(height: 20), 
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF02197D)),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String text, VoidCallback? onTap) {
  return ListTile(
    leading: Icon(icon, color: Color(0x990013AD)), 
    title: Text(text, style: TextStyle(color: Color(0xFF010F7E))),
    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF010F7E)),
    onTap: onTap, 
  );
}
// Fonction pour afficher la fenêtre modale
void showEditProfileDialog(BuildContext context) {
  // Valeurs par défaut pour les champs
  String defaultName = "John Doe";
  String defaultGender = "Male";
  String defaultEmail = "john.doe@example.com";

  showDialog(
    context: context,
    builder: (context) {
      return EditProfileDialog(
        defaultName: defaultName,
        defaultGender: defaultGender,
        defaultEmail: defaultEmail,
      );
    },
  );
}

void showChangePasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return ChangePasswordDialog();
    },
  );
}
void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return LanguageDialog();
    },
  );
}
void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return SettingsDialog();
    },
  );
}
void showContactUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return ContactUsDialog();  // Affiche le ContactUsDialog
    },
  );
}
void showLogOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return LogoutDialog();  
    },
  );
}


}
