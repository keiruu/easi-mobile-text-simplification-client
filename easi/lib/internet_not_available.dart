import 'package:flutter/material.dart';

class InternetNotAvailable extends StatelessWidget {
  const InternetNotAvailable({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Stack(
      children: [
        Container(
          height: mediaQuery.size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Center(
            child: Text(
                  'No Internet ConneADJHASKJHDJKSAction!!!',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
          ),
        )
      ],
    );
  }
}
