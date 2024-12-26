import 'package:borrow_booksy/Screens/Navscreen.dart';
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
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup page"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
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
                child: TextField(
                  decoration: InputDecoration(
                      // fillColor: Colors.white,
                      filled: true,
                      labelText: "Username",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10)),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  obscureText: _obscureText,
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
                      )),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  controller: _idController,
                  decoration: InputDecoration(

                      //fillColor: Colors.white,
                      filled: true,
                      labelText: "ID",
                      border: InputBorder.none),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    String id = _idController.text.trim();
                    if (id == "admin") {
                      // Navigate to Main Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Navscreen(role: "admin")),
                      );
                    } else if (id == "user") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Navscreen(role: "user")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("invalid text")));
                    }
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
