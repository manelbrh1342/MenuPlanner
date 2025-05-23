import 'package:flutter/material.dart';

class Exportpage extends StatefulWidget {
  const Exportpage({super.key});

  @override
  State<Exportpage> createState() => _ExportpageState();
}

class _ExportpageState extends State<Exportpage> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close, color: Colors.yellow, size: 24),
              ),
            ),
            Text(
              "Export the \nweekly menu!",
              style: TextStyle(
                color: Color(0xFF02197D),
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Choose your preferred format.",
              style: TextStyle(color: Color(0xFF949494), fontSize: 12),
            ),
            SizedBox(height: 20),
            _exportOption("assets/Icons/ExportPDF.png", "Export as PDF"),
            SizedBox(height: 10),
            _exportOption(
              "assets/Icons/ExportPicture.png",
              "Export as Picture",
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportOption(String imagePath, String text) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(imagePath),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: Color(0xFF69696B), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
