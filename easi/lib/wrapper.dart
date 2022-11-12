import 'package:easi/main.dart';
import 'package:easi/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'model/user_model.dart';
import 'navigation.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<UserModel?>(
        stream: authService.user,
        builder: (_, AsyncSnapshot<UserModel?> snapshot) {
          // if (snapshot.connectionState == ConnectionState.active) {
          //   final UserModel? user = snapshot.data; // does user have data
          //   return user == null ? LoginScreen() : MyHomePage();
          // } else {
          //   return Container(
          //     color: Colors.white,
          //     width: mediaQuery.size.width,
          //     height: (mediaQuery.size.height - 56),
          //     child: Center(
          //         child: Padding(
          //             padding: EdgeInsets.fromLTRB(150, 0, 150, 0),
          //             child: LoadingIndicator(
          //               indicatorType: Indicator.ballPulse,
          //               backgroundColor: Colors.white,
          //             ))),
          //   );
          // }
          final UserModel? user = snapshot.data; // does user have data
          print(user);
          return user == null ? LoginScreen() : Navigation(selectedIndex: 0);
        });
  }
}
