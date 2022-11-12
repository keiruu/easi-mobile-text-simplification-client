import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:touchable/touchable.dart';
import 'auth_service.dart';
import 'home.dart';
import 'http_methods.dart';
import 'image_output_screen.dart';

class ImageSelect extends StatefulWidget {
  final selectedFile;
  final extractedText;
  final recognizedText;
  final elements;
  final lines;

  const ImageSelect(this.selectedFile, this.extractedText, this.recognizedText,
      this.elements, this.lines,
      {Key? key})
      : super(key: key);

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class PaintingController extends ChangeNotifier {
  int trigger = 0;
  List<TextElement> elements = [];
  List elementState = [];
  List textToExtract = [];
  String extracted = "";
  bool loadState = false;

  void controlTrigger() {
    trigger += 1;
    notifyListeners();
  }

  void resetTrigger() {
    trigger = 0;
    notifyListeners();
  }

  void changeState(int i, bool stateChange) {
    elementState[i] = stateChange;
    print(elementState);
    notifyListeners();
  }

  void setter(List<TextElement> el) {
    for (TextElement element in el) {
      elements.add(element);
      elementState.add(false);
    }
    notifyListeners();
  }
}

class _ImageSelectState extends State<ImageSelect> {
  var _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";
  bool loading = false;
  var simplifiedResult;
  String simplify = "";
  int clicked = 0;
  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference dbRef;
  User? currentUser;

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  void _initializeVision() async {
    final File imageFile = widget.selectedFile;

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    if (this.mounted) {
      setState(() {
        recognizedText = widget.extractedText;
      });
    }
  }

  @override
  void initState() {
    _initializeVision();
    dbRef = FirebaseDatabase.instance.ref().child('history');
    currentUser = AuthService().getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return !authService.loading
        ? _imageSize != null
            ? ChangeNotifierProvider<PaintingController>(
                create: (context) => PaintingController(),
                child: Consumer<PaintingController>(
                    builder: (context, controller, child) => Material(
                        color: Colors.black,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.fromLTRB(30, 150, 30, 0),
                              child: Text(
                                  "Tap on the boxes to select",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      backgroundColor: Colors.blue)),
                            ),
                            Center(
                              child: Container(
                                  width: double.maxFinite,
                                  color: Colors.black,
                                  child: GestureDetector(
                                    onTapDown: (details) {
                                      setState(() {
                                        clicked = clicked + 1;
                                      });
                                      print("HERE");
                                      print(clicked);
                                    },
                                    child: Container(
                                      child: CanvasTouchDetector(
                                        gesturesToOverride: [
                                          GestureType.onPanDown
                                        ],
                                        builder: (context) => CustomPaint(
                                          foregroundPainter:
                                              TextDetectorPainter(
                                                  clicked,
                                                  context,
                                                  _imageSize,
                                                  widget.elements,
                                                  widget.lines),
                                          child: AspectRatio(
                                            aspectRatio: _imageSize.aspectRatio,
                                            child: Image.file(
                                              // File(path),
                                              widget.selectedFile,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                            NextBtn(
                                context: context,
                                recognizedText: widget.recognizedText,
                                selectedFile: widget.selectedFile,
                                extractedText: widget.extractedText,
                                elements: widget.elements,
                                ref: dbRef,
                                uid: currentUser?.uid)
                          ],
                        ))))
            : Center(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                    )))
        : ChangeNotifierProvider<PaintingController>(
            create: (context) => PaintingController(),
            child: Consumer<PaintingController>(
                builder: (context, controller, child) => Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                        )))));
  }
}

class NextBtn extends StatelessWidget {
  NextBtn(
      {Key? key,
      required this.context,
      this.recognizedText,
      this.selectedFile,
      this.extractedText,
      this.elements,
      required this.ref,
      this.uid})
      : controller = Provider.of<PaintingController>(context, listen: false);

  final PaintingController controller;
  BuildContext context;
  final recognizedText;
  final extractedText;
  final elements;
  final selectedFile;
  final DatabaseReference ref;
  final uid;

