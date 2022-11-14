// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  var _historyText = "";

  late DatabaseReference dbRef;
  var _history;
  int _historyLength = 0;

  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

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
          _history = data;
          _historyLength = data.length;
        });
      }

      _history.forEach((index) {
        if (index["result"].length > 60) {
          index["placeholder"] = index["result"].substring(0, 60) + "...";
        } else {
          index["placeholder"] = index["result"];
        }
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _historyLength,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: InkWell(
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoryDetails(historyDetails: _history[index]),
                    ),
                  )
                },
                child: Row(
                  children: [
                    Container(
                      width: 240,
                      child: Text("${_history[index]["placeholder"]}"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.navigate_next),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}

class HistoryDetails extends StatelessWidget {
  const HistoryDetails({Key? key, required this.historyDetails});

  final historyDetails;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   title: Image.asset(
        //     'assets/logo.png',
        //     height: 35,
        //     width: 35,
        //   ),
        //   centerTitle: true,
        // ),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: EdgeInsets.fromLTRB(15, 50, 15, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF5274AE),
                      size: 36,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: SingleChildScrollView(
                      child: Container(
                          height: 200,
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 111, 111, 111),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(3)),
                          child: SingleChildScrollView(
                              child: Text(
                            '${historyDetails["prompt"]}',
                            style: TextStyle(fontSize: 16.0),
                          )))),
                ),
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Container(
                      height: 200,
                      margin: const EdgeInsets.all(15.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 111, 111, 111),
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(3)),
                      child: SingleChildScrollView(
                          child: Text(
                        '${historyDetails["result"]}',
                        style: TextStyle(fontSize: 16.0),
                      ))),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Text("${historyDetails["date"]}",
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          )),
        ));
  }
}
