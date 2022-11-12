import 'package:easi/history.dart';
import 'package:easi/home_history.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeHistoryUI extends StatefulWidget {
  const HomeHistoryUI({Key? key}) : super(key: key);

  @override
  _HomeHistoryUIState createState() => _HomeHistoryUIState();
}

class _HomeHistoryUIState extends State<HomeHistoryUI> {
 
  late DatabaseReference dbRef;
  int _historyLength = 0;

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    dbRef = FirebaseDatabase.instance.ref().child('history');
    final listed = dbRef.orderByChild("userUID").equalTo(uid);

    var data = [];
    listed.onValue.listen((event) {
      for (final child in event.snapshot.children) {
        data.add(child.value);
      }

      if (data != null) {
        setState(() {
          _historyLength = data.length;
        });
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Material(
      color: Color(0xFFF6F6F8),
      child: Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 50),
          child: 
            _historyLength <= 0 ? 
            Container(
              child: Container(
                  width: 500,
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFCFCFCF)),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(children: [
                    // Insert code for conditional rendering, if may history ang user or wala
                    Text("You haven't simplified any text yet.",
                        style: TextStyle(color: Colors.black))
                  ]),
                ),
            )
          : HomeHistory()
          )
      
      ],
    ),
    );
  }
}