  void pushHistory(String prompt, String simplified) {
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
    ref.push().set({
      "prompt": prompt,
      "result": simplified,
      "userUID": uid,
      "placeholder": " ",
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
    final mediaQuery = MediaQuery.of(context);
    print("HERHER");
    print(authService.loading);

    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.fromLTRB(5, 0, 0, 40),
                child: MaterialButton(
                  color: Color.fromARGB(255, 102, 105, 108),
                  onPressed: () {
                    for (var i = 0; i < controller.elementState.length; i++) {
                      controller.elementState[i] = false;
                    }
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Unselect all",
                        style: TextStyle(color: Colors.white),
                      )),
                )),
            Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    for (var i = 0; i < controller.elementState.length; i++) {
                      controller.elementState[i] = true;
                    }
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Select all",
                        style: TextStyle(color: Colors.white),
                      )),
                )),
            Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: MaterialButton(
                  color: Colors.blue,
                  shape: const CircleBorder(),
                  onPressed: () async {
                    controller.loadState = true;
                    print(controller.loadState);
                    for (var i = 0; i < controller.elementState.length; i++) {
                      if (controller.elementState[i] == true) {
                        controller.textToExtract
                            .add(controller.elements[i].text.toString());
                      }
                    }

                    controller.textToExtract.forEach((element) {
                      controller.extracted += element + " ";
                    });

                    Fluttertoast.showToast(
                        msg:
                            "Loading. Please wait.");
                    String results =
                        await postSimplifyText(controller.extracted);
                    pushHistory(controller.extracted, results);
                    List<TextLine> _lines = [];

                    for (TextBlock block in recognizedText.blocks) {
                      for (TextLine line in block.lines) {
                        _lines.add(line);
                      }
                    }

                    print("text toi extratc");
                    print(controller.textToExtract);

                    controller.loadState = false;
                    print(controller.loadState);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageScreen(
                            selectedFile,
                            extractedText,
                            controller.extracted,
                            recognizedText,
                            elements,
                            _lines,
                            results),
                      ),
                    );
                    print(":clicked");
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                        size: 30,
                      )),
                ))
          ],
        ),
        controller.loadState
            ? Container(
                color: Colors.white,
                width: mediaQuery.size.width,
                height: (mediaQuery.size.height - mediaQuery.padding.top),
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                          backgroundColor: Colors.white,
                        ))),
              )
            : Container(),
      ],
    );
  }
}

// FOR AR OVERLAY
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.clicked, this.context, this.absoluteImageSize,
      this.elements, this.lines)
      : controller = Provider.of<PaintingController>(context, listen: false);
  final _ImageSelectState imgstate = new _ImageSelectState();

  final PaintingController controller;
  int clicked;
  BuildContext context;
  final Size absoluteImageSize;
  final List<TextElement> elements;
  final List<TextLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;
    final List<TextLine> newLines;
    var myCanvas = TouchyCanvas(context, canvas);

    if (controller.elements.isEmpty) {
      for (TextElement element in elements) {
        controller.elements.add(element);
        controller.elementState.add(false);
      }
    }

    Rect scaleRect(container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromARGB(0, 38, 176, 255)
      ..strokeWidth = 2.0;

    final Paint paintBorder = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 2.0;

    final Paint paintBorderClicked = Paint()
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 125, 255, 192)
      ..strokeWidth = 2.0;

    // Color in each element (word)
    for (var i = 0; i < controller.elementState.length; i++) {
      myCanvas.drawRect(scaleRect(controller.elements[i]), paintBorder);

      if (controller.elementState[i] == false) {
        myCanvas.drawRect(scaleRect(controller.elements[i]), paintBorder);
      } else if (controller.elementState[i] == true) {
        myCanvas.drawRect(
            scaleRect(controller.elements[i]), paintBorderClicked);
      }

      // Draws a selectable rect that is transparent
      myCanvas.drawRect(scaleRect(controller.elements[i]), paintFill,
          onPanDown: (_) {
        controller.changeState(i, !controller.elementState[i]);
      });
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    // return true;
    // print(oldDelegate.clicked != clicked);
    // print("OLD");
    // print(oldDelegate._trigger);
    // print("NEW");
    // print(_trigger);
    // print(oldDelegate._trigger != _trigger);
    return oldDelegate.clicked != clicked;
  }
}
