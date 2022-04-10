import 'package:flutter/material.dart';
import 'http-methods.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Easi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController inputController = TextEditingController(); 
  var simplifiedResult;
  String simplified = "";
  String prompt = "";

  void setPrompt() {
    setState(() {
      prompt = inputController.text;
    });
  }

  void setSimplifiedText(prompt) async{
    try {
      simplifiedResult = await postSimplifyText(prompt);
      setState(() {
        simplified = simplifiedResult;
      });
    } catch (e) {
      print("Error simplifying text");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
                  hintText: 'Enter text to simplify'
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15), 
              child: TextField(
                minLines: 1,
                maxLines: 100,
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '$simplified',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.fromLTRB(138, 13, 138, 13)
                  ),
                ),
                onPressed: () {
                  setPrompt();
                  setSimplifiedText(prompt);
                },
                child: Text('Simplify'),
              )
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}