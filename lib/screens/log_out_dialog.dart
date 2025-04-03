import 'package:flutter/material.dart';
import 'login_page.dart'; // Assure-toi que la page de login est bien importée

class LogoutDialog extends StatelessWidget {
  // Fonction pour gérer l'action de déconnexion
  void _logout(BuildContext context) {
    // Logique de déconnexion ici (par exemple, suppression des données utilisateur, redirection, etc.)
    Navigator.pop(context); // Fermer le dialog

    // Remplace la page actuelle par la page de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Remplace LoginPage par ta page de login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Confirm Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Are you sure you want to log out?",
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton de confirmation de déconnexion
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: Text("Yes"),
                ),
                SizedBox(width: 25),
                // Bouton d'annulation
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue sans rien faire
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 172, 183, 214),
                    foregroundColor: const Color.fromARGB(255, 249, 249, 249),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
