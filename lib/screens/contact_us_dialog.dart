import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsDialog extends StatelessWidget {
  // Fonction pour ouvrir l'application de messagerie
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri.parse("mailto:menuplanner123@gmail.com");

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Impossible d’ouvrir $emailLaunchUri';
      }
    } catch (e) {
      print('Erreur lors de l’ouverture de l’email: $e');
    }
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
              "Contact Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "If you have any questions or need assistance, feel free to contact us at:",
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _launchEmail,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 5),
                  Text(
                    "menuplanner123@gmail.com",
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
