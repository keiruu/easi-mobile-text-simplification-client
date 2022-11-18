import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'http_methods.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TextSimplification extends StatefulWidget {
  @override
  _TextSimplificationState createState() => _TextSimplificationState();
}

class _TextSimplificationState extends State<TextSimplification> {
  TextEditingController inputController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference dbRef;
  // UserModel loggedInUser = UserModel();
  var simplifiedResult;

  String? uid;
  String simplified = "";
  String prompt = "";
  bool loading = false;
  bool over = false;
  int counter = 0;

  // Gets prompt from textfield
  void setPrompt() {
    setState(() {
      prompt = inputController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('history');
  }

  // Calls function to simplify text (from http_methods.dart)
  void setSimplifiedText(prompt, uid) async {
    try {
      setState(() {
        loading = true;
      });

      simplifiedResult = await postSimplifyText(prompt);
      setState(() {
        simplified = simplifiedResult;
        loading = false;
      });
      pushHistory(uid);
    } catch (e) {
      print("Error simplifying text");
      print(e);
    }
  }

  void pushHistory(uid) {
    DateTime now = DateTime.now();
    var MONTHS = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    print(simplified);

    String placeholder = "";
    // if (simplified.length > 60) {
    //   placeholder = simplified.substring(0, 60) + "...";
    // } else {
    //   placeholder = simplified + "...";
    // }

    dbRef.push().set({
      "prompt": prompt,
      "result": simplified,
      "userUID": uid,
      "placeholder": "",
      // "time": now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString(),
      "date": now.day.toString() +
          " " +
          MONTHS[now.month - 1] +
          " " +
          now.year.toString() +
          " " +
          now.hour.toString() +
          ":" +
          now.minute.toString() +
          ":" +
          now.second.toString()
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
        body: loading
            ? const Center(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                    )))
            : SingleChildScrollView(
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
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: TextField(
                              onChanged: (value) => {
                                setState(() => {counter = value.length}),
                                if (value.length > 300)
                                  {
                                    setState(() => {over = true})
                                  }
                                else
                                  {
                                    setState(() => {over = false})
                                  }
                              },
                              controller: inputController,
                              maxLines: 10,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Enter text you want to understand better.'),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(25),
                              child: Text("$counter/300",
                                  style: TextStyle(
                                      color:
                                          over ? Colors.red : Colors.black))),
                        ],
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
                              '$simplified',
                              style: TextStyle(fontSize: 16.0),
                            ))),
                      ),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: TextButton(
                            style: ButtonStyle(
                              foregroundColor: over
                                  ? MaterialStateProperty.all<Color>(
                                      Color.fromARGB(255, 237, 237, 237))
                                  : MaterialStateProperty.all<Color>(
                                      Color(0xFF5274AE)),
                              backgroundColor: over
                                  ? MaterialStateProperty.all<Color>(
                                      Color.fromARGB(255, 216, 216, 216))
                                  : MaterialStateProperty.all<Color>(
                                      Color(0xFFCDDBF2)),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(123, 25, 123, 25)),
                            ),
                            onPressed: over
                                ? null
                                : () async {
                                    setPrompt();
                                    setSimplifiedText(prompt, authService.uid);
                                    // dbRef.push().set(simplifiedResult);
                                    // dbRef.push().set(uid);
                                  },
                            child: Text('Simplify'),
                          )),
                    ],
                  ),
                )),
              ));
  }
}
