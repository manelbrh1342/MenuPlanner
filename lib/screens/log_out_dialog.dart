import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  // Fonction pour gérer l'action de déconnexion
  void _logout(BuildContext context) {
    // Logique de déconnexion ici (par exemple, suppression des données utilisateur, redirection, etc.)
    // Pour l'instant, on va juste fermer la boîte de dialogue.
    Navigator.pop(context); // Fermer le dialog
    // Ajoute ici ta logique de déconnexion (par exemple, appel à FirebaseAuth.signOut(), etc.)
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Are you sure you want to log out?",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton de confirmation de déconnexion
                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Yes"),
                ),
                SizedBox(width: 20),
                // Bouton d'annulation
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue sans rien faire
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
