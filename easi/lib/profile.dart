import 'package:easi/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  User? currentUser;

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
    currentUser = AuthService().getCurrentUser();
    print("current user");
    print(currentUser?.displayName);
  }

//  This is the code for update. Need gd anay butang ang Email, Password kag fullname sa realtime database
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authService = Provider.of<AuthService>(context);

    return Material(
        child: Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(25, 60, 25, 20),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF5274AE),
                  size: 36,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(60, 20, 25, 20),
              child: Text(
                "Edit Profile",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
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
            await authService.updateProfile(
                userNameController.text,
                userEmailController.text,
                userPasswordController.text,
                userConfirmpasswordController.text, context);

            // User? user = authService.getCurrentUser();
            // print("CRUREURE");
            // print(user);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ),
            );
            // Navigator.pop(context);
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
    ]));
  }
}

class ProfileHome extends StatelessWidget {
  const ProfileHome({Key? key, required this.currentUser});

  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    User? user = AuthService().getCurrentUser();
    final authService = Provider.of<AuthService>(context);
    final mediaQuery = MediaQuery.of(context);

    return Material(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(25, 50, 25, 20),
            child: Text(
              "Edit Profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 40, 0, 5),
            child: Text(
              "${user?.displayName}",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Text(
              "${user?.email}",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30),
            height: (mediaQuery.size.height - mediaQuery.padding.top),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                InkWell(
                    onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(
                                userKey: '',
                              ),
                            ),
                          )
                        },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 18),
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Color(0xFFF6F6F8)),
                                  child: Icon(Icons.edit),
                                ),
                                Text("Edit Profile"),
                              ],
                            ),
                            Icon(Icons.navigate_next)
                          ]),
                    )),
                InkWell(
                    onTap: () async => {await authService.signout(context)},
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 18),
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Color(0xFFF6F6F8)),
                                  child: Icon(Icons.logout),
                                ),
                                Text("Log out"),
                              ],
                            ),
                            Icon(Icons.navigate_next)
                          ]),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
