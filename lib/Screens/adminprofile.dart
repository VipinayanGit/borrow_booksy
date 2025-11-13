import 'dart:convert';
import 'dart:io';
import 'package:borrow_booksy/Screens/adding_books.dart';
import 'package:borrow_booksy/Screens/transactions.dart';
import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/Screens/requestscreen.dart';
import 'package:borrow_booksy/Screens/transaction_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/src/widgets/image.dart';

class Adminprofile extends StatefulWidget {
 
  Adminprofile({super.key});


  @override
  State<Adminprofile> createState() => _ProfilescreenState();

}

class _ProfilescreenState extends State<Adminprofile> {

   File? _selectedImage;
final ImagePicker _picker = ImagePicker();

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
    "phno":phno,
    "books_read":0
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






String extractPublicId(String imageUrl) {
  final uri = Uri.parse(imageUrl);
  final parts = uri.pathSegments;

  final uploadIndex = parts.indexOf('upload');
  if (uploadIndex != -1 && parts.length > uploadIndex + 1) {
    final segments = parts.sublist(uploadIndex + 2); // skip 'upload' and version
    final joined = segments.join('/');
    return joined.replaceAll('.jpg', ''); // or '.png' if needed
  }
  return '';
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
          "role":book['role'],
          "image_url":book["image_url"],
          "duration_value":book["duration_value"]??"",
          "duration_unit":book["duration_unit"]

          
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


Future<void> deleteImageFromCloudinary(String publicId) async {
  const cloudName = 'di24ilgw4';
  const apiKey = '283866122381729';
  const apiSecret = 'cVnq7zpNpHxV16NYiXAXzoFUSzQ';

  final auth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));

  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload?public_ids[]=$publicId',
  );

  final response = await http.delete(
    url,
    headers: {'Authorization': auth},
  );

  print("📩 Cloudinary Delete Response: ${response.statusCode} - ${response.body}");

  if (response.statusCode == 200) {
    print('✅ Image deleted from Cloudinary');
  } else {
    print('❌ Failed to delete image. Status: ${response.statusCode}');
  }
}

