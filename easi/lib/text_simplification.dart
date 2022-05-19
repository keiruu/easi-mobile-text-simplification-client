import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'http_methods.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'main.dart';

class TextSimplification extends StatefulWidget {
  @override
  _TextSimplificationState createState() => _TextSimplificationState();
}

class _TextSimplificationState extends State<TextSimplification> {
  TextEditingController inputController = TextEditingController();
  var simplifiedResult;
  String simplified = "";
  String prompt = "";
  bool loading = false;

  void setPrompt() {
    setState(() {
      prompt = inputController.text;
    });
  }

  void setSimplifiedText(prompt) async {
    try {
      setState(() {
        loading = true;
      });

      simplifiedResult = await postSimplifyText(prompt);
      setState(() {
        simplified = simplifiedResult;
        loading = false;
      });
    } catch (e) {
      print("Error simplifying text");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                  )))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: inputController,
                      maxLines: 10,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter text to simplify'),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.all(15),
                  //   child: TextField(
                  //     minLines: 1,
                  //     maxLines: 100,
                  //     enabled: false,
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       hintText: '$simplified',
                  //     ),
                  //   ),
                  // ),
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
                        child: Text(
                          '$simplified',
                          style: TextStyle(fontSize: 16.0),
                        )),
                  ),
                  Padding(
                      padding: EdgeInsets.all(15),
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.fromLTRB(138, 13, 138, 13)),
                        ),
                        onPressed: () {
                          setPrompt();
                          setSimplifiedText(prompt);
                        },
                        child: Text('Simplify'),
                      )),
                  Padding(
                      padding: EdgeInsets.all(2),
                      child: TextButton(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.fromLTRB(138, 13, 138, 13)),
                        ),
                        onPressed: () {
                          // CODE TO PUSH TO A NEW SCREEN
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //       Camera(),
                          //   ),
                          // );
                        },
                        child: Text('Camera'),
                      )),
                ],
              ),
            ),
    );
  }
}
