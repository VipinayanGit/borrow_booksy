import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Requestscreen extends StatefulWidget {
  const Requestscreen({super.key});

  @override
  State<Requestscreen> createState() => _RequestscreenState();
}

class _RequestscreenState extends State<Requestscreen> {
  @override
  void initState(){
     super.initState();
     _loaduserData();
     _refreshFirestore();
    
  }
  String?CustomUid;
  String?Cid;
  String? UserType;
  bool  isUserDataLoaded=false;
    
     void _refreshFirestore() async {
  await FirebaseFirestore.instance.disableNetwork();
  await FirebaseFirestore.instance.enableNetwork();
}
  
  Future<void>_loaduserData()async{
    print("Loading user data from SharedPreferences...");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? storeduserid=prefs.getString('userId');
    String? storedcommunityid=prefs.getString('communityId');
    bool isAdmin=prefs.getBool('isadmin')??false;
    isUserDataLoaded=true;
   

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
    
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }


Future<void>create_loan(
            String owner_role,
            String? ownerId,
            dynamic bookId,
            dynamic bookName,
            dynamic book_author,
            dynamic book_genre,
            Map<String, dynamic> data,
            var owner_mobile,
            dynamic owner_flat,
            duration_value,
            duration_unit)
            async{
            String requester_Name=data["requesterName"];
            dynamic requester_flatno=data["requester-flatno"];
            String duration_value=data["duration_value"]; 
            String duration_unit=data["duration_unit"];
            

           final   firestore=FirebaseFirestore.instance;
         final loanref=firestore.collection("communities").doc(Cid).collection("loans");
     try{
            await loanref.add({
                "ownerId":ownerId,
                "bookId":bookId,
                "owner_flat":owner_flat,
                "owner_mob":owner_mobile,
                "owner_role":owner_role,
                "requester_name":requester_Name,
                "requester_flatno":requester_flatno,
                "duration_value":duration_value,
                "duration_unit":duration_unit,
                "timestamp":DateTime.now()
              }); 
     print("loan created");
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("loan created")),
    );
     }catch(e){
               print("Error creating loan: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error creating loan")),
    );

     }   
}


Future<void>remove_After_Receiving(String owner_role, String? ownerId, dynamic bookId, dynamic bookName, dynamic book_author, dynamic book_genre,Map<String, dynamic> data,dynamic owner_flat,var owner_mobile,duration_value,duration_unit)async{
 
 await create_loan( owner_role, ownerId, bookId, bookName,  book_author, book_genre, data, owner_flat,owner_mobile,duration_value,duration_unit);
 
 
 
 
 
 
 
 
 
  await FirebaseFirestore.instance
                  .collection('communities')
                  .doc(Cid)
                  .collection(owner_role)
                  .doc(ownerId)
                  .update({
                  "books": FieldValue.arrayRemove([{
                  "book-id": bookId,
                  "name": bookName,
                  "authorname":book_author,
                  "genre": book_genre,
                  "owner-id": ownerId,
                  "flatno":data['ownerflatno'],
                  "role":owner_role,
                  "duration_unit":duration_unit,
                  "duration_value":duration_value
    }]),
    "no_of_books": FieldValue.increment(-1),
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title:Text("request screen"),

      ),
      body:!isUserDataLoaded
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
              .collection('communities')
              .doc(Cid)
              .collection('requests')
              .where(
                Filter.or(
                  Filter('requested-To', isEqualTo: CustomUid),
                  Filter('requesterName', isEqualTo: CustomUid),
                ),
              )
              .orderBy('timestamp', descending: true)
              .snapshots(),
              builder: (context, snapshot) {
              print("StreamBuilder triggered");

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

            if(snapshot.hasError) {
            print("Firestore error: ${snapshot.error}");
            return Center(child: Text("Error loading data"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("No matching documents found");
            return Center(child: Text("No requests found"));
            }

// Debug print the first document
for (var doc in snapshot.data!.docs) {
  print("Doc ID: ${doc.id}, Data: ${doc.data()}");
}

              final docs = snapshot.data!.docs;

              print("Documents found: ${docs.length}");

              if (docs.isEmpty) {
                return Center(child: Text("No requests found"));
              }

          return ListView.builder
          (
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context,index){
              var doc=snapshot.data!.docs[index];
              var data=doc.data() as Map<String,dynamic>;
              String bookName = data['bookName'] ?? 'Unknown';
              String status = data['status'] ?? 'pending';
              String requester = data['requesterName'];
              String owner = data['requested-To'];
              bool isRequester = requester == CustomUid;
              return ListTile(
                title: Text("$bookName - $status"),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => isRequester
                      ? requesterDialog(context, data, doc.id,Cid!)
                      : ownerDialog(context, data, doc.id,Cid!),
                ),
              );
            });
        }),
    );
  }
  


 Widget requesterDialog(BuildContext context, Map<String, dynamic> data, String docId,String Cid) {
  
    String status=data['status'];

    return AlertDialog(
      title: Text("Request Info"),
      content: status == "accepted"
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your request for this book was accepted by ${data['ownername']}."),
              SizedBox(height: 8),
              Text("Owner's Flat No: ${data['ownerflatno']} "),
              SizedBox(height: 8,),
              Text("Owners mobile no:${data['ownermobno']}"),
              SizedBox(height: 8),
              Text("Mark as received once you collect the book."),
            ],
          )
        :Text("You requested this book from ${data['ownername']}"),
      actions: [
       if (status == "accepted") ...[
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("communities")
                    .doc(Cid)
                    .collection("requests")
                    .doc(docId)
                    .delete();
                    
                 
               String owner_role=data['owner_role'];
               String ownerId=data['requested-To'];
               dynamic bookId=data['bookId'];
               String bookName=data['bookName'];
               String book_author=data['book_author'];
               String book_genre=data['book_genre'];
               String owner_flat=data['ownerflatno'];
               String owner_mobile=data['ownerflatno'];
               String duration_unit=data["duration_unit"];
               String duration_value=data["duration_value"] ;

            
               print(owner_role);
               print(ownerId);
               print(bookId);
               print(bookName);
               print(book_author);
               print(book_genre);
               print(duration_value);
               print(duration_unit);
                   //await create_loan(owner_role, ownerId, bookId, bookName, book_author, book_genre, data,owner_flat,owner_mobile);
                   await remove_After_Receiving(owner_role, ownerId, bookId, bookName, book_author, book_genre, data,owner_flat,owner_mobile,duration_value,duration_unit);
               
                   print("book deleted successfully");
                   
              if (mounted) {
                Navigator.pop(context);
              }
               
              },
              child: Text("Book Received", style: TextStyle(color: Colors.green)),
            );
          }
        ),
      ] else ...[
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("communities")
                .doc(Cid)
                .collection("requests")
                .doc(docId)
                .delete();
            Navigator.pop(context);
          },
          child: Text("Cancel Request", style: TextStyle(color: Colors.red)),
        ),
      ],
      ],
    );
  }


 
 Widget ownerDialog(BuildContext context, Map<String, dynamic> data, String docId,Cid) {
    return AlertDialog(
      title: Text("Request Received"),
      content: Text("${data['requesterName']} from ${data['requester-flatno']} has requested this book."),
      actions: [
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("communities")
                .doc(Cid)
                .collection("requests")
                .doc(docId)
                .update({"status": "accepted"});
            Navigator.pop(context);
          },
          child: Text("Accept"),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection("communities")
                .doc(Cid)
                .collection("requests")
                .doc(docId)
                .delete();
            Navigator.pop(context);
          },
          child: Text("Decline", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  
}




