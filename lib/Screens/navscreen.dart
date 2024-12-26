import 'package:borrow_booksy/Screens/adminprofile.dart';
import 'package:borrow_booksy/Screens/eventscreen.dart';
import 'package:borrow_booksy/Screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'profilescreen.dart';

class Navscreen extends StatefulWidget {
  final String role;
  Navscreen({required this.role});

  

  @override
  State<Navscreen> createState() => _NavscreenState();
}

class _NavscreenState extends State<Navscreen> {
  late final List<Widget> _adminScreens;
  late final List<Widget> _userScreens;
  
  @override
  void initState() {
    super.initState();

    // Admin Screens
    _adminScreens = [
       Homescreen(),
       Eventscreen(),
       Adminprofile(),
    ];

    // User Screens
    _userScreens = [
      Homescreen(),
      Eventscreen(),
      Profilescreen(),
    ];
  }
  


  void ontapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == "admin";
    final screens = isAdmin ? _adminScreens : _userScreens;

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(  
        currentIndex: selectedIndex,
        items:isAdmin
        ?[
          BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: "Admin",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: "Events",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: " Profile",
                ),
        ]:[
          BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "user",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.policy),
                  label: "EVENTS",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
        ],
        selectedItemColor: Colors.white,
        onTap: ontapped,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
           ),
      ),
    );
  }
}
