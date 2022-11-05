import 'package:easi/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/model/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class HistoryUI extends StatefulWidget {
  const HistoryUI({Key? key}) : super(key: key);

  @override
  _HistoryUIState createState() => _HistoryUIState();
}

class _HistoryUIState extends State<HistoryUI> {
 
  @override
  void initState() {
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
          child: Text("History 🕒", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 50),
          child: History(),
        )
      
      ],
    );
  }
}
