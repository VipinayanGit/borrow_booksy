import 'package:borrow_booksy/Screens/Navscreen.dart';
import 'package:borrow_booksy/Screens/homescreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profilescreen.dart';
import 'package:flutter/material.dart';
import 'adminprofile.dart';
import 'superadmin.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  bool _obscureText = true; //Set to true because by default the text should be hidden
  final TextEditingController _emailcontroller=TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _admincontroller=TextEditingController();
  bool adminclick=false;
  String email="",password="",id="";
    final GlobalKey<FormState> _formkey = GlobalKey<FormState>();


   Future<void> userLogin() async {
   if(password=="superadmin"){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>Superadmin()));
    }else{
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String userId = userCredential.user!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      print("User not found in Firestore.");
      return;
    }

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    String? role = userData['role'];
    String? storedAdminId = userData['id']; // Admin ID from Firestore
    String userName = userData['name'];

   

    if (role == "admin") {
      if (adminclick) { 
        // Ensure the provided admin ID matches the one in Firestore
        if (id.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Admin ID is required for admin login"))
          );
          return;
        } else if (storedAdminId != id) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid Admin ID"))
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome Admin $userName")));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Navscreen(role: "admin")));
    } else if (role == "user") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Welcome $userName")));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Navscreen(role: "user")));
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage = "An error occurred";
    if (e.code == 'user-not-found') {
      errorMessage = "No User Found for that Email";
    } else if (e.code == "wrong-password") {
      errorMessage = "Incorrect password";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(errorMessage, style: TextStyle(fontSize: 20.0)),
      ),
    );
  }
    }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup page"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 130,
                    width: 130,
                  ),
                ),
                SizedBox(height: 40),
               
                
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    
                    validator: (value){
                      if(value==null){
                        return "the password cannot be empty";
                      }
                      else if(value.toString().length<6){
                        return "length must be greater than 6";
                      }else{
                        return null;
                      }
                    
                    },
                    
                    controller: _emailcontroller,
                    
                    decoration: InputDecoration(
          
                        //fillColor: Colors.white,
                        filled: true,
                        labelText: "email",
                        border: InputBorder.none,
                       
                        ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
          
                        //fillColor: Colors.white,
                        filled: true,
                        labelText: "password",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                        ),
                  ),
                ),
                 SizedBox(
                  height: 10,
                ),
               if(adminclick)
                 Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller:_admincontroller,
                    decoration: InputDecoration(
                        // fillColor: Colors.white,
                        filled: true,
                        labelText: "admin id",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
               
                Container(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                          email= _emailcontroller.text.trim();
                          password=_passwordController.text.trim();
                          id=_admincontroller.text.trim();
                          
                          userLogin();
                        
                          });
                          
                          
                          // String password = _passwordController.text.trim();
                          // if (password == "admin") {
                          //   // Navigate to Main Screen
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => Navscreen(role: "admin")),
                          //   );
                          // } else if (password == "user") {
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => Navscreen(role: "user")),
                          //   );
                          // }else if(password=="superadmin"){
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context)=>Superadmin())
                          //     );
                            
                          // } 
                          // else {
                          //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("invalid text")));
                          // }
                        },
                        child: Text("Login"),
                      ),
                      
                      Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    
                    
                    TextButton(onPressed: (){
                      setState(() {
                        adminclick=!adminclick;
                      });
                      
                    },
                    
                     child: adminclick?Text("Not a admin?user"):Text("Not a user?admin"),
                     ),
                  ],
                ),
                    ],
                  ),
                )
                
                
              ]
            ),
          ),
        ),
      )
      ),
    );
  }

}