import 'package:easi/image_output_screen.dart';

import 'main.dart';
import 'words_in_picture.dart';
import 'text_simplification.dart';
import 'image_output_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = "User";
  var _selectedFile;
  bool _inProcess = false;
  bool _scanningText = false;
  var _extractedText;

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return Text("Wala image");
    }
  }

  saveImage() async {
    int currentUnix = DateTime.now().millisecondsSinceEpoch;

    final directory = await getApplicationDocumentsDirectory();

    String fileFormat = _selectedFile.path.split('.').last;

    print(fileFormat);

    await _selectedFile.copy(
      '${directory.path}/$currentUnix.$fileFormat',
    );
    print(directory.path);
    print(currentUnix);

    // Link to solution: https://stackoverflow.com/questions/68046612/flutter-image-gallery-saver-image-not-showing-after-saving
    // Saves image to local storage after saving it to app directory storage
    try {
      bool? isImageSaved = await GallerySaver.saveImage(
          '${directory.path}/$currentUnix.$fileFormat',
          albumName: "easi");
    } catch (exception) {
      print("Error $exception");
    }
  }

  getRecognizedText(final inputImage) async {
    final textDetector = GoogleMlKit.vision.textRecognizer();
    List<TextElement> _elements = [];
    List<TextLine> _lines = [];

    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    String scannedText = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
        _lines.add(line);
        for (TextElement element in line.elements) {
            _elements.add(element);
        }
      }
    }

    setState(() {
      _extractedText = scannedText;
      _scanningText = false;
    });
    print(_extractedText);

    // Save cropped image
    // saveImage();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageScreen(_selectedFile, _extractedText, recognizedText, _elements, _lines),
      ),
    );
    // Send scanned text to backend. Refer to text_simplification.dart for the process.
    // After that take the translated text and manage to display it over the image you took.
    // Additional is to change from cropped image to select certain or multiple sentences in a picture.
    // More stuff to add, maybe a dictionary? or something to display for learners to read better.
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });

    final ImagePicker _picker = ImagePicker();

    final XFile? image = await _picker.pickImage(source: source);
    // File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      // ImageCropper().cropImage(sourcePath: sourcePath)
      var cropped = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepPurpleAccent,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false)
          ]);

      if (cropped != null) {
        this.setState(() {
          _selectedFile = File(cropped.path);
          _inProcess = false;
          _scanningText = true;
        });
      }

      // Send text for extraction
      final inputImage = InputImage.fromFile(_selectedFile);
      getRecognizedText(inputImage);
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(35, 5, 35, 0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'Hi ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF232253)),
                ),
                Text('$userName 👋',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF5274AE)))
              ],
            ),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome to Easi.',
                style: TextStyle(fontSize: 15, color: Color(0xFF6E7683)),
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
              height: 120,
              width: 291,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/header.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: (Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text("Making it\nsimple for you.",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ))),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Choose how you want to enter words:",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF232253),
                    fontWeight: FontWeight.w600)),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TextSimplification(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                  padding: EdgeInsets.fromLTRB(15, 70, 50, 20),
                  decoration: BoxDecoration(
                      color: Color(0xFFFFF6D1),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "Type it",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF3D55E)),
                  ),
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14.0))),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(30, 40, 30, 40),
                            height: _selectedFile != null ? 500 : 200,
                            child: Column(
                              mainAxisAlignment: _selectedFile != null
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                // if(_selectedFile != null)
                                //   getImageWidget()
                                // ,
                                // if(_selectedFile != null)
                                //   Text (_extractedText,
                                //   style: TextStyle(
                                //           color: Color.fromARGB(255, 0, 0, 0),)
                                //   )
                                // ,
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Color(0xFFFFF6D1),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9.0))),
                                      minimumSize: Size.fromHeight(40)),
                                  onPressed: () {
                                    getImage(ImageSource.camera);
                                  },
                                  child: Text('Camera',
                                      style: TextStyle(
                                          color: Color(0xFFF3D55E),
                                          fontWeight: FontWeight.bold)),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Color(0xFFF8E2EC),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9.0))),
                                      minimumSize: Size.fromHeight(40)),
                                  onPressed: () {
                                    getImage(ImageSource.gallery);
                                  },
                                  child: Text('Gallery',
                                      style: TextStyle(
                                          color: Color(0xFFFE95C6),
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        );
                      });
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //       Modal(),
                  //   ),
                  // );
                  // Navigator.of(context).restorablePush(
                  //     MaterialPageRoute(
                  //       builder: (context) =>
                  //         WordsInPicture(),
                  //     ),
                  //   )
                  // );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                  padding: EdgeInsets.fromLTRB(15, 50, 45, 20),
                  decoration: BoxDecoration(
                      color: Color(0xFFF8E2EC),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text("Words in\npicture",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF8AC1))),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("History",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF232253),
                    fontWeight: FontWeight.w600)),
          ),
          Container(
            width: 500,
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFCFCFCF)),
                borderRadius: BorderRadius.circular(15)),
            child: Column(children: [
              // Insert code for conditional rendering, if may history ang user or wala
              Text("You haven't simplified any text yet.",
                  style: TextStyle(color: Color(0xFF232253)))
            ]),
          )
        ],
      ),
    );
  }
}
