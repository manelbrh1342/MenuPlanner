import 'package:flutter/material.dart';

class LanguageDialog extends StatefulWidget {
  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String _selectedLanguage = "English"; // Langue par défaut

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Language",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02197D).withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                _buildLanguageOption("English"),
                _buildLanguageOption("French"),
                _buildLanguageOption("Arabic"),
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
              child: Icon(Icons.arrow_back, color: Color(0xFF02197D), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language, style: TextStyle(color: Colors.black)),
      trailing: _selectedLanguage == language
          ? Icon(Icons.check, color: Color.fromARGB(255, 63, 94, 232), size: 24) // Icône de validation
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
    );
  }
}
