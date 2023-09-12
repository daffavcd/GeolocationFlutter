import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(this.onItemTapped, {super.key});
  final void Function(int index, bool choose) onItemTapped;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  var pagesName = 'Edit Profile';

  dynamic docId;
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final noTeleponController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    context.loaderOverlay.show();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        QueryDocumentSnapshot document = userQuery.docs.first;
        setState(() {
          docId = document.id;
          namaController.text = document['nama'];
          emailController.text = document['email'];
          noTeleponController.text = document['noTelepon'];
        });
      }
    }
    context.loaderOverlay.hide();
  }

  Future<void> updateProfile() async {
    context.loaderOverlay.show();

    // Get the document reference
    DocumentReference userDoc = users.doc(docId);

    return userDoc.update({
      'nama': namaController.text,
      'noTelepon': noTeleponController.text,
    }).then((value) {
      context.loaderOverlay.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil dirubah.')),
      );
      widget.onItemTapped(1, false);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 100,
          ),
          Text(
            pagesName,
            style: GoogleFonts.poppins(
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // IF ELSE IS AUTHENTICATED
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: TextFormField(
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: namaController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nama',
                      filled: true,
                      labelText: 'Nama',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                  child: TextFormField(
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.normal),
                    ),
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: noTeleponController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'No Telepon',
                      filled: true,
                      labelText: 'No Telepon',
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 102, 41),
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        context.loaderOverlay.show();
                        await updateProfile();
                        context.loaderOverlay.hide();
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
