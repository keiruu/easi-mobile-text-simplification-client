import 'package:flutter/material.dart';

class InternetNotAvailable extends StatelessWidget {
  const InternetNotAvailable({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Material(
      child: Stack(
      children: [
        Container(
          height: mediaQuery.size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 200),
                  child: Image.asset(
                    'assets/no_internet.png',
                    height: 235,
                    width: 235,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                  child: Text("Whoops!", style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Inter', fontWeight: FontWeight.w500),),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                  child: Text("Slow or no internet connection, please check your internet settings", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Inter', fontWeight: FontWeight.normal))
                )
              ],
            ),
          ),
        )
      ],
    ),
    );
  }
}
