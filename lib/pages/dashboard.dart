import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import './components/home.dart';
import './components/profil.dart';
import './components/edit_profile.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String docId;
  late Map<String, dynamic> pet;
  int _selectedIndex = 0;
  bool _isChild = false;

  @override
  void initState() {
    super.initState();
  }

  void onItemTapped(int index, bool choose) {
    setState(() {
      _selectedIndex = index;
      _isChild = choose;
    });
  }

  Widget childBody() {
    if (_selectedIndex == 0 && !_isChild) {
      return Home(onItemTapped);
    } else if (_selectedIndex == 1 && !_isChild) {
      return Profil(onItemTapped);
    } else if (_selectedIndex == 1 && _isChild) {
      return EditProfile(onItemTapped);
    }

    return const Text('Failed rendering.');
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
        body: Center(
          child: childBody(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Home',
              backgroundColor: Color.fromRGBO(250, 153, 121, 1.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Color.fromRGBO(250, 153, 121, 1.0),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedLabelStyle: GoogleFonts.poppins(
            textStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            textStyle:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          iconSize: 26,
          unselectedItemColor: const Color.fromRGBO(248, 217, 201, 1.0),
          selectedItemColor: const Color.fromARGB(255, 253, 10, 10),
          onTap: (int index) {
            onItemTapped(index, false);
          },
        ),
      ),
    );
  }
}
