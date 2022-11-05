// class UserModel {
//   String? uid;
//   String? email;
//   String? password;
//   String? fullname;

//   UserModel({this.uid, this.email, this.password, this.fullname});

//   //server to Database
//   factory UserModel.fromMap(map) {
//     return UserModel(
//       uid: map['uid'],
//       email: map['email'],
//       password: map['password'],
//       fullname: map['fullname'],
//     );
//   }
//   //Database to Server

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'password': password,
//       'fullname': fullname,
//     };
//   }
// }

class UserModel {
  final String uid;
  final String? email;
  final String? displayname;

  UserModel(this.uid, this.email, this.displayname);

  // factory UserModel.fromMap(map) {
  //   return UserModel(
  //     uid: map['uid'],
  //     email?: map['email'],
  //     displayname: map['displayname'],
  //   );
  // }
  // //Database to Server

  // Map<String, dynamic> toMap() {
  //   return {
  //     'uid': uid,
  //     'email': email,
  //     'displayname': displayname,
  //   };
  // }

}
