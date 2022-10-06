// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:convert';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  var _historyText = "";
  getHistory() {
    this.setState(() {
      _historyText =
          "loT devices are usually constrained in terms of computing and storage resources. ";
    });

    // Shortens text to be displayed
    if (_historyText.length > 60) {
      print(_historyText.length);
      this.setState(() {
        _historyText = _historyText.substring(0, 60) + "...";
      });
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: InkWell(
          child: Row(
            children: [
              Container(
                width: 240,
                child: Text(_historyText),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.navigate_next),
              )
            ],
          ),
        )
      ),
    );
  }
}
