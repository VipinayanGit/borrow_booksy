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
        title:Text("Signup page"),
        centerTitle: true,
      ),
      
      body: SafeArea(
        child:Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset("assets/logo.png",
                height: 150,
                width: 150,),
              ),
            ],
          ),
        ) ),

    );
  }
}
