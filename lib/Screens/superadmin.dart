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
  TextEditingController communitynamecontroller=TextEditingController();
  TextEditingController communityidcontroller=TextEditingController();
  TextEditingController adminidcontroller=TextEditingController();
  TextEditingController useridcontroller=TextEditingController();

  
  String name="",email="",password="",communityid="",adminid="",userid="";

Future<void>adduser(String name,String email,String password,String communityid,String userid)async{
  DocumentSnapshot communitydoc=await FirebaseFirestore.instance.collection("communities").doc(communityid).get();
  if(!communitydoc.exists){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("no community")));
    return;
  }

await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email, password: password);

  await FirebaseFirestore.instance.collection("communities").doc(communityid).collection("users").doc(userid).set({
    "name":name,
    "email":email,
     "password":password
  });
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created")));
 
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
   communityidcontroller.clear();
   useridcontroller.clear();



}



  Future<void>addadmin(String name,String email,String password,String communityid,String adminid)async{
   
   DocumentSnapshot communitydoc=await FirebaseFirestore.instance.collection("communities").doc(communityid).get();
   if(!communitydoc.exists){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("community does not exists")));
    return;
   }

   await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email, password: password);




    await FirebaseFirestore.instance.collection("communities").doc(communityid).collection("admins").doc(adminid).set({
      "name":name,
      "email":email,
      "password":password

    });
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
   communityidcontroller.clear();
   adminidcontroller.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin created with id $adminid")));

  }

  Future<void>addcommunity(String id,String name)async{
    await FirebaseFirestore.instance.collection("communities").doc(id).set(
      {
        "name":name
      }
  //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Community id is $name") ));
    );
    communitynamecontroller.clear();
    communityidcontroller.clear();
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Community Created",
                style: TextStyle(fontSize: 20.0),
              )));
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
                   _manageusers(context);
              }, 
              child: Text("Manage users")),),
              SizedBox(height: 50),
            Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
                _manageadmins(context);
               
              }, 
              child: Text("Manage admins")), ),
              SizedBox(height: 50),
              Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
                _managecommunity(context);
               
              }, 
              child: Text("Manage community")), )
           

          ],
        ),
      )
    );
  }

  void _manageusers(BuildContext context){
    showDialog(context: context,
     builder:(context){
      return Dialog(
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Padding(padding: EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _addusers(context);
                },
                 child:Text("Add Users")),
                 SizedBox(height: 20),
                 ElevatedButton(onPressed: (){},
                  child:Text("Delete Users")),
              ],
            ),
          ),),
        ),
      );
     });
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
              Text("Add Users", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Form(
                key:_Formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namecontroller,
                      decoration: InputDecoration(labelText: "Enter your name"),
                      validator:(value){
                        if(value.toString().isEmpty){
                          return "name should not be empty";
                        
                        }else{
                          return null;
                        }
                      },
                      
                    ),
                    // TextFormField(
                    //   controller: flatcontroller,
                    //   decoration: InputDecoration(labelText: "Enter your flatno"),
                    //   validator:(value){
                    //     if(value.toString()==null){
                    //       return "flatno should not be empty";
                        
                    //     }else{
                    //       return null;
                    //     }
                    //   },
                    // ),
                    TextFormField(
                      controller: emailcontroller,
                      decoration: InputDecoration(labelText: "Enter your email"),
                      validator:(value){
                        if(value.toString().isEmpty||!(value.toString().contains("@"))){
                          return "invalid email";
                        
                        }else{
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(labelText: "Enter your password"),
                      validator:(value){
                        if(value.toString().isEmpty){
                          return "password should not be null";
                        
                        }else if(value.toString().length<3){
                          return "very small password";
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    // TextFormField(
                    //   controller: phnocontroller,
                    //   decoration: InputDecoration(labelText: "Enter your number"),
                    //    validator:(value){
                    //     if(value.toString()==null){
                    //       return "number should not be null";
                        
                    //     }else if(value.toString().length<3){
                    //       return "very small password";
                    //     }
                    //     else if(value.toString().length<10 || value.toString().length>10){
                    //       return "invalid number";
                    //     }
                    //     else{
                    //       return null;
                    //     }
                    //   },
                    // ),
                    // TextFormField(
                    //   controller: adminidcontroller,
                    //   decoration: InputDecoration(labelText: "Enter admin id"),
                    //    validator:(value){
                    //     if(value.toString()==null){
                    //       return "password should not be null";
                        
                    //     }
                    //     else if(value.toString().length>5){
                    //       return "only 5 characters";

                    //     }
                    //     else{
                    //       return null;
                    //     }
                    //   },
                    // ),
                     TextFormField(
                      controller: useridcontroller,
                      decoration: InputDecoration(labelText: "Enter user id"),
                       validator:(value){
                        if(value.toString().isEmpty){
                          return "id should not be null";
                        
                        }
                        else if(value.toString().length>5){
                          return "only 5 characters";

                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                       controller: communityidcontroller,
                      decoration: InputDecoration(labelText: "enter your community id"),
                       validator:(value){
                        if(value.toString().isEmpty){
                          return "type your community id";
                        
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                   // SizedBox(height: 10),
                    
                  
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          name=namecontroller.text;
                          email=emailcontroller.text;
                          password=passwordcontroller.text;
                          communityid=communityidcontroller.text;
                          userid=useridcontroller.text;
                        });
                       
                        adduser(name, email, password,communityid,userid);
                        
                        
                        
                      },
                      child: Text("add user"),
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
  


  void _managecommunity(BuildContext context){
    showDialog(context: context,
     builder:(context){
      return Dialog(
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Padding(padding: EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _addcommunity(context);
                },
                 child:Text("Add Community")),
                 SizedBox(height: 20),
                 ElevatedButton(onPressed: (){},
                  child:Text("Delete Community")),
              ],
            ),
          ),),
        ),
      );
     });
  }
   void _addcommunity(BuildContext context){
    showDialog(context: context,
     builder:(context){
       return Dialog(
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Padding(padding:EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(

              children: [
               Text("Add Community", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               Form(child:Column(
                key:_Formkey,
                children: [
                   TextField(
                      controller: communitynamecontroller,
                      decoration: InputDecoration(labelText: "Enter community name"),
                    ),
                    TextField(
                      controller: communityidcontroller,
                      decoration: InputDecoration(labelText: "Enter community id"),
                    ),

                  SizedBox(height: 10),
                  ElevatedButton(onPressed:(){
                    addcommunity(communityidcontroller.text,communitynamecontroller.text);
                    Navigator.pop(context);
                  },
                   child:Text("Add")),


                ],
               ))
              ],
            ),
          )),
        
        ),
       );
     });
  }
  void _manageadmins(BuildContext context){
    showDialog(context: context,
     builder:(context){
      return Dialog(
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          child: Padding(padding: EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Column(
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _addadmins(context);
                },
                 child:Text("Add admins")),
                 SizedBox(height: 20),
                 ElevatedButton(onPressed: (){},
                  child:Text("Delete admins")),
              ],
            ),
          ),),
        ),
      );
     });
  }

 
  
  
  void _addadmins(BuildContext context){
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
              Text("Add Admins", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Form(
                key: _Formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: namecontroller,
                      decoration: InputDecoration(labelText: "Enter your name"),
                      validator:(value){
                        if(value.toString().isEmpty){
                          return "name should not be empty";
                        
                        }else{
                          return null;
                        }
                      },
                      
                    ),
                    // TextFormField(
                    //   controller: flatcontroller,
                    //   decoration: InputDecoration(labelText: "Enter your flatno"),
                    //   validator:(value){
                    //     if(value.toString()==null){
                    //       return "flatno should not be empty";
                        
                    //     }else{
                    //       return null;
                    //     }
                    //   },
                    // ),
                    TextFormField(
                      controller: emailcontroller,
                      decoration: InputDecoration(labelText: "Enter your email"),
                      validator:(value){
                        if(value.toString().isEmpty||!(value.toString().contains("@"))){
                          return "invalid email";
                        
                        }else{
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      controller: passwordcontroller,
                      decoration: InputDecoration(labelText: "Enter your password"),
                      validator:(value){
                        if(value.toString().isEmpty){
                          return "password should not be null";
                        
                        }else if(value.toString().length<3){
                          return "very small password";
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    // TextFormField(
                    //   controller: phnocontroller,
                    //   decoration: InputDecoration(labelText: "Enter your number"),
                    //    validator:(value){
                    //     if(value.toString()==null){
                    //       return "number should not be null";
                        
                    //     }else if(value.toString().length<3){
                    //       return "very small password";
                    //     }
                    //     else if(value.toString().length<10 || value.toString().length>10){
                    //       return "invalid number";
                    //     }
                    //     else{
                    //       return null;
                    //     }
                    //   },
                    // ),
                    TextFormField(
                      controller: adminidcontroller,
                      decoration: InputDecoration(labelText: "Enter admin id"),
                       validator:(value){
                        if(value.toString().isEmpty){
                          return "password should not be null";
                        
                        }
                        else if(value.toString().length>5){
                          return "only 5 characters";

                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                       controller: communityidcontroller,
                      decoration: InputDecoration(labelText: "enter your community id"),
                       validator:(value){
                        if(value.toString().isEmpty){
                          return "type your community id";
                        
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                   // SizedBox(height: 10),
                    
                  
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          name=namecontroller.text;
                          email=emailcontroller.text;
                          password=passwordcontroller.text;
                          adminid=adminidcontroller.text;
                          communityid=communityidcontroller.text;


                        });
                       
                        addadmin(name, email, password,communityid,adminid);
                        
                        
                      },
                      child: Text("add admin"),
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