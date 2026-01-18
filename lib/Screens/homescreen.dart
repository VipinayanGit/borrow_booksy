import 'dart:async';
import 'dart:convert';
import 'package:borrow_booksy/Screens/transactions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
 
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

static bool _dialogShownThisSession = false;
@override
void initState() {
  super.initState();
  _initializeData();
  

}

Future<void> _initializeData() async {
  await _loaduserData(); // ✅ Wait until user data is loaded
 WidgetsBinding.instance.addPostFrameCallback((_){
    checkLoanTimers();  
 });
     // ✅ Now safe to call
}

//static bool dialogShownThisSession = false;
  Map<String, dynamic> loanTimers = {};
  Timer? checkTimer;
 DateTime? endDate;
 
 String? selectedGenre;
  Future<List<Map<String, dynamic>>>? futureBooks;
  String?CustomUid;
  String?Cid;
  String? UserType;
  String? flat;
  String? phno;
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
    String?storedflatno=prefs.getString('flat');
    String?mobile=prefs.getString('phno');


    

    if(storeduserid!=null&&storedcommunityid!=null){
      setState(() {
        CustomUid=storeduserid;
        Cid=storedcommunityid;
        flat=storedflatno;
        UserType=isAdmin?'admins':'users';
        futureBooks=fetchBooksFromFirestore();
        phno=mobile;
         

      });
          print("CustomUid: $CustomUid");
    print("Cid: $Cid");
    print("Is Admin: $isAdmin");
    print("flat no: $flat");
      print("Cid updated: $Cid");
      print("my mobile $phno");
      
      
     
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }


Future<void> checkLoanTimers() async {
  final firestore = FirebaseFirestore.instance;
  final prefs = await SharedPreferences.getInstance();

  // Read last time shown
  final lastShownMillis = prefs.getInt('lastDialogShownTime');
  DateTime? lastShownTime = lastShownMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(lastShownMillis)
      : null;

  final now = DateTime.now();

  // 🔴 If dialog was shown within the last 24 hours → Do NOT show again
  if (lastShownTime != null) {
    final hourspassed = now.difference(lastShownTime).inMinutes;
    if (hourspassed < 1) {
      print("⏳ Dialog was shown $hourspassed hours ago → Not showing again.");
      return;
    }
  }

  print("🔍 Checking expired loans for cid=$Cid user=$CustomUid");

  final collectionRef = firestore
      .collection('communities')
      .doc(Cid)
      .collection('loans');

  final querySnapshot = await collectionRef
      .where('loan_status', isEqualTo: 'not returned')
      .get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final endTime = (data['End_time'] as Timestamp).toDate();
    final isExpired = now.isAfter(endTime);

    if (!isExpired) continue;

    // 🔹 REQUESTER
    if (data['requester_name'] == CustomUid) {
      print("📌 Requester expired loan. Showing dialog…");

      // store timestamp
      await prefs.setInt('lastDialogShownTime', now.millisecondsSinceEpoch);

      await showDialog(
        context: context,
        builder: (_) => requesterDialog(context, data, doc.id),
      );
      return;
    }

    // 🔹 OWNER
    if (data['ownerId'] == CustomUid) {
      print("📌 Owner expired loan. Showing dialog…");

      // store timestamp
      await prefs.setInt('lastDialogShownTime', now.millisecondsSinceEpoch);

      await showDialog(
        context: context,
        builder: (_) => ownerDialog(context, data, doc.id),
      );
      return;
    }
  }
}



