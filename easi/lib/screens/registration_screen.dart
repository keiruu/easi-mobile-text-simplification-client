import 'package:easi/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import '../google_sign_in.dart';
import '/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //form key
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final fullNameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();

  @override
  void dispose() {
    fullNameEditingController.dispose();
    emailEditingController.dispose();
    passwordEditingController.dispose();
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    //fullName Field
    final fullNameField = TextFormField(
      autofocus: false,
      controller: fullNameEditingController,
      keyboardType: TextInputType.name,
      //validator: () {},
      validator: (value) {
        RegExp regex = new RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Full Name Required");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter Valid Name(Min. 6 Character");
        }
        return null;
      },
      onSaved: (value) {
        fullNameEditingController.text = value!;
      },
      //icon
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.account_circle),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: 'Full Name',
        hintText: "Full Name",
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCFCFCF))),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1976D2))),
      ),
    );
    //email Field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      //validator: () {},
      validator: (value) {
        if (value!.isEmpty) {
          return ("Enter your Email");
        }
        //reg expression for eail validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter your Email");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value!;
      },
      //icon
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
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(5),
        //   borderSide: BorderSide(width: 3, color: Colors.greenAccent), //<-- SEE HERE

        // )
      ),
    );
    //Password
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      //validator: () {},

      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter Valid Password(Min. 6 Character");
        }
        return null;
      },
      onSaved: (value) {
        passwordEditingController.text = value!;
      },
      //icon
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: 'Password',
        hintText: "Password",
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCFCFCF))),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1976D2))),
      ),
    );

    final signupButton = Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(5),
      color: Color(0xFF1976D2),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          await authService
              .createUserWithEmailAndPassword(
                  emailEditingController.text,
                  passwordEditingController.text,
                  fullNameEditingController.text)
              .catchError((e) {
            Fluttertoast.showToast(msg: e!.message);
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
          );
        },
        child: Text(
          "Register",
          style: TextStyle(color: (Colors.white)),
        ),
      ),
    );

    final googlelog = Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(5),
        color: Colors.white);
    MaterialButton(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
      minWidth: MediaQuery.of(context).size.width,
      onPressed: () {
        context.read<FirebaseAuthMethods>().signInWithGoogle(context);
      },
      child: Container(
          alignment: Alignment.center,
          child: Text(
            'Sign in with Google',
            style: TextStyle(
              color: (Colors.white),
            ),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
            child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(bottom: 40),
                                child: const Text(
                                  'Create an Account',
                                  style: TextStyle(
                                      color: Color(0xFF1976D2),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 27),
                                )),
                            fullNameField,
                            SizedBox(height: 30),
                            emailField,
                            SizedBox(height: 30),
                            passwordField,
                            SizedBox(height: 30),
                            signupButton,
                            SizedBox(height: 30),
                            googlelog,
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                LoginScreen())));
                                  },
                                  child: Text(
                                    "Log in Here",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      color: Color(0xFF1565c0),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ])),
                ))),
      ),
    );
  }

  // void signUp(String email, String password) async
  // {
  //   if(_formKey.currentState!.validate())
  //   {
  //     await _auth.createUserWithEmailAndPassword(email: email, password: password)
  //     .then((value) =>  {postDetailsToFirestore()})
  //     .catchError((e){
  //         Fluttertoast.showToast(msg: e!.message);
  //       });
  //   }
  // }

  // postDetailsToFirestore() async{
  //   //call firestore, usermodel and send values

  //   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   User? user = _auth.currentUser;

  //   UserModel userModel = UserModel();
  //   //values

  //   userModel.email = user!.email;
  //   userModel.uid = user.uid;
  //   userModel.fullname = fullNameEditingController.text;

  //   await firebaseFirestore
  //   .collection("users")
  //   .doc(user.uid)
  //   .set(userModel.toMap());
  //   Fluttertoast.showToast(msg: "Account Created Successfully: ) ");

  //   Navigator.pushAndRemoveUntil((context), MaterialPageRoute(builder: (context) => HomeScreen()),
  //   (route) => false);
  // }
}
