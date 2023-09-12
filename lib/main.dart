import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import './pages/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(home: Masuk()));
}

class Masuk extends StatefulWidget {
  const Masuk({super.key});

  @override
  State<Masuk> createState() => _MasukState();
}

class _MasukState extends State<Masuk> {
  final _formKey = GlobalKey<FormState>();
  var pagesName = 'Masuk';
  dynamic myUser;

  final namaController = TextEditingController();
  final noTeleponController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Enter a valid email address';
    } else {
      return null;
    }
  }

  bool _obscureText = true;
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        myUser = user;
      });
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const Dashboard()));
      });
    }
  }

  Future<void> login() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      setState(() {
        myUser = userCredential.user;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Success')),
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Dashboard()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Wrong password provided for that user.')));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> register() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      if (!mounted) return;

      return users.add({
        'email': emailController.text,
        'nama': namaController.text,
        'noTelepon': noTeleponController.text,
      }).then((value) {
        context.loaderOverlay.hide();
        // print(value.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil didaftarkan.')),
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      overlayColor: const Color.fromARGB(255, 253, 178, 148),
      useDefaultLoading: false,
      overlayOpacity: 0.4,
      overlayWidget: const Center(
        child: SpinKitWanderingCubes(
          color: Color.fromARGB(255, 255, 102, 41),
          size: 50.0,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            const SizedBox(
              height: 100,
            ),
            // IF ELSE IS AUTHENTICATED
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
                  if (pagesName == 'Daftar')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 11),
                      child: TextFormField(
                        style: GoogleFonts.poppins(
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.normal),
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
                  if (pagesName == 'Daftar')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 11),
                      child: TextFormField(
                        style: GoogleFonts.poppins(
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.normal),
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
                        horizontal: 15, vertical: 11),
                    child: TextFormField(
                      style: GoogleFonts.poppins(
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email',
                        filled: true,
                        labelText: 'Email',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => validateEmail(value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 11),
                    child: TextFormField(
                      style: GoogleFonts.poppins(
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                      ),
                      obscureText: _obscureText,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            _toggle();
                          },
                          icon: const Icon(Icons.remove_red_eye),
                        ),
                        border: const OutlineInputBorder(),
                        hintText: 'Password',
                        filled: true,
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                  pagesName == 'Masuk'
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              pagesName = 'Daftar';
                            });
                            emailController.text = '';
                            passwordController.text = '';
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Belum punya akun? Daftar',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.blue[500],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              pagesName = 'Masuk';
                            });
                            emailController.text = '';
                            passwordController.text = '';
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sudah punya akun? Masuk',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.blue[500],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(246, 157, 123, 1.0),
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          context.loaderOverlay.show();
                          if (pagesName == 'Masuk') {
                            await login();
                          } else {
                            await register();
                          }
                          context.loaderOverlay.hide();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
