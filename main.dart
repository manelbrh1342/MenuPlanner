import 'package:flutter/material.dart';

void main() {
  runApp(CommentApp());
}

class CommentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comment Box',
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(child: CommentBox()),
      ),
    );
  }
}

class CommentBox extends StatefulWidget {
  @override
  _CommentBoxState createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec icône et bouton close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.edit, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    "Add comments :",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Fermer la boîte de dialogue ou faire autre chose
                  print("Closed");
                },
                child: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Zone de commentaire
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Add your comments here ...",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bouton Submit
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              print("Comment submitted: ${_controller.text}");
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
