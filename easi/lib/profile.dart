import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/model/user_model.dart';
import 'package:firebase_database/firebase_database.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key, required this.userKey }) : super(key: key);
  final String userKey;
  @override
   _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //for updating user info
  final  userNameController = TextEditingController();
  final  userEmailController = TextEditingController();
  final  userPasswordController = TextEditingController();
  final  userConfirmpasswordController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  late DatabaseReference dbRef;
 
  @override
  void initState() {

    super.initState();
    //Get user info from the real time database
    dbRef = FirebaseDatabase.instance.ref().child('Users');
    //Shows user information from the database
      getUserData();
        FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }
  
  void getUserData() async {
    DataSnapshot snapshot = await dbRef.child(widget.userKey).get();
 
    Map user = snapshot.value as Map;
 
    userNameController.text = user['Name'];
    userEmailController.text = user['Email'];
    userPasswordController.text = user['Password'];
    userConfirmpasswordController.text = user['Confirm Password'];
  }
  @override
  Widget build(BuildContext context) {
   
      return Padding(
      padding: const EdgeInsets.fromLTRB(35, 5, 35, 0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "${loggedInUser.fullname}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Color(0xFF232253))),

                Text("${loggedInUser.email}",
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                        color: Color(0xFF232253)))
              ],
            ),
          ),
        ]
      ),
      );  
       
  }
  
 //This is the code for update. Need gd anay butang ang Email, Password kag fullname sa realtime database
  // @override
  // Widget build (BuildContext context) {
  //   var scaffold = Scaffold(
  //   final fullnameField = TextFormField(
  //     autofocus: false,
  //     controller: UserNameController,
  //     keyboardType: TextInputType.emailAddress,
  //     textInputAction: TextInputAction.next,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(Icons.mail),
  //       contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //       labelText: "${loggedInUser.fullname}",
  //       hintText: "Full Name",
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       )

  //     ),
  //   );
    
  //   final emailField = TextFormField(
  //     autofocus: false,
  //     controller: UserEmailController,
  //     keyboardType: TextInputType.emailAddress,
  //     textInputAction: TextInputAction.next,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(Icons.mail),
  //       contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //       labelText: '"${loggedInUser.email}"',
  //       hintText: "Email",
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       )

  //     ),
  //   );
  //    final passwordField = TextFormField(
  //     autofocus: false,
  //     controller: UserPasswordController,
  //      textInputAction: TextInputAction.done,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(Icons.lock),
  //       contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //       labelText: 'Password',
  //       hintText: "Password",
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       )

  //     ),
  //   ); 
  //     final confirmpasswordField = TextFormField(
  //     autofocus: false,
  //     controller: UserConfirmpasswordController,
  //      textInputAction: TextInputAction.done,
  //     decoration: InputDecoration(
  //       prefixIcon: Icon(Icons.lock),
  //       contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //       labelText: 'Password',
  //       hintText: "Password",
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(5),
  //       )

  //     ),
  //   );
  //   MaterialButton(
  //               onPressed: () {
 
  //                 Map<String, String> students = {
  //                   'Name': UserNameController.text,
  //                   'Email': UserEmailController.text,
  //                   'Password': UserPasswordController.text
  //                   'Confirm Password': UserConfirmpasswordController.text
  //                 };
 
  //                 dbRef.child(widget.UserKey).update(User)
  //                 .then((value) => {
  //                    Navigator.pop(context) 
  //                 });
 
  //               },
  //               child: const Text('Save'),
  //               color: Colors.blue,
  //               padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
  //               textColor: Colors.blue,
  //               minWidth: 300,
  //               height: 40,
  //             ),
  //   );
  //   return scaffold;
   
  // }
   
  

  }
