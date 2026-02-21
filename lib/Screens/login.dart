import 'package:borrow_booksy/Screens/Navscreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import  'package:shared_preferences/shared_preferences.dart';

class login extends StatefulWidget {
 
 login({super.key});
 


  

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
    String communityId = Cid;
    String userId = id;
    String userType = adminclick ? "admins" : "users";
       try{
         DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("communities")
          .doc(communityId)
          .collection(userType)
          .doc(userId)
          .get();
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          
          if (userDoc.exists) {
        // Save login details in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('communityId', communityId);
        await prefs.setString('userId', userId);
        await prefs.setString('flat',userDoc['flatno']);
        
        await prefs.setBool('isadmin', adminclick);
        await prefs.setString('phno',userDoc['phno']);
        

        // Navigate to respective screen
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>adminclick?Navscreen(role: "admin"):Navscreen(role: "user")));
       
      } 
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found")));
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