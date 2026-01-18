import 'package:borrow_booksy/Screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Superadmin extends StatefulWidget {
  // final GoogleDriveService driveService;
 Superadmin({super.key});
 //Superadmin({required this.driveService, Key? key}): super(key: key);
 
 

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
  dynamic flatno="";String phno="";

 Future<void>adduser(String name,String email,String password,String communityid,String userid,String flatno,String phno)async{
  DocumentSnapshot communitydoc=await FirebaseFirestore.instance.collection("communities").doc(communityid).get();
  if(!communitydoc.exists){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("no community")));
    return;
  }

try{

  UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email, password: password);
  
   String? firebaseUid = userCredential.user?.uid;
    if (firebaseUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get Firebase UID")));
      return;
    }


  await FirebaseFirestore.instance.collection("communities").doc(communityid).collection("users").doc(userid).set({
    "name":name,
    "email":email,
    "communityid":communityid,
    "uid":firebaseUid,
    "role":"user",
    "flatno":flatno,
    "phno":phno,
    "books_read":0
  });
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created")));
 
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
   communityidcontroller.clear();
   useridcontroller.clear();
   flatcontroller.clear();
   phnocontroller.clear();



}catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  }



}



 Future<void>addadmin(String name,String email,String password,String communityid,String adminid,String flatno,String phno)async{
   
   DocumentSnapshot communitydoc=await FirebaseFirestore.instance.collection("communities").doc(communityid).get();
   if(!communitydoc.exists){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("community does not exists")));
    return;
   }
  try{
  UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email, password: password);


 String? firebaseUid = userCredential.user?.uid;
    if (firebaseUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get Firebase UID")));
      return;
    }

    
    await FirebaseFirestore.instance.collection("communities").doc(communityid).collection("admins").doc(adminid).set({
      "name":name,
      "email":email,
      "communityid":communityid,
      "uid":firebaseUid,
      "role":"admin",
      "flatno":flatno,
      "phno":phno,
      "books_read":0
    });
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
   communityidcontroller.clear();
   adminidcontroller.clear();
   phnocontroller.clear();
   flatcontroller.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Admin created with id $adminid")));
  }catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  }
  
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
     ),//driveService: widget.driveService, 
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
                 ElevatedButton(onPressed: (){
                  showDeleteUserDialog();
                 },
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
                    TextFormField(
                      controller: flatcontroller,
                      decoration: InputDecoration(labelText: "Enter your flatno"),
                      validator:(value){
                        if(value.toString()==null){
                          return "flatno should not be empty";
                        
                        }else{
                          return null;
                        }
                      },
                    ),
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
                    TextFormField(
                      controller: phnocontroller,
                      decoration: InputDecoration(labelText: "Enter your number"),
                       validator:(value){
                        
                        if((value.toString()).isEmpty){
                          return "number should not be null";
                        
                        }else if(value.toString().length<3){
                          return "very small password";
                        }
                        else if(value.toString().length<10 || value.toString().length>10){
                          return "invalid number";
                        }
                        else{
                          return null;
                        }
                      },
                    ),
                    
                     TextFormField(
                      controller: useridcontroller,
                      decoration: InputDecoration(labelText: "Enter user id"),
                       validator:(value){
                        if(value.toString().isEmpty){
                          return "id should not be null";
                        
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
                          flatno=flatcontroller.text;
                          phno=phnocontroller.text;
                          
                        });
                       
                        adduser(name, email, password,communityid,userid,flatno,phno);
                        Navigator.pop(context);
                        
                        
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
                 ElevatedButton(onPressed: (){
                  showDeleteCommunityDialog();
                 },
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
                 ElevatedButton(onPressed: (){
                  showDeleteAdminDialog();
                 },
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
                    TextFormField(
                      controller: flatcontroller,
                      decoration: InputDecoration(labelText: "Enter your flatno"),
                      validator:(value){
                        if((value.toString()).isEmpty){
                          return "flatno should not be empty";
                        
                        }else{
                          return null;
                        }
                      },
                    ),
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
                    TextFormField(
                      controller: phnocontroller,
                      decoration: InputDecoration(labelText: "Enter your number"),
                       validator:(value){
                        if((value.toString()).isEmpty){
                          return "number should not be null";
                        
                        }else if(value.toString().length<3){
                          return "very small password";
                        }
                        else if(value.toString().length<10 || value.toString().length>10){
                          return "invalid number";
                        }
                        else{
                          return null;
                        }
                      },
                    ),
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
                          flatno=flatcontroller.text;
                          phno=phnocontroller.text;


                        });
                       
                        addadmin(name, email, password,communityid,adminid,flatno,phno);
                        
                        
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
  
 
 void showDeleteCommunityDialog() {
  TextEditingController communityIdController = TextEditingController();
  String? foundCommunityId;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Community"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Input for Community ID
                  TextField(
                    controller: communityIdController,
                    decoration: InputDecoration(labelText: "Enter Community ID"),
                  ),
                  SizedBox(height: 10),
              
                  //Search Button
                  ElevatedButton(
                    onPressed: () async {
                      if (communityIdController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Enter a Community ID to search")),
                        );
                        return;
                      }
              
                      // 🔍 Check if community exists
                      DocumentSnapshot communityDoc = await FirebaseFirestore.instance
                          .collection("communities")
                          .doc(communityIdController.text)
                          .get();
              
                      if (communityDoc.exists) {
                        setState(() {
                          foundCommunityId = communityIdController.text;
                        });
                      } else {
                        setState(() {
                          foundCommunityId = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Community not found")));
                      }
                    },
                    child: Text("Search Community"),
                  ),
                  SizedBox(height: 20),
              
                  // 🔹 Show Delete Button if Community Found
                  if (foundCommunityId != null)
                    ListTile(
                      title: Text("Community ID: $foundCommunityId"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            //Delete Community and Its Subcollections
                          await FirebaseFirestore.instance
                          .collection("communities")
                          .doc(communityIdController.text)
                          .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Community deleted successfully")),
                            );
              
                            setState(() {
                              foundCommunityId = null;
                              communityIdController.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}

 
 void showDeleteAdminDialog() {
  TextEditingController communityIdController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String? adminId;
  String? fbAdminUid;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete admin"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TextField for Community ID Input
                  TextField(
                    controller: communityIdController,
                    decoration: InputDecoration(
                      labelText: "Enter Community ID",
                    ),
                  ),
                  SizedBox(height: 10),
              
                  // Search Bar for User ID
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Enter admin ID",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          if (communityIdController.text.isEmpty || searchController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Community ID and User ID to search")));
                            return;
                          }
              
                          DocumentSnapshot adminDoc = await FirebaseFirestore.instance
                              .collection("communities")
                              .doc(communityIdController.text)
                              .collection("admins")
                              .doc(searchController.text)
                              .get();
              
                          if (adminDoc.exists) {
                            setState(() {
                              adminId = searchController.text;
                              fbAdminUid= adminDoc["uid"]; // 🔹 Fetch Firebase Authentication UID
                            });
                          } else {
                            setState(() {
                              adminId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("admin not found in this community")));
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
              
                  // 🔹 Show User ID & Delete Button if User Found
                  if (adminId != null)
                    ListTile(
                      title: Text("admin ID: $adminId"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            
                            await FirebaseFirestore.instance
                                .collection("communities")
                                .doc(communityIdController.text)
                                .collection("admins")
                                .doc(adminId)
                                .delete();
                              if (fbAdminUid != null) {
                              try {
                                await FirebaseAuth.instance
                                    .currentUser!
                                    .delete(); //  Only works if the current user is logged in
                              } catch (e) {
                                print("Error deleting from authentication: $e");
                              }
                            }
              
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("admin deleted successfully")));
              
                            setState(() {
                              adminId = null;
                              searchController.clear();
                              communityIdController.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}
  
  
 void showDeleteUserDialog() {
  TextEditingController communityIdController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String? userId;
  String? firebaseUid;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete User"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 TextField for Community ID Input
                  TextField(
                    controller: communityIdController,
                    decoration: InputDecoration(
                      labelText: "Enter Community ID",
                    ),
                  ),
                  SizedBox(height: 10),
              
                  // 🔹 Search Bar for User ID
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Enter User ID",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          if (communityIdController.text.isEmpty || searchController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Community ID and User ID to search")));
                            return;
                          }
              
                          DocumentSnapshot userDoc = await FirebaseFirestore.instance
                              .collection("communities")
                              .doc(communityIdController.text)
                              .collection("users")
                              .doc(searchController.text)
                              .get();
              
                          if (userDoc.exists) {
                            setState(() {
                              userId = searchController.text;
                              firebaseUid = userDoc["uid"]; // 🔹 Fetch Firebase Authentication UID
                            });
                          } else {
                            setState(() {
                              userId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found in this community")));
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
              
                  // 🔹 Show User ID & Delete Button if User Found
                  if (userId != null)
                    ListTile(
                      title: Text("User ID: $userId"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            
                            await FirebaseFirestore.instance
                                .collection("communities")
                                .doc(communityIdController.text)
                                .collection("users")
                                .doc(userId)
                                .delete();
                              if (firebaseUid != null) {
                              try {
                                await FirebaseAuth.instance
                                    .currentUser!
                                    .delete(); //  Only works if the current user is logged in
                              } catch (e) {
                                print("Error deleting from authentication: $e");
                              }
                            }
              
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User deleted successfully")));
              
                            setState(() {
                              userId = null;
                              searchController.clear();
                              communityIdController.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}
}