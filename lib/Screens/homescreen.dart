import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
 
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
 
@override
void initState(){
    super.initState();
  
    _loaduserData();
  //  fetchBooksFromFirestore();
  // futureBooks = fetchBooksFromFirestore();
   
  }
 String? selectedGenre;
  Future<List<Map<String, dynamic>>>? futureBooks;
  String?CustomUid;
  String?Cid;
  String? UserType;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> allBooks = [];
  List<Map<String, dynamic>> filteredBooks = []; 
  TextEditingController searchController = TextEditingController();

  


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
        futureBooks=fetchBooksFromFirestore();

      });
      print("Cid updated: $Cid");
      
      
     
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }
Future<List<Map<String, dynamic>>> fetchBooksFromFirestore() async {
  if (Cid == null) {
    print("⚠️ Cid is null, returning empty book list.");
    setState(() {
      allBooks = [];
      filteredBooks = [];
    });
    return [];
  }

  print("📡 Fetching books for Community ID: $Cid...");
  
  Set<String> bookNames = {};
  List<Map<String, dynamic>> books = [];

  // ✅ Fetch Books from Users Subcollection
  var usersSnapshot = await FirebaseFirestore.instance
      .collection("communities")
      .doc(Cid)
      .collection("users")
      .get();

  for (var userDoc in usersSnapshot.docs) {
    var userData = userDoc.data();
    if (userData.containsKey("books")) {
      for (var book in List<Map<String, dynamic>>.from(userData["books"])) {
        if (!bookNames.contains(book["name"])) {
          bookNames.add(book["name"]);
          books.add(book);
        }
      }
    }
  }

  // ✅ Fetch Books from Admins Subcollection
  var adminsSnapshot = await FirebaseFirestore.instance
      .collection("communities")
      .doc(Cid)
      .collection("admins")
      .get();

  for (var adminDoc in adminsSnapshot.docs) {
    var adminData = adminDoc.data();
    if (adminData.containsKey("books")) {
      for (var book in List<Map<String, dynamic>>.from(adminData["books"])) {
        if (!bookNames.contains(book["name"])) {
          bookNames.add(book["name"]);
          books.add(book);
        }
      }
    }
  }

  // ✅ Update state here, so no need for `fetchBooks()`
  setState(() {
    allBooks = books;
    filteredBooks = books; // Initialize filteredBooks here
  });

  print("✅ Final Book List: ${allBooks.length}");
  return books;
}

void filterBooks(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredBooks = List.from(allBooks); // ✅ Reset to full list if search is empty
    } else {
      filteredBooks = allBooks.where((book) {
        String bookName = book["name"]?.toLowerCase() ?? "";
        String authorName = book["authorname"]?.toLowerCase() ?? "";
        String searchText = query.toLowerCase();
        return bookName.contains(searchText) || authorName.contains(searchText);
      }).toList();
    }
  });

  print("🔍 Filtered Books: ${filteredBooks.length}"); // ✅ Debugging log
}
  Future<void>SendBookRequest({
    required String ownerId,
    required String bookId,
    required String bookName,
    required String? requesterId,
  })async{
    

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final requestsRef = firestore
      .collection("communities")
      .doc(Cid)
      .collection(UserType!)
      .doc(CustomUid)
      .collection("requests");


    try{

       QuerySnapshot existing = await requestsRef
        .where("requesterId", isEqualTo: requesterId)
        .where("bookId", isEqualTo: bookId)
        .where("status", isEqualTo: "pending")
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have already requested this book.")),
      );
      return;
    }
     
       await firestore
         .collection("communities")
         .doc(Cid)
         .collection(UserType!)
         .doc(CustomUid)
         .collection("requests")
         .add({
          "requesterId": requesterId,
          "bookId": bookId,
          "bookName": bookName,
          "status": "pending",
          "timestamp": FieldValue.serverTimestamp(),
          "requested-To":ownerId
         });

  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request sent to book owner.")),
    );
    }catch(e){
         print("Error sending request: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error sending request.")),
    );
    }


  }

  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Homescreen")),
    body: SafeArea(
      child: Column(
        children: [
          // 🔹 Search Bar (Fixed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (query) => filterBooks(query),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search books...",
                filled: true,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                
              ),
            ),
          ),

          // 🔹 Fetch Books (Fixed)
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Cid == null ? Future.value([]) :futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No books found in your community!"));
                  }

                 var allBooks = snapshot.data!;
                 if(filteredBooks.isEmpty){
                  filteredBooks=allBooks;
                 }
               //  print("Final Book List: $allBooks");
                //GridView Fix: Wrapped with Expanded
                return GridView.builder(
                  padding: EdgeInsets.all(7),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    var book = filteredBooks[index];
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
                             
                            ),  // Placeholder for book image
                        ),
                        SizedBox(height: 10),
                        Text(
                          book["name"] ?? "Unknown Book",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                        book["authorname"] ?? "Unknown Author",
                        ),
                        Text(
                           book["genre"] ?? "No Genre",
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
 void _showbookdetails(BuildContext context, Map<String, dynamic> book, int index) {
    if (book == null||book.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book details not available.")));
    return;
  }

  String bookName = book["name"] ?? "Unknown Book";
  String authorName = book["authorname"] ?? "Unknown Author";
  String genre = book["genre"] ?? "Unknown Genre";
  String owner=book["owner-id"]?? "Unknown owner";
  String bookid=book["book-id"]??"unknown bookid";

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
                      Text(
                        "Owner:${owner}",
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
                         
                         owner!=CustomUid?TextButton(
                            onPressed: ()async {
                          Navigator.pop(context);

                          await SendBookRequest(
                            ownerId: owner,
                            bookId: bookid,
                            bookName: bookName,
                            requesterId:CustomUid
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request sent to book owner")),
      );
                          
                            },
                            child: Text(
                              "Request",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ):
                          Container(),
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
