import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hoost_mvp/model/user_model.dart';
import 'package:hoost_mvp/provider/auth_provider.dart';
// import 'package:hoost_mvp/screens/home_screen.dart';
import 'package:hoost_mvp/utils/bottom_bar.dart';
import 'package:hoost_mvp/utils/utils.dart';
import 'package:hoost_mvp/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _Feed();
}

class _Feed extends State<FeedScreen> {
  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  // for selecting image
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    final ap = Provider.of<AuthProvider>(context, listen: true);
    final CollectionReference _post =
        FirebaseFirestore.instance.collection('posts');
    final query = _post.where("uidUser", isNotEqualTo: ap.uid);
    return Scaffold(
       appBar: AppBar(
          title: const Center(child: Text("Fil d'actualité")),
        ),
      body: StreamBuilder(
        stream: query.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                final String yearDebut =
                    DateTime.parse(documentSnapshot['date_debut'])
                        .year
                        .toString();
                final String monthDebut =
                    DateTime.parse(documentSnapshot['date_debut'])
                        .month
                        .toString();
                final String yearFin =
                    DateTime.parse(documentSnapshot['date_fin'])
                        .year
                        .toString();
                final String monthFin =
                    DateTime.parse(documentSnapshot['date_fin'])
                        .month
                        .toString();
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['lieu']),
                    subtitle: Text(documentSnapshot['description'] +
                        ' Durée : ' + yearDebut + ' - ' + monthDebut + ' à ' + yearFin + ' - ' + monthFin),
                        trailing: SizedBox(
                        width: 50,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () => {}),                            
                          ],
                        ),
                      ),

                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.purple,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.purple,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.purple.shade50,
          filled: true,
        ),
      ),
    );
  }

  // store user data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );
    if (image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => const HomeScreen(),
                            builder: (context) =>
                                const BottomNavigationBarExample(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please upload your profile photo");
    }
  }
}
