// ignore_for_file: prefer_const_constructors

import 'package:easi/image_output_screen.dart';
import 'package:easi/select_text_in_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'history_home_ui.dart';
import 'home_history.dart';
import 'navigation.dart';
import 'text_simplification.dart';
import 'image_output_screen.dart';
import 'dart:io';
import 'http_methods.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easi/globals.dart' as globals;
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // User? user = FirebaseAuth.instance.currentUser;
  // UserModel loggedInUser = UserModel();
  var userExists;
  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference dbRef;
  User? currentUser;
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

//shows user info sa may homepage
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('history');
    currentUser = AuthService().getCurrentUser();
    print("current user");
    print(currentUser?.displayName);
  }

  String userName = "User";
  var _selectedFile;
  bool _scanningText = false;
  var _extractedText;

  // Saves image to gallery
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

  void pushHistory(String prompt, String simplified, uid) {
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
    dbRef.push().set({
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

  // OCR Scanner using Google ML Kit
  getRecognizedText(final inputImage, String? uid) async {
    final textDetector = GoogleMlKit.vision.textRecognizer();
    List<TextElement> _elements = [];
    List<TextLine> _lines = [];
    final results;

    // Processes image
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    String scannedText = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // Checks if the last character of the line is "-"
        // ex. "Gusto ko maging hat-
        // ex. dog ngayon."
        // then it will join it with the next word instead of adding a space
        String currentLine = "";
        var checker = line.text.substring(line.text.length - 1);

        if (checker == "-") {
          currentLine = line.text.substring(0, line.text.length - 1);
          scannedText = scannedText + currentLine;
        } else {
          currentLine = line.text;
          scannedText = scannedText + currentLine + " ";
        }

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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageSelect(_selectedFile, _extractedText,
            recognizedText, _elements, _lines),
      ),
    );
  }

  // Code for loading image from camera or gallery and showing the crop tool
  getImage(ImageSource source, String? uid) async {
    // this.setState(() {
    //   globals.inProcess = true;
    // });

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
          // _inProcess = false;
          _scanningText = true;
        });

        globals.inProcess = false;
      }

      // Send text for extraction
      if (_selectedFile != null) {
        final inputImage = InputImage.fromFile(_selectedFile);
        getRecognizedText(inputImage, uid);
        this.setState(() {
          globals.inProcess = false;
        });
      }
    } else {
      // this.setState(() {
      //   _inProcess = false;
      // });
      globals.inProcess = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // For calculating total height of screen
    final mediaQuery = MediaQuery.of(context);
    final authService = Provider.of<AuthService>(context);
    // final name = FirebaseAuth.instance.currentUser?.displayName;
    // final uid = FirebaseAuth.instance.currentUser?.uid;
    // User? user = FirebaseAuth.instance.currentUser;

    var userExists = "";
    return Material(
      color: Color(0xFFF6F6F8),
      child: Stack(
        children: <Widget>[
          Padding(
                  padding: EdgeInsets.fromLTRB(32, 80, 32, 0),
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
                            Text('${currentUser?.displayName} 👋',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Color(0xFF5274AE)))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Choose how you want to enter words:",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF232253),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TextSimplification(),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 180.0,
                                      width: 140.0,
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/words.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Words by Typing",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFC2A534),
                                      ),
                                    ),
                                  ],
                                )),
                            Spacer(),
                            InkWell(
                                onTap: () {
                                  BuildContext dialogContext = context;
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(14.0))),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                30, 40, 30, 40),
                                            height: 200,
                                            child: Column(
                                              mainAxisAlignment:
                                                  _selectedFile != null
                                                      ? MainAxisAlignment
                                                          .spaceEvenly
                                                      : MainAxisAlignment
                                                          .spaceBetween,
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Color(0xFFFFF6D1),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15,
                                                              horizontal: 5),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          9.0))),
                                                      minimumSize:
                                                          Size.fromHeight(40)),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        dialogContext);
                                                    getImage(ImageSource.camera,
                                                        currentUser?.uid);
                                                  },
                                                  child: Text('Camera',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFF3D55E),
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Color(0xFFF8E2EC),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15,
                                                              horizontal: 5),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          9.0))),
                                                      minimumSize:
                                                          Size.fromHeight(40)),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        dialogContext);
                                                    getImage(
                                                        ImageSource.gallery,
                                                        currentUser?.uid);
                                                  },
                                                  child: Text('Gallery',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFFE95C6),
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 180.0,
                                      width: 140.0,
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/pics.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Words by Picture",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6FAEF2)),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("HISTORY",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFCFCFCF),
                                  fontWeight: FontWeight.w600)
                            ),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Navigation(selectedIndex: 1),
                                ),
                              )
                            },
                            child: Text("See All",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                  color: Color(0xFF232253),)
                            ),
                          )
                        ],
                      )
                      ),
                      HomeHistoryUI(),
                      // Container(
                      //   width: 500,
                      //   padding: const EdgeInsets.fromLTRB(0, 25, 0, 20),
                      //   margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      //   decoration: BoxDecoration(
                      //       border: Border.all(color: Color(0xFFCFCFCF)),
                      //       borderRadius: BorderRadius.circular(15)),
                      //   // child: Column(children: [
                      //   //   // Insert code for conditional rendering, if may history ang user or wala
                      //   //   Text("You haven't simplified any text yet.",
                      //   //       style: TextStyle(color: Color(0xFF232253)))
                      //   // ]),
                      //   child: History(),
                      // ),
                      // Container(
                      //   width: 500,
                      //   child: History(),
                      // )
                    ],
                  ),
                ),
          _scanningText
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
              : Container(
                  child: null,
                ),
        ],
      ),
    );
  }
}
