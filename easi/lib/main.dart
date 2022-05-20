import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedFile;
  bool _inProcess = false;
  bool _scanningText = false;
  var extractedText;

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

    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    String scannedText = "";

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }

    setState(() {
      extractedText = scannedText;
      _scanningText = false;
    });
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

      // Save cropped image
      saveImage();
    } else {
      this.setState(() {
        _inProcess = false;
      });
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
            height: 50,
            width: 50,
          ),
          centerTitle: true,
        ),
      body: Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Home(),
            getImageWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    color: Colors.green,
                    child: Text(
                      "Camera",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      getImage(ImageSource.camera);
                    }),
                MaterialButton(
                    color: Colors.deepOrange,
                    child: Text(
                      "Device",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    }),
              ],
            ),
            Text('$extractedText')
          ],
        ),
        (_inProcess || _scanningText)
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.95,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Center()
      ],
    ));
  }
}
