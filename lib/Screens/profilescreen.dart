import 'dart:convert';
import 'dart:io';
import 'package:borrow_booksy/Screens/adding_books.dart';
import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/Screens/requestscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';





class Profilescreen extends StatefulWidget {
  
  Profilescreen({super.key});
  
   
  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {

   File? _selectedImage;
    String response_bkname="";
final ImagePicker _picker = ImagePicker();

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
     print('flat no: $flat');
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
         // "timestamp":book["timestamp"],
          "flatno":book['flatno'],
          "role":book['role'],
          "image_url":book["image_url"],
          "duration_value":book["duration_value"],
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



  void logout()async{
    await FirebaseAuth.instance.signOut();
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        key: _ScaffoldKey,
        appBar: AppBar(
          title: Text("profilescreen"),
          actions: [
            IconButton(
              onPressed:(){Navigator.push(context,MaterialPageRoute(builder: (context)=>Requestscreen()));},
              icon:Icon(Icons.menu_book)),
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
                            Text(userData != null ? userData!['flatno'] ?? 'N/A' : 'Loading...'),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Container(
                                    height: 30,
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: () =>Navigator.push(context, MaterialPageRoute(builder:(context)=>AddBooks())),         //_addbookdialogue(context),
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
              childAspectRatio: 1.3 / 2,
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
               String imageurl=book["image_url"]??"unknown picture";

              

              return GestureDetector(
                onTap: () {
                  _showbookdetails(context, book, index);
                },
                child: SizedBox(
                  height: 190,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            height: 150,
                            width: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:NetworkImage(imageurl) ,
                                
                                
                              ),
                             
                            ), 
                          ),
                          SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              bookName,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 13),
                              maxLines: 2,
                              softWrap: true,
                            ),
                          ),
                          Flexible(child: Text(authorName,
                          style: TextStyle(fontSize: 12),)),
                          Flexible(
                            child: Text(
                              genre,
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
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




//book detail dialogue box
 void _showbookdetails(BuildContext context, Map<String, dynamic> book, int index) {
    if (book == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book details not available.")));
    return;
  }

  String bookName = book["name"] ?? "Unknown Book";
  String authorName = book["authorname"] ?? "Unknown Author";
  String genre = book["genre"] ?? "Unknown Genre";
  String owner=book["owner-id"]?? "Unknown owner";
  String owner_role=book["role"]??"unknown role";
  String imageurl=book["image_url"]??"unknown image url";

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
                      image: DecorationImage(image: NetworkImage(imageurl),
                      fit: BoxFit.cover) ,
                      
                    ),
                   
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
                        "role:${owner_role}",
                        style:TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                           Column(
                      
                        children: [
                          
                          TextButton(
                           onPressed: ()async {
                              // Remove book from list
                            await deleteImageUsingUrl(imageurl);
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
