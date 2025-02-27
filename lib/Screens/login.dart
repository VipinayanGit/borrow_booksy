import 'package:borrow_booksy/Screens/Navscreen.dart';
import 'package:borrow_booksy/Screens/homescreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:borrow_booksy/drive/upload_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profilescreen.dart';
import 'package:flutter/material.dart';
import 'adminprofile.dart';
import 'superadmin.dart';

class login extends StatefulWidget {
 // final GoogleDriveService driveService; 
 login({super.key});
  //login({required this.driveService, Key? key}) : super(key: key);


  

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  bool _obscureText = true; //Set to true because by default the text should be hidden
  final TextEditingController _emailcontroller=TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idcontroller=TextEditingController();
  final TextEditingController _communityidcontroller=TextEditingController();
  bool adminclick=false;
  String email="",password="",id="",communityid="";
    final GlobalKey<FormState> _formkey = GlobalKey<FormState>();


   Future<void>userlogin(String email,String password,String id,String Cid)async{

    if(password=='superadmin'){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Superadmin()));
    }
       try{
       if(adminclick){
        DocumentSnapshot admindoc=await FirebaseFirestore.instance.collection("communities").doc(Cid).collection("admins").doc(id).get();
        if(!admindoc.exists){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("no admin id found")));
          return;
        }
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("welcome ${admindoc['name']}")));
         Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Navscreen(role: "admin")));//driveService: widget.driveService,
      }else{
        DocumentSnapshot userdoc=await FirebaseFirestore.instance.collection("communities").doc(Cid).collection("users").doc(id).get();
        if(!userdoc.exists){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("no user id found")));
            return;
             }
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("welcome ${userdoc['name']}")));
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Navscreen(role: "user")));//driveService:widget.driveService
         
      }     
       }catch(e){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
       }
   }
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login page"),
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
                    height: 100,
                    width: 100,
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
               
                 Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller:_idcontroller,
                    decoration: InputDecoration(
                        // fillColor: Colors.white,
                        filled: true,
                        labelText:adminclick? "admin id":"user id",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: TextFormField(
                    controller:_communityidcontroller,
                    decoration: InputDecoration(
                        // fillColor: Colors.white,
                        filled: true,
                        labelText:"community id",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10)),
                  ),
                ),
               
                Container(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                         
                          email= _emailcontroller.text.trim();
                          password=_passwordController.text.trim();
                          id=_idcontroller.text.trim();
                          communityid=_communityidcontroller.text.trim();
                          
                          
                          
                        
                        
                          userlogin(email, password, id,communityid);
                          
                          
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