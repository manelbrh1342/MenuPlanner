import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'dart:io'; // For Platform
import 'package:flutter/foundation.dart'; // For debugPrint

class ContactUsDialog extends StatelessWidget {
  const ContactUsDialog({super.key});

  Future<void> _launchEmail(BuildContext context) async {  // Pass context
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'menuplanner123@gmail.com',
      queryParameters: {'subject': 'Menu Planner App Support'},
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await _showNoEmailAppDialog(context);  // Pass context
      }
    } catch (e) {
      debugPrint('Email launch error: $e');
      await _showNoEmailAppDialog(context);  // Pass context
    }
  }
  Future<void> _showNoEmailAppDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Email App Found"),
        content: const Text(
            "Would you like to copy the email address to your clipboard?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(
                  const ClipboardData(text: "menuplanner123@gmail.com"));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Email copied to clipboard")),
              );
              Navigator.pop(context);
            },
            child: const Text("Copy"),
          ),
        ],
      ),
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
              "Contact Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF02197D),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "If you have any questions or need assistance, feel free to contact us at:",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => _launchEmail(context), // Pass context here
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      "menuplanner123@gmail.com",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
