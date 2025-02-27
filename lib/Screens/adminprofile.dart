import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/drive/upload_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:borrow_booksy/Screens/superadmin.dart';
import 'package:flutter/services.dart';

class Adminprofile extends StatefulWidget {
  //  final GoogleDriveService driveService;
 // Adminprofile({super.key, required this.driveService}) : super(); // Initialize driveService here
  Adminprofile({super.key});


  @override
  State<Adminprofile> createState() => _ProfilescreenState();

}

class _ProfilescreenState extends State<Adminprofile> {
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _Formkey=GlobalKey<FormState>();
  final List<Map<String, String>> books = []; // List to store books (initially empty)
  TextEditingController namecontroller=TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController passwordcontroller =TextEditingController();
  TextEditingController useridcontroller=TextEditingController();
  TextEditingController communityidcontroller=TextEditingController();
  String name="",email="",password="",userid="",communityid="";


  // final Function _manageusers;
  // Adminprofile(this._manageusers);
  Future<void>adduser(String name,String email,String password,String communityid,String userid)async{
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
     "password":password,
    "communityid":communityid,
    "uid":firebaseUid
  });
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created")));
 
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
   communityidcontroller.clear();
   useridcontroller.clear();



}catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  }

 
}


  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _ScaffoldKey,
        appBar: AppBar(
          title: Text("ADMIN PROFILE"),
          actions: [
            Icon(Icons.person_pin),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                _ScaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Container(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the drawer
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Contact"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("Support"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("help"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("Log out"),
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login()));//driveService: widget.driveService,
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(radius: 50),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Apartment name",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text("Name"),
                            Text("flat no"),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Container(
                                  height: 35,
                                  width: 85,
                                  child: ElevatedButton(
                                    onPressed:(){ _addbookdialogue(context);},
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Add Books",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Container(
                                  height: 35,
                                  width: 85,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _manageusers(context);
                                    },
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Manage users",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.book),
                    text: "your Rack",
                  ),
                  Tab(
                    icon: Icon(Icons.book),
                    text: "History",
                  ),
                ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // "Your Rack" tab: Grid of books
                      books.isEmpty
                          ? Center(child: Text("your rack is empty"))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 3 / 4,
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing: 10, // Spacing between columns
                                mainAxisSpacing: 10, // Spacing between rows
                              ),
                              itemCount: books.length, // Example: number of books
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showbookdetails(context, book, index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.white)),
                                    child: Center(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          //padding: EdgeInsets.all(10),
                                          height: 100,
                                          width: 90,
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          book["name"]!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(book["author"]!)
                                      ],
                                    )),
                                  ),
                                );
                              },
                            ),
                      // "History" tab: Single container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          //color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Container(
                          //color: Colors.blue,
                          height: 250,
                          width: 250,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 50,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 130,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 130,
                                left: 70,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
  //Manage book dialogue box
  // void _showdialoguebox(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Manage Books"),
  //           content: Text("choose any option"),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 _addbookdialogue(context);
  //               },
  //               child: Text("add"),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text("remove"),
  //             ),
  //           ],
  //         );
  //       });
  // }

//Add book dialogue box
  void _addbookdialogue(BuildContext context) {
    final _bookcontroller = TextEditingController();
    final _authorcontroller = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add book"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Text("Upload book image"),
                      icon: Icon(Icons.upload_file),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _bookcontroller,
                    decoration: InputDecoration(
                      hintText: "Book name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _authorcontroller,
                    decoration: InputDecoration(
                      hintText: "Author name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      String Bookname = _bookcontroller.text;
                      String authorname = _authorcontroller.text;
                      if (Bookname.isNotEmpty && authorname.isNotEmpty) {
                        setState(() {
                          books.add({
                            "name": Bookname,
                            "author": authorname,
                          });
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("please fill all the fields"),
                        ));
                      }
                    },
                    child: Text("add"),
                  ),
                ],
              ),
            ],
          );
        });
  }

//book detail dialogue box
 void _showbookdetails(BuildContext context, Map<String, String> book, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.red, // Placeholder for book image
                    width: 100,
                    height: 150,
                  ),
                ),
                SizedBox(width: 16),
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Book Name
                      Text(
                        book["name"]!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible, // Handles long text gracefully
                        maxLines: 4,
                      ),
                      SizedBox(height: 8),
                      // Author Name
                      Text(
                        "Author: ${book["author"]!}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      // Description (optional)
                      // Text(
                      //   "Description: This is a sample description of the book. "
                      //   "It provides an overview of the book's content and purpose.",
                      //   style: TextStyle(fontSize: 14),
                      //   textAlign: TextAlign.justify,
                      // ),
                      // SizedBox(height: 16),
                      // Action Buttons
                      Column(
                       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Request",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Remove book from list
                              setState(() {
                                books.removeAt(index);
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Remove",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
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
