import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easi/model/user_model.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
   _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
   User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

 
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
  width: 200,
  height: 200,
  margin: EdgeInsets.all(10),
  padding: EdgeInsets.all(5),
  child: Text(''),
  decoration: BoxDecoration(
	  color: Colors.yellow[200],

	  ),
);


  }
}
// class Box extends StatefulWidget {
//   const Box({Key? key}) : super(key: key);

//   @override
//    _BoxState createState() => _BoxState();
// }

// class _BoxState extends State<Box> {
//    @override
//   Widget build(BuildContext context) {
    
//     //email
//     var emailController;
//     final emailField = TextFormField(
//       autofocus: false,
//       controller: emailController,
//       keyboardType: TextInputType.emailAddress,
//       //Email
      
//       textInputAction: TextInputAction.next,
//       decoration: InputDecoration(
//         prefixIcon: Icon(Icons.mail),
//         contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//         labelText: 'Email',
//         hintText: "Email",
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(5),
//         )

//       ),
//     );



//   }
// }
