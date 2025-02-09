import 'package:borrow_booksy/Screens/homescreen.dart';
import 'package:borrow_booksy/Screens/navscreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  }

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Homescreen(),
      theme: ThemeData(brightness: Brightness.dark),


    );
  }
}
