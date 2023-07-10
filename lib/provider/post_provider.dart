import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hoost_mvp/model/post_model.dart';
import 'package:hoost_mvp/utils/utils.dart';

class PostProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  PostModel? _postModel;
  PostModel get postModel => _postModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // PostProvider() {
  //   checkSign();
  // }

  // void checkSign() async {
  //   final SharedPreferences s = await SharedPreferences.getInstance();
  //   _isSignedIn = s.getBool("is_signedin") ?? false;
  //   notifyListeners();
  // }

  // Future setSignIn() async {
  //   final SharedPreferences s = await SharedPreferences.getInstance();
  //   s.setBool("is_signedin", true);
  //   _isSignedIn = true;
  //   notifyListeners();
  // }

  // // signin
  // void signInWithPhone(BuildContext context, String phoneNumber) async {
  //   try {
  //     await _firebaseAuth.verifyPhoneNumber(
  //         phoneNumber: phoneNumber,
  //         verificationCompleted:
  //             (PhoneAuthCredential phoneAuthCredential) async {
  //           await _firebaseAuth.signInWithCredential(phoneAuthCredential);
  //         },
  //         verificationFailed: (error) {
  //           throw Exception(error.message);
  //         },
  //         codeSent: (verificationId, forceResendingToken) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => OtpScreen(verificationId: verificationId),
  //             ),
  //           );
  //         },
  //         codeAutoRetrievalTimeout: (verificationId) {});
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message.toString());
  //   }
  // }

  // // verify otp
  // void verifyOtp({
  //   required BuildContext context,
  //   required String verificationId,
  //   required String userOtp,
  //   required Function onSuccess,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     PhoneAuthCredential creds = PhoneAuthProvider.credential(
  //         verificationId: verificationId, smsCode: userOtp);

  //     User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

  //     if (user != null) {
  //       // carry our logic
  //       _uid = user.uid;
  //       onSuccess();
  //     }
  //     _isLoading = false;
  //     notifyListeners();
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message.toString());
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // DATABASE OPERTAIONS
  Future<bool> checkExistingPost() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("post").doc(_uid).get();
    if (snapshot.exists) {
      print("POST EXISTS");
      return true;
    } else {
      print("NEW POST");
      return false;
    }
  }

  void savePostDataTofirebase({
    required BuildContext context,
    required PostModel postModel,
    required File postPic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await storeFileToStorage("postPic/$_uid", postPic).then((value) {
        postModel.postPic = value;
        postModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        postModel.uidUser = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _postModel = postModel;
      await _firebaseFirestore
          .collection("posts")
          .doc(_uid)
          .set(postModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // void saveUserDataToFirebase({
  //   required BuildContext context,
  //   required UserModel userModel,
  //   required File profilePic,
  //   required Function onSuccess,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     // uploading image to firebase storage.
  //     await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
  //       userModel.profilePic = value;
  //       userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
  //       userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
  //       userModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
  //     });
  //     _userModel = userModel;

  //     // uploading to database
  //     await _firebaseFirestore
  //         .collection("users")
  //         .doc(_uid)
  //         .set(userModel.toMap())
  //         .then((value) {
  //       onSuccess();
  //       _isLoading = false;
  //       notifyListeners();
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     showSnackBar(context, e.message.toString());
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Future getDataFromFirestore() async {
  //   await _firebaseFirestore
  //       .collection("users")
  //       .doc(_firebaseAuth.currentUser!.uid)
  //       .get()
  //       .then((DocumentSnapshot snapshot) {
  //     _userModel = UserModel(
  //       name: snapshot['name'],
  //       email: snapshot['email'],
  //       createdAt: snapshot['createdAt'],
  //       bio: snapshot['bio'],
  //       uid: snapshot['uid'],
  //       profilePic: snapshot['profilePic'],
  //       phoneNumber: snapshot['phoneNumber'],
  //     );
  //     _uid = userModel.uid;
  //   });
  // }
}