Widget requesterDialog(BuildContext context, Map<String, dynamic> data, String docId) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 10,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 50),

          SizedBox(height: 15),

          Text(
            "Loan Period Exceeded",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          Text(
            "Your loan period for the book:",
            style: TextStyle(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4),

          Text(
            "'${data['bookName']}' has expired.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Transactions()),
              );
            },
            child: Text(
              "View Loan Details",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}




Widget ownerDialog(BuildContext context, Map<String, dynamic> data, String docId) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 10,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 50),

          SizedBox(height: 15),

          Text(
            "Book Not Returned",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          Text(
            "${data['requester_name']} has not returned your book:",
            style: TextStyle(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4),

          Text(
            "'${data['bookName']}'",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('communities')
                  .doc(Cid)
                  .collection('loans')
                  .doc(docId)
                  .update({'loan_status': 'returned'});
              Navigator.pop(context);
            },
            child: Text(
              "Mark as Returned",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
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
    required String? requesterName,
    required String? flatno,
    required String owner_role,
    required String book_genre,
    required String book_author,
    required duration_value,
    required duration_unit,
    required phno,
    required image
  })async{
    String?ownerflatno;
    String?ownermobno;
    String?ownername;
   

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final ownerdoc=await fetchOwnerDetails(ownerId);
    

    if(ownerdoc!=null){
      ownerflatno=ownerdoc['flatno'];
      ownermobno=ownerdoc['phno'];
      ownername=ownerdoc['name'];

    }else {
  print("Owner not found in users or admins.");
}

  



    final requestsRef = firestore
      .collection("communities")
      .doc(Cid)
      .collection("requests");


    try{

       QuerySnapshot existing = await requestsRef
        .where("requesterName", isEqualTo: requesterName)
        .where("bookId", isEqualTo: bookId)
        .where("status", isEqualTo: "pending")
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You have already requested this book.")),
      );
      return;
    }
     
       await requestsRef.add({
          "requesterName": requesterName,
          "bookId": bookId,
          "bookName": bookName,
          "book_genre":book_genre,
          "status": "pending",
          "timestamp": FieldValue.serverTimestamp(),
          "requested-To":ownerId,
          "requester-flatno":flatno,
          "ownername":ownername,
          "ownerflatno":ownerflatno,
          "ownermobno":ownermobno,
          "owner_role":owner_role,
          "book_author":book_author,
          "duration_value":duration_value,
          "duration_unit":duration_unit,
          "r_phno":phno,
          "image":image

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
  


Future<Map<String, dynamic>?> fetchOwnerDetails(String ownerid) async{


  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final userdoc = await firestore
      .collection("communities")
      .doc(Cid)
      .collection('users')
      .doc(ownerid)
      .get();

  if (userdoc.exists) {
    return userdoc.data(); 
  }

  final admindoc = await firestore
      .collection("communities")
      .doc(Cid)
      .collection('admins')
      .doc(ownerid)
      .get();

  if (admindoc.exists) {
    return admindoc.data(); 
  }

  return null;


}



void refreshBooks() async {
  setState(() {
    futureBooks = fetchBooksFromFirestore();
  });
}

 
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Homescreen"),
      actions: [
        IconButton(onPressed: (){
           refreshBooks(); 
        },
         icon:Icon(Icons.refresh))
      ],
    ),
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
                    childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 1.45),
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
                  padding:EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    //color: const Color(0xFF2F2C39),
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
                            padding: EdgeInsets.only(top: 10),
                            height: 150,
                            width: 120,
                           decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:NetworkImage(book["image_url"]??"") ,
                                  fit: BoxFit.fill
                                  
                                ),
                               
                              ),  // Placeholder for book image
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          book["name"] ?? "Unknown Book",
                          textAlign: TextAlign.center,
                          style: TextStyle( color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        ),
                        Text(
                        book["authorname"] ?? "Unknown Author",
                        style:  TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        Text(
                           book["genre"] ?? "No Genre",
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
  String owner_role=book['role']??'unknown role';
  String book_genre=book['genre']??'unknown genre';
  String book_author=book['authorname']??"unknwon book author";
  String imageurl=book['image_url']??"unknown image";
  String duration_value=book["duration_value"].toString() ;
  String duration_unit=book["duration_unit"];

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
                      Text(
                        bookName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "by $authorName",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Genre Chip
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
                      // Owner Info
                      _buildDetailRow("Owner", owner),
                      const SizedBox(height: 4),
                      _buildDetailRow("Role", owner_role),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                          "Duration", "$duration_value $duration_unit"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Request Button
            owner != CustomUid
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await SendBookRequest(
                          ownerId: owner,
                          bookId: bookid,
                          bookName: bookName,
                          requesterName: CustomUid,
                          flatno: flat,
                          owner_role: owner_role,
                          book_genre: book_genre,
                          book_author: book_author,
                          duration_value: duration_value,
                          duration_unit: duration_unit,
                          phno: phno,
                          image: imageurl,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Request sent to book owner"),
                          ),
                        );
                      },
                      child: const Text(
                        "Request Book",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
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
