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
   
  }
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
      print("Cid updated: $Cid");
      
      
     
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }
   Future<List<Map<String, dynamic>>> fetchBooksFromFirestore() async {
    if (Cid == null) {
      print("⚠️ Cid is null, returning empty book list.");
      return []; // Return empty list if community ID is not set
    }

    List<Map<String, dynamic>> allBooks = [];

    // ✅ Fetch Books from Users Subcollection
    var usersSnapshot = await FirebaseFirestore.instance
        .collection("communities")
        .doc(Cid)
        .collection("users")
        .get();

    for (var userDoc in usersSnapshot.docs) {
      var userData = userDoc.data();
      print("👤 User Found: ${userDoc.id}, Data: $userData");
      if (userData.containsKey("books")) {
        print("📚 Books from ${userDoc.id}: ${userData["books"]}");
        allBooks.addAll(List<Map<String, dynamic>>.from(userData["books"]));
      } else {
        print("⚠️ No books field found for user ${userDoc.id}");
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
      print("👤 Admin Found: ${adminDoc.id}, Data: $adminData");

      if (adminData.containsKey("books")) {
        print("📚 Books from ${adminDoc.id}: ${adminData["books"]}");
        allBooks.addAll(List<Map<String, dynamic>>.from(adminData["books"]));
      } else {
        print("⚠️ No books field found for admin ${adminDoc.id}");
      }
    }

    print("✅ Final Book List: $allBooks");
    return allBooks;
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
                future: Cid == null ? Future.value([]) : fetchBooksFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No books found in your community!"));
                  }

                 var allBooks = snapshot.data!;
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
                  itemCount: allBooks.length,
                  itemBuilder: (context, index) {
                    var book = allBooks[index];
                    return GestureDetector(
                onTap: () {
                //  _showbookdetails(context, book, index);
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

}
