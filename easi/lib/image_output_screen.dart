import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageScreen extends StatefulWidget {
  final selectedFile;
  final extractedText;
  final recognizedText;
  final elements;
  final lines;

  const ImageScreen(this.selectedFile, this.extractedText, this.recognizedText,
      this.elements, this.lines,
      {Key? key})
      : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  var _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";

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

    // final FirebaseVisionImage visionImage =
    //     FirebaseVisionImage.fromFile(imageFile);

    // final TextRecognizer textRecognizer =
    //     FirebaseVision.instance.textRecognizer();

    // final VisionText visionText =
    //     await textRecognizer.processImage(visionImage);

    // String pattern =
    //     r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    // RegExp regEx = RegExp(pattern);

    // String mailAddress = "";
    // for (TextBlock block in recognizedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     if (regEx.hasMatch(line.text)) {
    //       mailAddress += line.text + '\n';
    //       for (TextElement element in line.elements) {
    //         _elements.add(element);
    //       }
    //     }
    //   }
    // }

    if (this.mounted) {
      setState(() {
        recognizedText = widget.extractedText;
      });
    }
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  Widget getImageWidget() {
    if (widget.selectedFile != null) {
      return Image.file(
        widget.selectedFile,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return Text("Wala image");
    }
  }

  // widget._selectedFile
  @override
  Widget build(BuildContext context) {
    return _imageSize != null
        ? Stack(
            children: <Widget>[
              Center(
                child: Container(
                  width: double.maxFinite,
                  color: Colors.black,
                  child: CustomPaint(
                    foregroundPainter: TextDetectorPainter(
                        _imageSize, widget.elements, widget.lines),
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
                  elevation: 13,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(),
                        Container(
                          height: 60,
                          child: SingleChildScrollView(
                            child: Text(
                              recognizedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements, this.lines);

  final Size absoluteImageSize;
  final List<TextElement> elements;
  final List<TextLine> lines;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

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

    // Color in each element
    // for (TextElement element in elements) {
    //   canvas.drawRect(scaleRect(element), paint);
    // }

    // Color in whole line
    for (TextLine line in lines) {
      canvas.drawRect(scaleRect(line), paint);
    }

    // Draw text 
    for (TextLine line in lines) {
      // replace line.text with the simplified text
      drawName(canvas, line.text, scaleRect(line).height,
          scaleRect(line).left, scaleRect(line).top);
    }

  }

  void drawName(Canvas context, String text, double size, double x, double y) {
    TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: size - 3,
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
