import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/Screens/requestscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class Adminprofile extends StatefulWidget {
  //  final GoogleDriveService driveService;
 // Adminprofile({super.key, required this.driveService}) : super(); // Initialize driveService here
  Adminprofile({super.key});


  @override
  State<Adminprofile> createState() => _ProfilescreenState();

}

class _ProfilescreenState extends State<Adminprofile> {
   @override
    void initState(){
    super.initState();
    _loaduserData();
  } 

   


  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _Formkey=GlobalKey<FormState>();
  final List<Map<String, dynamic>> books = []; // List to store books (initially empty)
  TextEditingController namecontroller=TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController passwordcontroller =TextEditingController();
  TextEditingController useridcontroller=TextEditingController();
  TextEditingController communityidcontroller=TextEditingController();
  TextEditingController flatcontroller=TextEditingController();
  TextEditingController phnocontroller=TextEditingController();
  String name="",email="",password="",userid="",communityid="",flatno="",phno="";
  String?selectedGenre;
  String?CustomUid;
  String?Cid;
  String?UserType;
  String?flat;
  Map<String, dynamic>? userData;

 Future<void>_loaduserData()async{
    print("Loading user data from SharedPreferences...");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? storeduserid=prefs.getString('userId');
    String? storedcommunityid=prefs.getString('communityId');
    String? storedflatno=prefs.getString('flat');
    bool isAdmin=prefs.getBool('isadmin')??false;

    print("Stored User ID: $storeduserid");
    print("Stored Community ID: $storedcommunityid");
    print("Is Admin: $isAdmin");
    print("Stored flatno:$storedflatno");
    

    if(storeduserid!=null&&storedcommunityid!=null){
      setState(() {
        CustomUid=storeduserid;
        Cid=storedcommunityid;
        flat=storedflatno;
        UserType=isAdmin?'admins':'users';

      });

      print("calling _fetchuserdata()..");
      _fetchuserdata();
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }
  Future<void>_fetchuserdata()async{
    FirebaseFirestore firestore=FirebaseFirestore.instance;
     print("Fetching user data from Firestore...");
     print("Checking collection: communities -> $Cid -> $UserType -> $CustomUid->$flat");

     print("Fetching user data...");
     print("Community ID: $Cid");
     print("Custom User ID: $CustomUid");
     print("User Type: $UserType");
     print("flat no: $flat");

    if (Cid == null || CustomUid == null || UserType == null) {
    print("Error: Missing required values for fetching user data.");
    return;
  }
    DocumentSnapshot UserDoc=await firestore
    .collection("communities")
    .doc(Cid)
    .collection(UserType!)
    .doc(CustomUid)
    .get();

    if(UserDoc.exists){
      print("User data fetched successfully: ${UserDoc.data()}");
      setState(() {
        userData=UserDoc.data() as Map<String,dynamic>;
      });
    }else {
    print("Error: User document not found in Firestore.");
  }
  }


  // final Function _manageusers;
  // Adminprofile(this._manageusers);
  Future<void>adduser(String name,String email,String password,String userid,String flatno,String phno)async{
  DocumentSnapshot communitydoc=await FirebaseFirestore.instance.collection("communities").doc(Cid).get();
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


  await FirebaseFirestore.instance.collection("communities").doc(Cid).collection("users").doc(userid).set({
    "name":name,
    "email":email,
     "password":password,
    "communityid":communityid,
    "uid":firebaseUid,
    "role":"user",
    "flatno":flatno,
    "phno":phno
  });
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created")));
 
   namecontroller.clear();
   emailcontroller.clear();
   passwordcontroller.clear();
  
   useridcontroller.clear();
   flatcontroller.clear();
   phnocontroller.clear();



}catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
  }

 
}
Future<void> _storebookindb( String bookname, String authorname, String genre) async {
   
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection("communities").doc(Cid).collection(UserType!).doc(CustomUid);
   

   var uuid=Uuid();
  String bookId = uuid.v4();

  await userDocRef.update({
    "books": FieldValue.arrayUnion([
      { 
        "book-id":bookId,
        "name": bookname,
        "authorname": authorname,
        "genre": genre,
        "owner-id":CustomUid,
      //  "timestamp": DateTime.now(),
        "flatno":flat,
        "role":UserType
      }
    ]),
    "no_of_books": FieldValue.increment(1),
  }, 
  );

 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("book added successfully")));
   
} 
Future<void> _removeBookFromDB(Map<String, dynamic> book, int index) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference userDocRef = firestore
      .collection("communities")
      .doc(Cid)  
      .collection(UserType!)  
      .doc(CustomUid);  

  try {
    print("📌 Books before removal: $books");
    print("📌 Attempting to remove: ${book['name']} - ${book['authorname']} - ${book['genre']}");

    // Fetch latest books list from Firestore before attempting to remove
    DocumentSnapshot snapshot = await userDocRef.get();
    List<dynamic> currentBooks = (snapshot.data() as Map<String, dynamic>)["books"] ?? [];
    print("📌 Firestore Books before removing: $currentBooks");

    if (currentBooks.isEmpty || index >= currentBooks.length) {
      print("⚠️ Books list is empty or index out of range!");
      return;
    }

    // Remove from Firestore
    await userDocRef.update({
      "books": FieldValue.arrayRemove([
        {
          "book-id":book["book-id"],
          "name": book["name"],
          "authorname": book["authorname"], // Ensure Firestore uses this key
          "genre": book["genre"],
          "owner-id":book["owner-id"],
          //"timestamp":book["timestamp"],
          "flatno":book['flatno'],
          "role":book['role']
        }
      ]),
      "no_of_books": FieldValue.increment(-1),
    });

    print("✅ Firestore update successful!");

    // Fetch books again to force UI update
    snapshot = await userDocRef.get();
    List<dynamic> updatedBooks = (snapshot.data() as Map<String, dynamic>)["books"] ?? [];
    print("📌 Firestore Books after removing: $updatedBooks");

    // UI should update via StreamBuilder, but if not, refresh manually
    setState(() {}); // Force UI refresh

   // Navigator.pop(context);
  } catch (e) {
    print("❌ Error removing book: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to remove book: $e")),
    );
  }
}
Stream<List<Map<String, dynamic>>> getBooksStream() {
  return FirebaseFirestore.instance
      .collection("communities")
      .doc(Cid)
      .collection(UserType!)
      .doc(CustomUid)
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          List<dynamic>? bookList = doc.get("books");
          return (bookList ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
        }
        return []; // Return empty list instead of null
      });
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
             IconButton(
              onPressed:(){Navigator.push(context,MaterialPageRoute(builder: (context)=>Requestscreen()));},
              icon:Icon(Icons.person)),
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
                               userData != null ? userData!['communityid'] ?? 'N/A' : 'Loading...',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(userData != null ? userData!['name'] ?? 'N/A' : 'Loading...'),
                            Text(userData != null ? userData!['flatno'] ?? 'N/A' : 'Loading...'),
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
                  // Tab(
                  //   icon: Icon(Icons.book),
                  //   text: "History",
                  // ),
                ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // "Your Rack" tab: Grid of books
                      StreamBuilder<List<Map<String,dynamic>>>(
                        stream:getBooksStream(),
                        builder:(context,snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator());
                          }
                        if(!snapshot.hasData||snapshot.data!.isEmpty){
                          return Center(child: Text("your rack is empty"));
                        }
                        List<Map<String,dynamic>>books=snapshot.data!;

                        return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 3 / 4,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
                final book = books[index];
               String bookName = book["name"] ?? "Unknown Book";
               String authorName = book["authorname"] ?? "Unknown Author";
               String genre = book["genre"] ?? "Unknown Genre";

              

              return GestureDetector(
                onTap: () {
                  _showbookdetails(context, book, index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 90,
                           decoration: BoxDecoration(
                              image: DecorationImage(
                                image:AssetImage("assets/bookpic.jpg") ,
                                
                              ),
                             
                            ), // Placeholder for book image
                        ),
                        SizedBox(height: 10),
                        Text(
                          bookName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(authorName),
                        Text(
                          genre,
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

                         }
                      ),


                     
                      // "History" tab: Single container
                      // Container(
                      //   padding: const EdgeInsets.all(16.0),
                      //   margin: const EdgeInsets.all(16.0),
                      //   decoration: BoxDecoration(
                      //     //color: Colors.blueAccent.withOpacity(0.2),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: Center(
                      //       child: Container(
                      //     //color: Colors.blue,
                      //     height: 250,
                      //     width: 250,
                      //     child: Stack(
                      //       children: [
                      //         Positioned(
                      //           top: 50,
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             decoration: BoxDecoration(
                      //               border: Border.all(color: Colors.white),
                      //               borderRadius: BorderRadius.circular(10),
                      //               color: Colors.greenAccent.withOpacity(0.2),
                      //             ),
                      //             child: Column(
                      //               children: [
                      //                 Text("Book donated"),
                      //                 Text("30"),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Positioned(
                      //           top: 50,
                      //           left: 130,
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             decoration: BoxDecoration(
                      //               border: Border.all(color: Colors.white),
                      //               borderRadius: BorderRadius.circular(10),
                      //               color: Colors.greenAccent.withOpacity(0.2),
                      //             ),
                      //             child: Column(
                      //               children: [
                      //                 Text("Book donated"),
                      //                 Text("30"),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Positioned(
                      //           top: 130,
                      //           left: 70,
                      //           child: Container(
                      //             padding: EdgeInsets.all(8),
                      //             decoration: BoxDecoration(
                      //               border: Border.all(color: Colors.white),
                      //               borderRadius: BorderRadius.circular(10),
                      //               color: Colors.greenAccent.withOpacity(0.2),
                      //             ),
                      //             child: Column(
                      //               children: [
                      //                 Text("Book donated"),
                      //                 Text("30"),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   )),
                      // ),
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
                    // TextFormField(
                    //   controller: communityidcontroller,
                    //   decoration: InputDecoration(labelText: "enter your community id"),
                    //    validator:(value){
                    //     if(value.toString().isEmpty){
                    //       return "type your community id";
                        
                    //     }
                    //     else{
                    //       return null;
                    //     }
                    //   },
                    // ),
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
                       
                        adduser(name, email, password,userid,flatno,phno);
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
 
  void _addbookdialogue(BuildContext context) {
    final _bookcontroller = TextEditingController();
    final _authorcontroller = TextEditingController();
  
    List<String> genres = ["Fiction", "Non-Fiction", "Mystery", "Fantasy", "Science Fiction", "Biography", "History", "Poetry"];


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
                      onPressed: (){
                        //pickAndUploadImage(context);
                      },
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
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value:selectedGenre,
                    decoration: InputDecoration(
                      hintText: "select genre",
                      border: OutlineInputBorder(),
                    ),
                    items:genres.map((String genre){
                      return DropdownMenuItem<String>(
                        value: genre,                        
                        child: Text(genre),
                        );
                    }).toList(),
                    onChanged:(String? newvalue){
                      setState(() {
                          selectedGenre=newvalue;
                      });
                    
                    })

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
                     onPressed: ()async {
                      String Bookname = _bookcontroller.text;
                      String authorname = _authorcontroller.text;
                      if (Bookname.isNotEmpty && authorname.isNotEmpty) {
                            Map<String,String>newbook={
                              "name": Bookname,
                            "author": authorname,
                            "genre":selectedGenre!,
                            };


                           await _storebookindb(Bookname,authorname,selectedGenre!);

                        setState(() {
                          books.add(newbook);
                        });
                       Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("please fill all the fields"),
                        ));
                      }
                      _bookcontroller.clear();
                      _authorcontroller.clear();
                      setState(() {
                        selectedGenre=null;
                      });
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
 void _showbookdetails(BuildContext context, Map<String, dynamic> book, int index) {
    if (book == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book details not available.")));
    return;
  }

  String bookName = book["name"] ?? "Unknown Book";
  String authorName = book["author"] ?? "Unknown Author";
  String genre = book["genre"] ?? "Unknown Genre";
  String owner=book["owner-id"]?? "Unknown owner";
  String owner_role=book['role'];

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
                    decoration: BoxDecoration(
                              image: DecorationImage(
                                image:AssetImage("assets/bookpic.jpg") ,
                                
                              ),
                             
                            ), // Placeholder for book image
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
                        bookName,
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
                        "Author: ${authorName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          
                        ),
                        
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Genre:${genre}",
                        style:TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Role:${owner_role}",
                        style:TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
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
                           onPressed: ()async {
                              // Remove book from list
                             await _removeBookFromDB(book, index);
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
