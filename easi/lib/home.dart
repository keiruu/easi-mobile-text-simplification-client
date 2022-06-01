import 'package:flutter/material.dart';
import 'main.dart';
import 'words_in_picture.dart';
import 'text_simplification.dart';
class Home extends StatelessWidget {
  String userName = "User";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35, 5, 35, 0),
      child: Column(
          children: [
            Align( 
              alignment: Alignment.centerLeft, 
              child: Row(
                children: [
                  Text('Hi ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF232253)),), 
                  Text('$userName 👋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF5274AE)))
                ],
              ),
            ),
            Align( 
              alignment: Alignment.centerLeft, 
              child: Text('Welcome to Easi.', style: TextStyle(fontSize: 15, color: Color(0xFF6E7683)),)
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
              height: 120,
              width: 291,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/header.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: (
                Align( 
                  alignment: Alignment.centerLeft, 
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                    child: Text("Making it\nsimple for you.",
                      style: TextStyle(fontSize: 20, color: Colors.white,
                        fontWeight: FontWeight.w400,
                      )  
                    ),
                  )
                ,)
              )
            ),
            Align(
              alignment: Alignment.centerLeft, 
              child: Text("Choose how you want to enter words:",
                style: TextStyle(fontSize: 14, color: Color(0xFF232253),
                  fontWeight: FontWeight.w600)
                ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                          TextSimplification(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                    padding: EdgeInsets.fromLTRB(15, 70, 50, 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF6D1),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text("Type it", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFFF3D55E)),
                    ),
                  ),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                          WordsInPicture(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                    padding: EdgeInsets.fromLTRB(15, 50, 45, 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8E2EC),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Text("Words in\npicture", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xFFFF8AC1))),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.centerLeft, 
              child: Text("History", style: TextStyle(fontSize: 14, color: Color(0xFF232253),
                  fontWeight: FontWeight.w600)
              ),
            ),
            Container(
              width: 500,
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFCFCFCF)),
                borderRadius: BorderRadius.circular(15)
              ),
              child: Column(
                children: [
                  // Insert code for conditional rendering, if may history ang user or wala
                    Text("You haven't simplified any text yet.", style: TextStyle(color: Color(0xFF232253)))
                  ]
                ),
            )
          ],
        ),
    );
  }
}
