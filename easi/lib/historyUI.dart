import 'package:easi/history.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryUI extends StatefulWidget {
  const HistoryUI({Key? key}) : super(key: key);

  @override
  _HistoryUIState createState() => _HistoryUIState();
}

class _HistoryUIState extends State<HistoryUI> {
 
  late DatabaseReference dbRef;
  int _historyLength = 0;

  @override
  void dispose() {
    super.dispose();
  }

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
      child: Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
          child: Text("History 🕒", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 50),
          child: 
          // _historyLength == null ? 
          //       Container(
          //         color: Colors.white,
          //         width: mediaQuery.size.width,
          //         height: (mediaQuery.size.height - mediaQuery.padding.top),
          //         child: Center(
          //             child: Padding(
          //                 padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
          //                 child: LoadingIndicator(
          //                   indicatorType: Indicator.ballPulse,
          //                   backgroundColor: Colors.white,
          //                 ))),
          //       )
          //   :
            _historyLength <= 0 ? 
            Container(
              child: Container(
                  width: 500,
                  padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                  margin: const EdgeInsets.fromLTRB(25, 30, 25, 15),
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
          : History()
          )
      
      ],
    ),
    );
  }
}
