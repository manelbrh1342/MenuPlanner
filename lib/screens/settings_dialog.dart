import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _notificationsEnabled = true;
  bool _autoUpdateEnabled = true;  // Ajout de la variable pour la mise à jour automatique

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF02197D).withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20),
                _buildNotificationOption(),
                SizedBox(height: 10),
                _buildAutoUpdateOption(),  // Ajout de l'option pour la mise à jour automatique
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

  Widget _buildNotificationOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: Color(0x990013AD), size: 24),
              SizedBox(width: 10),
              Text("Notifications", style: TextStyle(fontSize: 16)),
            ],
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: _notificationsEnabled,
              activeColor: Color.fromARGB(255, 22, 50, 175),
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoUpdateOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.update, color: Color(0x990013AD), size: 24),
              SizedBox(width: 10),
              Text("Mise à jour automatique", style: TextStyle(fontSize: 16)),
            ],
          ),
          Transform.scale(
            scale: 0.7, 
            child: Switch(
              value: _autoUpdateEnabled,
              activeColor: Color.fromARGB(255, 22, 50, 175),
              onChanged: (value) {
                setState(() {
                  _autoUpdateEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
