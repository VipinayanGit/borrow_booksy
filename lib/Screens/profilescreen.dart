import 'dart:convert';
import 'dart:io';
import 'package:borrow_booksy/Screens/adding_books.dart';
import 'package:borrow_booksy/Screens/transactions.dart';
import 'package:borrow_booksy/Screens/login.dart';
import 'package:borrow_booksy/Screens/requestscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';





class Profilescreen extends StatefulWidget {
  
  Profilescreen({super.key});
  
   
  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {

   File? _selectedImage;
    String response_bkname="";
final ImagePicker _picker = ImagePicker();
bool loaded = false;
bool req_data=false;

  @override
  void initState(){
  
    super.initState();
  
    _loaduserData();
//R  checkIfRequestExists();
  
  }
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Map<String, String>> books = []; // List to store books (initially empty)
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String? selectedGenre;
  String?CustomUid;
  String?Cid;
  String? UserType;
  String? mobile;
  String?phno;
  String?flat;
  Map<String, dynamic>? userData;
  String CommunityName="";
 
 
  
  Future<void>_loaduserData()async{
    print("Loading user data from SharedPreferences...");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? storeduserid=prefs.getString('userId')??"";
    String? storedcommunityid=prefs.getString('communityId')??"";
    String? storedflatno=prefs.getString('flat')??"";
    bool isAdmin=prefs.getBool('isadmin')??false;
    mobile=prefs.getString('phno')??"";

    print("Stored User ID: $storeduserid");
    print("Stored Community ID: $storedcommunityid");
    print("Is Admin: $isAdmin");
    

    if(storeduserid!=null&&storedcommunityid!=null){
      setState(() {
        CustomUid=storeduserid;
        Cid=storedcommunityid;
        flat=storedflatno;
        UserType=isAdmin?'admins':'users';
        phno=mobile;

      });
              FirebaseFirestore.instance
    .collection('communities')
    .doc(Cid)
    .get()
    .then((DocumentSnapshot doc) {
      
      if (doc.exists) {
         CommunityName=doc['name'];
      }
    });


      print("calling _fetchuserdata()..");
     await Future.delayed(Duration(milliseconds: 50)); // prevent race condition
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
  final cloudName = dotenv.env['CLOUD_NAME'];
  final apiKey = dotenv.env['API_KEY'];
  final apiSecret = dotenv.env['API_SECRET'];

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


Stream<bool> hasRequestsStream() {
  return FirebaseFirestore.instance
      .collection('communities')
      .doc(Cid)
      .collection('requests')
      .where(
        Filter.or(
          Filter('requested-To', isEqualTo: CustomUid),
          Filter('requesterName', isEqualTo: CustomUid),
        ),
      )
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty);
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
            StreamBuilder<bool>(
             stream: hasRequestsStream(),
             builder: (context, snapshot) {
               if (!snapshot.hasData) {
                 return Icon(Icons.notifications_none); // initial state
               }

               final hasRequest = snapshot.data!;
           
               return IconButton(
                 icon: Icon(
                   hasRequest
                       ? Icons.notifications_active
                       : Icons.notifications_none,
                   color: hasRequest ? Colors.red : Colors.grey,
                 ),
                 onPressed: () {
                              Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => Requestscreen()),
                   );
                 },
               );
  },
),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                _ScaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(Icons.settings),
            ),

            // IconButton(onPressed:()async{
            // await  checkIfRequestExists();
            // }, icon: Icon(Icons.refresh))
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
                ListTile(
                  title: Text("transactions"),
                  onTap: ()async {
                    logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Transactions()));//driveService: widget.driveService,
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
                          "Community: $CommunityName",
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
                          ],
                        ),
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
                //  color: const Color(0xFF2F2C39),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child:Column(
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
                       Text(authorName,textAlign:TextAlign.center),
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
  String duration_unit=book['duration_unit']??"unknown duration unit";
  String duration_value=book['duration_value']??"unknown duration unit";

  showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E), // Dark modern background
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
            // Row with image + details
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
                      // Book name
                      Text(
                        bookName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Author name
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

                      // Role info
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
                  print("IMAGE URL  => $imageurl");
                  print("PUBLIC ID  => ${extractPublicId(imageurl)}"); 
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
}
