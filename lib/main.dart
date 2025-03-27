import 'package:borrow_booksy/Screens/navscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 // GoogleDriveService driveService=GoogleDriveService();
 // await driveService.init();
 Widget startPage = await getStartScreen();
 bool isloggedin=await checkFirebaseAuthStatus();
runApp(MyApp(startPage:startPage));
 


  //driveService: driveService
  }

  Future<Widget> getStartScreen() async {
  User? user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return login(); // Redirect to login if no user is logged in
  }

  // Check if the user is an admin or a normal user
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAdmin = prefs.getBool('isadmin') ?? false;

  return Navscreen(role: isAdmin ? "admin" : "user"); // Redirect accordingly
}

bool checkFirebaseAuthStatus() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null; // Returns true if a user is logged in
}
class MyApp extends StatefulWidget {
  
final Widget startPage;
const MyApp({Key? key, required this.startPage}) : super(key: key);// Initialize driveService here
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
      
     // driveService: widget.driveService,
      theme: ThemeData.dark(),
      home:widget.startPage ,
      //
    );
  }
}
