import 'package:borrow_booksy/Screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Superadmin extends StatefulWidget {
  const Superadmin({super.key});

  @override
  State<Superadmin> createState() => _SuperadminState();
}

class _SuperadminState extends State<Superadmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _Formkey=GlobalKey<FormState>();
  TextEditingController namecontroller=TextEditingController();
  TextEditingController flatcontroller=TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController passwordcontroller=TextEditingController();
  TextEditingController phnocontroller=TextEditingController();
  String selectedrole='user';
  String email="",password="",name="",role="",flatno="";

  register()async{
    if(password!=null){
      try{
        UserCredential usercredential=await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);

        String userid=usercredential.user!.uid;
         String? generatedId;

    String generateRandomId() {
    Random random = Random();
    String randomNumber = (10000 + random.nextInt(90000)).toString(); // 5-digit number
    return randomNumber;
  }

      // If role is Admin, generate an ID with 'a' prefix
      if (selectedrole == "admin") {
        generatedId = "a${generateRandomId()}"; // Unique 5-character ID
      }

      // Store user data in Firestore
      await _firestore.collection("users").doc(userid).set({
        "name": name,
        "email": email,
        "password":password,
        "role": selectedrole,
        if (generatedId != null) "id": generatedId, // Only store for admins
      });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("registered")));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>login()));
       
      }on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too weak",
                style: TextStyle(fontSize: 20.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 20.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      actions: [
        IconButton(
        onPressed: (){
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>login()));}, icon:Icon(Icons.logout_outlined))],
      ),
      body:Center(
        child:Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
                   _addusers(context);
              }, 
              child: Text("Add")),),
              SizedBox(height: 50),
            Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
               
              }, 
              child: Text("Remove")), )
           

          ],
        ),
      )
    );
  }
  
  
  void _addusers(BuildContext context){
    showDialog(
  context: context,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: 400), // Set max width
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height to content
            children: [
              Text("Add", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namecontroller,
                      decoration: InputDecoration(labelText: "Enter your name"),
                    ),
                    TextField(
                      controller: flatcontroller,
                      decoration: InputDecoration(labelText: "Enter your flatno"),
                    ),
                    TextField(
                      controller: emailcontroller,
                      decoration: InputDecoration(labelText: "Enter your email"),
                    ),
                    TextField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(labelText: "Enter your password"),
                    ),
                    TextField(
                      controller: phnocontroller,
                      decoration: InputDecoration(labelText: "Enter your number"),
                    ),
                   // SizedBox(height: 10),

                    Material(
                      color: Colors.transparent,
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        value: selectedrole,
                        items: [
                          DropdownMenuItem(value: 'admin', child: Text("Admin")),
                          DropdownMenuItem(value: 'user', child: Text("User"))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedrole = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          email=emailcontroller.text.trim();
                          password=passwordcontroller.text.trim();
                          name=namecontroller.text.trim();
                          password=passwordcontroller.text.trim();
                          flatno=flatcontroller.text.trim();
                          register();
          
                        });
                      },
                      child: Text("Register"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

  }
}