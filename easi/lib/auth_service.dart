import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/main.dart';
import 'package:easi/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'model/user_model.dart';
import 'navigation.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final inUser = auth.FirebaseAuth.instance.currentUser;
  var displayname;
  var uid;
  var email;
  var currentUser;

  bool loading = false;
  setLoading(bool state) {
    loading = state;
    // print(loading);
    return loading;
  }

  reloadUser() async {
    final User? user = _firebaseAuth.currentUser;
    // final uid = user?.uid;
    // print("UID");
    // print(uid);

    await user?.reload();
    return user;
  }

  getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    // final uid = user?.uid;
    // print("UID");
    // print(uid);

    // await user?.reload();
    return user;
  }

  // Future<User?> getCurrentUser() async {
  //   await inUser?.reload();
  //   User? user = inUser;
  //   user = await _firebaseAuth.currentUser;
  //   //print final version to console
  //   return user;
  // }

  UserModel? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    displayname = user.displayName;
    uid = user.uid;
    email = user.email;
    currentUser = user;
    return UserModel(user.uid, user.email, user.displayName);
  }

  Stream<UserModel?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return _userFromFirebase(credential.user);
  }

  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password, String displayname) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    User? user = credential.user;
    if (user != null) {
      //add display name for just created user
      await user.updateDisplayName(displayname);
      //get updated user
      await user.reload();
      user = await _firebaseAuth.currentUser;
      //print final version to console
      print("Registered user:");
      print(user);
    }

    return _userFromFirebase(credential.user);
  }

  Future<void> signout(context) async {
    await _firebaseAuth.signOut();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfile(String displayname, String email, String pass, String conpass, BuildContext context) async {
    Fluttertoast.showToast(msg: "Updating your profile");

    if (pass != "" || conpass != "") {
      if (pass == conpass) {
        try {
          User? user;
          user = _firebaseAuth.currentUser;
          if (email != "") {
            await user?.updateEmail(email);
          }
          if (displayname != "") {
            await user?.updateDisplayName(displayname);
          }
          if (pass != "") {
            await user?.updatePassword(pass);
          }

          await inUser?.reload();
          Fluttertoast.showToast(msg: "Successfully updated profile");
          //print final version to console
          print("Registered user:");
          print(user);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => Navigation(selectedIndex: 1),
          //   ),
          // );
        } on FirebaseAuthException catch (e) {
          Fluttertoast.showToast(msg: "Problem updating your profile");
          Fluttertoast.showToast(msg: e.message.toString());
        }
      } else {
        Fluttertoast.showToast(msg: "Oh no! Passwords don't match");
      }
    } else {
      try {
        if (email != "") {
          await inUser?.updateEmail(email);
        }
        if (displayname != "") {
          await inUser?.updateDisplayName(displayname);
        }

        await inUser?.reload();
        User? user = inUser;
        user = await _firebaseAuth.currentUser;
        Fluttertoast.showToast(msg: "Successfully updated profile");
        //print final version to console
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: "Problem updating your profile");
        Fluttertoast.showToast(msg: e.message.toString());
      }
    }
  }

  // UserModel? getLoggedInUser() {
  //   FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).get();
  //   // .then((value) {
  //   //   loggedInUser = UserModel.fromMap(value.data());
  //   //   // setState(() {
  //   //   //   userExists = loggedInUser;
  //   //   // });
  //   // }
  //   // );
  // }
}
