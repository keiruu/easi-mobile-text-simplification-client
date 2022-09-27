import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easi/globals.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';

import 'home.dart';
import 'words_in_picture.dart';
import 'profile.dart';

// void main() => runApp(MyApp());
void main() {
  // Transparent status bar
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Bottom navigation screen options
  List<Widget> _widgetOptions = <Widget>[Home(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: globals.inProcess ? null
      : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 35,
          width: 35,
        ),
        centerTitle: true,
      ),
      body: globals.inProcess ? 
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
            child: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
            )
          )
        )
      : Stack(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_widgetOptions.elementAt(_selectedIndex)],
        )
      ])
      ,
      bottomNavigationBar: globals.inProcess ? null
      : BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedIconTheme: IconThemeData(color: Colors.white, size: 25),
        selectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        backgroundColor: Color(0xFF5274AE),
        unselectedIconTheme: IconThemeData(color: Color(0xFF97ACCE), size: 25),
        unselectedItemColor: Color(0xFF97ACCE),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
