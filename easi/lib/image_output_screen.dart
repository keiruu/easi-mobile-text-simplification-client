import 'package:easi/http_methods.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'http_methods.dart';
import 'main.dart';

class ImageScreen extends StatefulWidget {
  final selectedFile;
  final extractedText;
  final recognizedText;
  final elements;
  final lines;
  final results;
  final extracted;

  const ImageScreen(this.selectedFile, this.extractedText, this.recognizedText,
      this.extracted, this.elements, this.lines, this.results,
      {Key? key})
      : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  var _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";
  bool loading = false;
  var simplifiedResult;
  String simplify = "";

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

  void getSimplifiedText(prompt) async {
    try {
      simplifiedResult = await postSimplifyText(prompt);
      print("simplfied result");
      print(simplifiedResult);
      // return simplifiedResult;
    } catch (e) {
      print("Error simplifying text");
      print(e);
    }
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  // widget._selectedFile
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return !authService.loading
        ? _imageSize != null
            ? Stack(
                children: <Widget>[
                  Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.fromLTRB(0, 60, 0, 40),
                      child: MaterialButton(
                        color: Colors.blue,
                        shape: const CircleBorder(),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyHomePage(),
                            ),
                          );
                        },
                        child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 30,
                            )),
                      )),
                  Center(
                    child: Container(
                      width: double.maxFinite,
                      color: Colors.black,
                      child: CustomPaint(
                        foregroundPainter: TextDetectorPainter(
                            _imageSize,
                            widget.elements,
                            widget.lines,
                            widget.extractedText,
                            widget.results),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      elevation: 10,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(),
                            Container(
                              height: 100,
                              child: SingleChildScrollView(
                                child: Text(
                                  "Results: ${widget.results}",
                                ),
                              ),
                            ),
                            // Container(
                            //   height: 100,
                            //   child: SingleChildScrollView(
                            //     child: Text(
                            //       "Extracted text: ${widget.recognizedText}",
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                    )))
        : Center(
            child: Padding(
                padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                )));
  }
}

// FOR AR OVERLAY
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements, this.lines,
      this.extractedText, this.results);
  final _ImageScreenState imgstate = new _ImageScreenState();

  final Size absoluteImageSize;
  final List<TextElement> elements;
  final List<TextLine> lines;
  final extractedText;
  final results;

  @override
  void paint(Canvas canvas, Size size) async {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;
    final List<TextLine> newLines;
    List excess = [];

    Rect scaleRect(container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeWidth = 2.0;

    // Color in each element (word)
    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }

    // Color in whole line
    for (TextLine line in lines) {
      canvas.drawRect(scaleRect(line), paint);
    }

    // Get rid of next line so that it's all one paragraph
    final List noNextLine = results.split('\n');
    // Loop through the list and store into string.
    String wordsToBeSplit = "";
    for (var e in noNextLine) {
      wordsToBeSplit = wordsToBeSplit + e + " ";
    }

    // Now split that string and get the words.
    // A list of words in results
    final List words = wordsToBeSplit.split(' ');
    print(words);
    int len2 = words.length;
    print('Words $len2');
    int num = 0;
    int endLength = 0;
    String finalText = "";

    // for each line in the picture
    for (TextLine line in lines) {
      // lineSplit.length = pila ka words ara sa isa ka line.
      final List lineSplit = line.text.split(' ');
      String result = "";
      // print("Line split length $len");

      // for each word in the line
      for (var x = 0; x < lineSplit.length; x++) {
        // Stitches together the line based on the number of words sa original text
        // minus 2 kay for some reason sobra ang length sang results by 2
        if (num <= words.length && endLength <= words.length - 2) {
          result = result + words[num] + " ";
          num++;
          // Set end number
          endLength = num - 1;
          // print("End length $endLength");
          // print(result);
        }
      }

      // Display each line
      drawName(canvas, result, scaleRect(line).height, scaleRect(line).left,
          scaleRect(line).top);

      num = endLength + 1;
      finalText = result;
    }

    // if (endLength < words.length) {
    //   // excess.add(finalText.substring(words.length, endLength));
    //   print("yup");
    //   print(words.length);
    //   print("yup");
    //   print(endLength);
    // }
  }

  // Displays all the words processed as an AR Overlay
  void drawName(Canvas context, String text, double size, double x, double y) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: size ,
        ),
        text: text);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(context, Offset(x, y));
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
