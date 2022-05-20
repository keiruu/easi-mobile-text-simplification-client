import 'package:flutter/material.dart';
import 'main.dart';

class Home extends StatelessWidget {
  String userName = "User";

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            Text('Hi $userName 👋'),
            Text('Welcome to Easi.'),
            Container(
              child: (
                Text("Making it simple for you.")
              )
            ),
            Text("Choose how you want to enter words:"),
            Row(
              children: [
                Container(
                  child: Text("Type it"),
                ),
                Container(
                  child: Text("Words in picture"),
                )
              ],
            ),
            Text("History")
          ],
        );
  }
}
