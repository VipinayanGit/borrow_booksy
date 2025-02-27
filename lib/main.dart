import 'package:borrow_booksy/Screens/adminprofile.dart';
import 'package:borrow_booksy/Screens/homescreen.dart';
import 'package:borrow_booksy/Screens/navscreen.dart';
import 'package:borrow_booksy/Screens/profilescreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/login.dart';
import 'drive/upload_image.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 // GoogleDriveService driveService =GoogleDriveService();
 // await driveService.init();


  runApp(MyApp());
  //driveService: driveService
  }

class MyApp extends StatefulWidget {
  
 
const MyApp({super.key});// Initialize driveService here
//required this.driveService
 //final GoogleDriveService driveService;
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Superadmin(),
     // driveService: widget.driveService,
      theme: ThemeData.dark(),
    );
  }
}
