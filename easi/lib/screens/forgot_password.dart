// ignore_for_file: unused_import, await_only_futures, prefer_const_constructors, deprecated_member_use, avoid_unnecessary_containers, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registration_screen.dart';
import 'package:provider/provider.dart';
import 'package:easi/home.dart';
import '../google_sign_in.dart';
import 'package:easi/main.dart';
import '../navigation.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _rememberMe = false;
  //form key
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  //firebase
  final _auth = FirebaseAuth.instance;
  //Displays error message
  String? errorMessage;
  get onPressed => null;

  @override
  void dispose() {
    emailController.dispose();
    print('Dispose used');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    //email
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,

      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter your Email");
        }
        //reg expression for eail validation
        else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
            .hasMatch(value)) {
          return ("Please Enter your Email");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },
      //Email
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: 'Email',
        hintText: "Email",
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCFCFCF))),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1976D2))),
      ),
    );

    final materialButton = MaterialButton(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      minWidth: MediaQuery.of(context).size.width,
      onPressed: () async {
        try {
          await authService
            .sendPasswordResetEmail( emailController.text)
            .then((value) => Fluttertoast.showToast(msg: "Password Reset Email sent"))
            .catchError((e) => Fluttertoast.showToast(msg: "Something went wrong, please check the email you typed if it is registered."));
        } on FirebaseAuthException catch (error) {
          switch (error.code) {
            case "invalid-email":
              errorMessage = "Whoops! Please check how your email is written";
              break;
            case "wrong-password":
              errorMessage =
                  "Sorry can't let you in, you entered the wrong password";
              break;
            case "user-not-found":
              errorMessage =
                  "Seems like you're new here. Maybe try to sign up first.";
              break;
            case "user-disabled":
              errorMessage =
                  "Oh no! We think you got disabled, please sign up again instead.";
              break;
            case "too-many-requests":
              errorMessage =
                  "There's too much of you trying to log in, please try again after a while.";
              break;
            case "operation-not-allowed":
              errorMessage =
                  "We can't sign you in at the moment, please try again.";
              break;
            default:
              errorMessage =
                  "Oh no! Something wrong happened, please try again.";
          }
          Fluttertoast.showToast(msg: errorMessage!);
          print(error.code);
        }
      },
        child: Container(
            alignment: Alignment.center,
            child: Text(
              'Send',
              style: TextStyle(
                color: (Colors.white),
              ),
            )),
      );

    final sendButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(5),
      color: Color(0xFF1976D2),
      child: materialButton,
    );


    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 60),
        child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 50),
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF5274AE),
                      size: 36,
                    ),
                  ),
                ),
                Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.fromLTRB(0, 30, 30, 10),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28),
                                )),
                            Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 40),
                                child: const Text(
                                  'Enter the email you use and we\'ll send a link to reset your password',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12),
                            )),
                            emailField,
                            SizedBox(height: 40),
                            sendButton,
                            SizedBox(height: 10),
                          ]
                        )
                      ),
                ))
              ],
            )
          ),
        ),
    );
  }
}

// ignore: non_constant_identifier_names
HomeScreen() {}
