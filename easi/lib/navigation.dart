import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'history_ui.dart';
import 'home.dart';
import 'profile.dart';
import 'auth_service.dart';

class Navigation extends StatefulWidget {
  Navigation({Key? key, required this.selectedIndex});

  int selectedIndex;
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  User? user;
  List<Widget> _widgetOptions = <Widget>[];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = AuthService().getCurrentUser();
    _widgetOptions = <Widget>[
      Home(),
      HistoryUI(),
      ProfileHome(currentUser: user)
    ]; //Profile(userKey: '',)di ko sure kay ga error ang sa profile. Gn butangan lang sng userKey
  }

  // Bottom navigation screen options
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: Image.asset(
      //     'assets/logo.png',
      //     height: 35,
      //     width: 35,
      //   ),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
          child: Stack(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_widgetOptions.elementAt(widget.selectedIndex)],
        ),
      ])),
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
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
            icon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
        onTap: (index) {
          setState(() {
            widget.selectedIndex = index;
          });
        },
      )
      )
    );
  }
}
