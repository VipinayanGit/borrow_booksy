import 'package:flutter/material.dart';

class signupscreen extends StatefulWidget {
  const signupscreen({super.key});

  @override
  State<signupscreen> createState() => _signupscreenState();
}

class _signupscreenState extends State<signupscreen> {
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
                  height: 150,
                  width: 150,
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
                  decoration: InputDecoration(
                    //fillColor: Colors.white,
                    filled: true,
                    labelText: "password",
                    border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                 padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  
                  decoration: InputDecoration(
                    //fillColor: Colors.white,
                    filled: true,
                    labelText: "ID",
                    border: InputBorder.none
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
