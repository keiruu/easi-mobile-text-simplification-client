import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/model/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.userKey}) : super(key: key);
  final String userKey;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //for updating user info
  final userNameController = TextEditingController();
  final userEmailController = TextEditingController();
  final userPasswordController = TextEditingController();
  final userConfirmpasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String _dp = "", _email = "";
  User? user = FirebaseAuth.instance.currentUser;
  // UserModel loggedInUser = UserModel();
  late DatabaseReference dbRef;
  var userExists;

  @override
  void dispose() {
    userNameController.dispose();
    userEmailController.dispose();
    userPasswordController.dispose();
    userConfirmpasswordController.dispose();

    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Get user info from the real time database
    dbRef = FirebaseDatabase.instance.ref().child('Users');
    // userNameController.addListener(_change);
    // userEmailController.addListener(_change);
    //Shows user information from the database'
    // FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(user!.uid)
    //     .get()
    //     .then((value) {
    //   loggedInUser = UserModel.fromMap(value.data());
    //   setState(() {
    //     userExists = loggedInUser;
    //   });
    // });
  }

  // void _change() {
  //   setState(() {
  //     _dp = userNameController.text;
  //     _email = userEmailController.text;
  //   });
  // }

  // void _authChange(dp, email) {
  //   setState(() {
  //     _dp = dp;
  //     _email = email;
  //   });
  // }

//  This is the code for update. Need gd anay butang ang Email, Password kag fullname sa realtime database
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authService = Provider.of<AuthService>(context);

    return Column(children: [
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(25, 100, 0, 20),
        child: Text(
          "Edit Profile",
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: TextFormField(
          autofocus: false,
          controller: userNameController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              labelText: "Name",
              hintText: "Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )),
        ),
      ),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: TextFormField(
            autofocus: false,
            controller: userEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail),
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: 'Email',
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: TextFormField(
            autofocus: false,
            controller: userPasswordController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              labelText: 'Password',
              hintText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                      style: BorderStyle.none, color: Color(0xFFCFCFCF))),
            ),
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: TextFormField(
            autofocus: false,
            controller: userConfirmpasswordController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                labelText: 'Confirm Password',
                hintText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          )),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: MaterialButton(
          onPressed: () async {
            // Map<String, String> students = {
            //   'Name': userNameController.text,
            //   'Email': userEmailController.text,
            //   'Password': userPasswordController.text,
            //   'Confirm Password': userConfirmpasswordController.text
            // };
            await authService.updateProfile(
                userNameController.text,
                userEmailController.text,
                userPasswordController.text,
                userConfirmpasswordController.text);
            // updateUser(
            //     userNameController.text,
            //     userEmailController.text,
            //     userPasswordController.text,
            //     userConfirmpasswordController.text);
            // dbRef.child(widget.UserKey).update(students)
            // .then((value) => {
            //     Navigator.pop(context)
            // });
          },
          child: const Text('Save'),
          color: Color(0xFFCDDBF2),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          textColor: Color(0xFF5274AE),
          minWidth: 320,
          height: 40,
          elevation: 0,
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: MaterialButton(
          onPressed: () async {
            await authService.signout();
          },
          child: const Text('Sign out'),
          color: Color(0xFFCDDBF2),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          textColor: Color(0xFF5274AE),
          minWidth: 320,
          height: 40,
          elevation: 0,
        ),
      )
    ]);
  }
}
