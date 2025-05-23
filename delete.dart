import 'package:flutter/material.dart';

class DeletePage extends StatefulWidget {
  const DeletePage({super.key});

  @override
  State<DeletePage> createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
                child: Icon(Icons.close, color: Color(0xFF02197D), size: 24),
              ),
            ),
            Text(
              "Do you really want to delete this meal?",
              style: TextStyle(
                color: Color(0xFF02197D),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFDBDB),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Color(0xFFFF8A8A)),
                  ),
                ),
                SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCCFFBD),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('No', style: TextStyle(color: Color(0xFF00BC29))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
