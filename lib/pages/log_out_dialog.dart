import 'package:flutter/material.dart';
import 'login.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // 🚨 Properly log out from Firebase

    Navigator.pop(context); // Close the dialog
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
            const Text(
              "Confirm Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Are you sure you want to log out?",
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: const Text("Yes"),
                ),
                const SizedBox(width: 25),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 172, 183, 214),
                    foregroundColor: const Color.fromARGB(255, 249, 249, 249),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  label: const Text("No"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}