Future<void> deleteImageUsingUrl(String imageUrl) async {
  String publicId = extractPublicId(imageUrl);
  if (publicId.isNotEmpty) {
    await deleteImageFromCloudinary(publicId);
  } else {
    print('❌ Failed to extract public_id from URL');
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login()));
                  },
                ),
                ListTile(
                  title: Text("transaction history"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistory()));
                  },
                ),
                ListTile(
                  title: Text("transactions"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Transactions()));
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
                    margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF262430),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),


              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Icon
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF6E5DE7),
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),

                  // Admin Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                           userData!['name']??"unknown name",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Community: $Cid",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Flat No: $flat",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:(){Navigator.push(context,MaterialPageRoute(builder: (context)=>AddBooks()));},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6E5DE7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.book, color: Colors.white),
                                label: const Text("Add Books",style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:(){
                                  _manageusers(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF6E5DE7)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                ),
                                icon: const Icon(Icons.group,
                                    color: Color(0xFF6E5DE7)),
                                label: const Text(
                                  "Manage Users",
                                  style: TextStyle(color: Color(0xFF6E5DE7)),
                                ),
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
                 





                // Container(
                //   width: double.infinity,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                      
                //      // CircleAvatar(radius: 50),
                //       Container(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //                userData != null ? userData!['communityid'] ?? 'N/A' : 'Loading...',
                //               style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                //             ),
                //             Text(userData != null ? userData!['name'] ?? 'N/A' : 'Loading...'),
                //             Text(userData != null ? userData!['flatno'] ?? 'N/A' : 'Loading...'),
                //             SizedBox(height: 10),
                            
                //           ],
                //         ),
                //       ),
                //       Column(
                             
                //               children: [
                //                 Padding(padding: EdgeInsets.only(bottom:20)),
                //                 SizedBox(width: 5),
                //                 Container(
                //                   padding: EdgeInsets.all(10),
                //                   height: 40,
                //                   width: 120,
                //                   child: ElevatedButton(
                //                     onPressed:(){ Navigator.push(context,MaterialPageRoute(builder: (context)=>AddBooks()));},
                //                     child: Text(
                //                       textAlign: TextAlign.center,
                //                       "Add Books",
                //                       style: TextStyle(fontSize: 10),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(width: 5),
                //                 Container(
                //                   height: 40,
                //                   width: 120,
                //                   child: ElevatedButton(
                //                     onPressed: () {
                //                       _manageusers(context);
                //                     },
                //                     child: Text(
                //                       textAlign: TextAlign.center,
                //                       "Manage users",
                //                       style: TextStyle(fontSize: 10),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             )
                //     ],
                //   ),
                // ),
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
              childAspectRatio: 1.3/ 2,
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
               String imageurl=book["image_url"]??"";
               String o_role=book['role']??"";
               String o=book['owner']??"";

              

              return GestureDetector(
                onTap: () {
                  print('Book Details:\n'
      'bookName: $bookName (${bookName.runtimeType})\n'
      'authorName: $authorName (${authorName.runtimeType})\n'
      'genre: $genre (${genre.runtimeType})\n'
      'owner_role: $o_role (${o_role.runtimeType})\n'
      'owner: $o (${o.runtimeType})\n'
      'imageurl: $imageurl (${imageurl.runtimeType})');

                  _showbookdetails(context, book, index);
                },
                child: Container(
                  decoration: BoxDecoration(
                //  color: const Color(0xFF2F2C39),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Container(
                            height: 150,
                            width: 120,
                             decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:NetworkImage(imageurl) ,
                                  
                                ),
                               
                              ), // Placeholder for book image
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          bookName,
                          textAlign: TextAlign.center,
                          style: TextStyle(                           color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        ),
                        Text(authorName),
                        Text(
                          genre,
                          style: TextStyle( color: Colors.purple[200],
                          fontStyle: FontStyle.italic,),
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
 
 
 

//book detail dialogue box
 void _showbookdetails(BuildContext context, Map<String, dynamic> book, int index) {
    if (book == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book details not available.")));
    return;
  }

  String bookName = book["name"]?.toString() ?? "Unknown Book";
  String authorName = book["authorname"]?.toString()  ?? "Unknown Author";
  String genre = book["genre"]?.toString()  ?? "Unknown Genre";
  String owner=book["owner-id"]?.toString() ?? "Unknown owner";
  String owner_role=book['role']?.toString() ??"unknown role";
  String imageurl=book["image_url"]?.toString() ??"";
  String duration_value=book["duration_value"]?.toString() ??"" ;
  String duration_unit=book["duration_unit"]?.toString() ??"";
  print(bookName.runtimeType);
  print(authorName.runtimeType);
  print(genre.runtimeType);
  print(owner.runtimeType);
  print(imageurl.runtimeType);
  print(duration_value.runtimeType);
  print(duration_unit.runtimeType);
  

try{
 showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageurl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Name
                      Text(
                        bookName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Author
                      Text(
                        "by $authorName",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[400],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Genre chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3E50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Details
                      _buildDetailRow("Role", owner_role),
                      const SizedBox(height: 4),
                      _buildDetailRow("Owner", owner),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                          "Duration", "$duration_value $duration_unit"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Remove Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                onPressed: () async {
                  await deleteImageUsingUrl(imageurl);
                  await _removeBookFromDB(book, index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Book removed successfully"),
                    ),
                  );
                },
                child: const Text(
                  "Remove Book",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
}catch (e, stackTrace) {
  print('Error in showDialog: $e');
  print(stackTrace);
}
}



Widget _buildDetailRow(String label, String value) {
  return Row(
    children: [
      Text(
        "$label: ",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
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
