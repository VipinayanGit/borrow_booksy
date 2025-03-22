import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/drive/upload_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/pubsub/v1.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profilescreen extends StatefulWidget {
  // final GoogleDriveService driveService;
  // Profilescreen({required this.driveService, Key? key}) : super(key: key);
  Profilescreen({super.key});
  
   
  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  void initState(){
    super.initState();
    _loaduserData();
  }
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Map<String, String>> books = []; // List to store books (initially empty)
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String? selectedGenre;
  String?CustomUid;
  String?Cid;
  String? UserType;
  Map<String, dynamic>? userData;
  
  Future<void>_loaduserData()async{
    print("Loading user data from SharedPreferences...");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? storeduserid=prefs.getString('userId');
    String? storedcommunityid=prefs.getString('communityId');
    bool isAdmin=prefs.getBool('isadmin')??false;

    print("Stored User ID: $storeduserid");
    print("Stored Community ID: $storedcommunityid");
    print("Is Admin: $isAdmin");
    

    if(storeduserid!=null&&storedcommunityid!=null){
      setState(() {
        CustomUid=storeduserid;
        Cid=storedcommunityid;
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
     print("Checking collection: communities -> $Cid -> $UserType -> $CustomUid");

     print("Fetching user data...");
     print("Community ID: $Cid");
     print("Custom User ID: $CustomUid");
     print("User Type: $UserType");

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
 // bool isadmin=false;
  // Future<void> pickAndUploadImage(BuildContext context) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     File file = File(result.files.single.path!);
  //     String? userId = await getCurrentUserId(); // Fetch user ID from Firebase
  //     if (userId == null) return;
  //     await widget.driveService.uploadImage(file, userId);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Image uploaded successfully!")),
  //     );
  //   }
  // }

   // Function to fetch the current user ID from Firebase Authentication
  // Future<String?> getCurrentUserId() async {
  //    String? id= FirebaseAuth.instance.currentUser?.uid;
  //   return id; // Replace with actual user ID fetching logic
  // }
 
Future<void> _storebookindb( String bookname, String authorname, String genre) async {
   
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection("communities").doc(Cid).collection(UserType!).doc(CustomUid);

  await userDocRef.update({
    "books": FieldValue.arrayUnion([
      {
        "name": bookname,
        "authorname": authorname,
        "genre": genre,
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
          "name": book["name"],
          "authorname": book["authorname"], // Ensure Firestore uses this key
          "genre": book["genre"],
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

    Navigator.pop(context);
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




  void logout()async{
    await FirebaseAuth.instance.signOut();
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _ScaffoldKey,
        appBar: AppBar(
          title: Text("profilescreen"),
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
                  onTap: ()async {
                    logout();
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
                            Text("flat no"),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Container(
                                    height: 30,
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: () => _addbookdialogue(context),
                                      child: Text(
                                        "Add Books",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
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
               String authorName = book["author"] ?? "Unknown Author";
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
                          color: Colors.red, // Placeholder for book image
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
    
    List<String> genres = ["Fiction", "Non-Fiction", "Mystery", "Fantasy", "Science Fiction", "Biography", "History", "Poetry"];
    selectedGenre=null;

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
                    
                    }),
                    SizedBox(height: 10),
                  

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
                        maxLines: 1,
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
                        maxLines: 1,
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
}
