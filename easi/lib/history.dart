// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    dbRef = FirebaseDatabase.instance.ref().child('history');
    final listed = dbRef.orderByChild("userUID").equalTo(uid);
    print("UasdasdasdadDI");
    print(uid);

    var data = [];
    listed.onValue.listen((event) {
      // final data = Map<String, dynamic>.from(
      //   event.snapshot.value as Map,
      // );

      for (final child in event.snapshot.children) {
        print(child.value);
        data.add(child.value);
      }
      // data.forEach((key, value) {
      //   print("$value");
      // });
      if (data != null) {
        // setState(() {
        //   _history = data.values.toList();
        //   _historyLength = data.values.toList().length;
        // });
         setState(() {
          _history = data;
          _historyLength = data.length;
        });
      }

      _history.forEach((index) {
        if (index["result"].length > 60) {
          index["result"] = index["result"].substring(0, 60) + "...";
        }

        print(index["result"]);
      });

      print(_history.length);
    });
    print("adasd");
    print(listed);
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => getHistory(_history, _historyLength));
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
                child: Row(
                  children: [
                    Container(
                      width: 240,
                      child: Text("${_history[index]["result"]}"),
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
