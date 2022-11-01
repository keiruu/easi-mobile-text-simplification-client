
// ignore_for_file: unused_import, await_only_futures, prefer_const_constructors, deprecated_member_use, avoid_unnecessary_containers, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
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

class LoginScreen extends StatefulWidget {
   const LoginScreen({Key? key}) : super(key: key);
   
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 bool _rememberMe = false;
//form key
  final _formKey = GlobalKey<FormState>();

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();


//firebase

final _auth = FirebaseAuth.instance;
//Displays error message
String? errorMessage;

  get onPressed => null;
  @override
  Widget build(BuildContext context) {
    

    //email
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
    
      validator: (value)
      {
        if(value!.isEmpty)
        {
          return ("Enter your Email");
        }
        //reg expression for eail validation
        else if(!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)){
          return("Please Enter your Email");

        }
        return null;
      },
      onSaved: (value)
      {
        emailController.text = value!;
      },
      //Email
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: 'Email',
        hintText: "Email",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        )

      ),
    );
    //way ni sya error. Okay man ni

   //password
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      //validator: () {},
      
      validator: (value){
        RegExp regex = RegExp(r'^.{6,}$');
        if(value!.isEmpty)
        {
          return("Password is required");
        }
       else if(!regex.hasMatch(value)){
         return("Please Enter Valid Password(Min. 6 Character");
        }
        return null;
        
      },
      onSaved: (value)
      {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: 'Password',
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        )

      ),
    ); 

    Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
       
        child: Container(
                
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: (Colors.blue),
                 ),
                )),
      ),
    );
  }  

 Widget _buildRememberMeCheckbox() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.black,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          Text(
            'Remember me',
          ),
        ],
      ),
    );
  }
//login button function
final materialButton = 
MaterialButton(
    padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
    minWidth: MediaQuery.of(context).size.width,
   onPressed: () async { signIn(emailController.text, passwordController.text);
    Navigator.of(context).push(
         await MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
      
    );
    },
    child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: TextStyle(color: (Colors.white),
                 ),
                )),
    
    );
    
final loginButton = Material(
  elevation: 5,
  borderRadius: BorderRadius.circular(5),
  color: Color(0xFF1565c0),
  child:  materialButton,
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
                  style: TextStyle(color: (Colors.white),
                 ),
                )),
    
    );

// will remove later
  /*ElevatedButton.icon(
    style:ElevatedButton.styleFrom(
      primary: Colors.blue,
      onPrimary: Colors.black,
      minimumSize: Size(double.infinity, 50),
    ),
    icon: FaIcon(FontAwesomeIcons.google),
    label: Text('Sign in With Google'),
    onPressed: () {
      final provider = Provider.of(context, listen: false);
      provider.googleLogin();
    },

  );*/
    return Scaffold(
      
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color:Colors.white,
            child:Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                child: const Text(
                  'Hello again!',
                  style: TextStyle(color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w900, fontSize: 30),
                )),
                    

                    emailField,
                    SizedBox(height: 45),
                    
                    passwordField,
                     SizedBox(height: 30),
                     _buildForgotPasswordBtn(),
                     _buildRememberMeCheckbox(),
                     
                    loginButton,
                     SizedBox(height: 10),
                    googlelog,
                     SizedBox(height: 10),
                    
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: <Widget>[
                          Text("Don't have an account? "),
                         
                          GestureDetector(onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder:((context) =>  RegistrationScreen()))
                            );
                          },
                          child: const Text("Sign up here", 
                          style: TextStyle(decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,fontSize:15, color: Color(0xFF1565c0)),),
                          )

                        ],
                      )
                    
                  ]
                )
              ),
            )
          )
        ),
      ),
    );
  }

 // login function
  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
                  Fluttertoast.showToast(msg: "Login Successful"),
                  // Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                });
                return null;
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";

            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  //nvm this code
//Login Function
// void signIn(String email,String password) async
// {
//   if(_formKey.currentState!.validate())
//   {
//     await FirebaseAuth.instance
//     .signInWithEmailAndPassword(email: email, password: password)
//     .then((uid) => {
//       Fluttertoast.showToast(msg: "Login Successfull"),
//       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen())),

//     }).catchError((e)
//     {
//       Fluttertoast.showToast(msg: e!.message);
//     });
//   }
// }
}

// ignore: non_constant_identifier_names
HomeScreen() {
}