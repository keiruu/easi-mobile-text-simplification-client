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
  bool over = false;
  int counter = 0;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 35,
          width: 35,
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                  )))
          : Center(
              child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
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
                                  color: over ? Colors.red : Colors.black))),
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
                        child: Text(
                          '$simplified',
                          style: TextStyle(fontSize: 16.0),
                        )),
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
                            : () {
                                setPrompt();
                                setSimplifiedText(prompt);
                              },
                        child: Text('Simplify'),
                      )),
                ],
              ),
            )),
    );
  }
}
