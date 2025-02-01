import 'package:borrow_booksy/Screens/Navscreen.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'profilescreen.dart';
import 'package:flutter/material.dart';
import 'adminprofile.dart';

class signupscreen extends StatefulWidget {
  const signupscreen({super.key});

  @override
  State<signupscreen> createState() => _signupscreenState();
}

class _signupscreenState extends State<signupscreen> {
  bool _obscureText = true; //Set to true because by default the text should be hidden
  final TextEditingController _passwordController = TextEditingController();
  bool adminclick=false;

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
                    decoration: InputDecoration(
                        // fillColor: Colors.white,
                        filled: true,
                        labelText: "id",
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
                          String password = _passwordController.text.trim();
                          if (password == "admin") {
                            // Navigate to Main Screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Navscreen(role: "admin")),
                            );
                          } else if (password == "user") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Navscreen(role: "user")),
                            );
                          }else if(password=="superadmin"){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context)=>Superadmin())
                              );
                            
                          } 
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("invalid text")));
                          }
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
