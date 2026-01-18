import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            dynamic owner_flat,
            owner_mobile,
            duration_value,
            duration_unit,
            r_phno
            )
            async{

            String requester_Name=data["requesterName"]??"unknown";
            dynamic requester_flatno=data["requester-flatno"]??"unknown";
            String duration_value=data["duration_value"]??"unknown"; 
            String duration_unit=data["duration_unit"]??"unknown";
            

         final   firestore=FirebaseFirestore.instance;
         final loanref=firestore.collection("communities").doc(Cid).collection("loans");
         try{
            await loanref.add({
                "bookName":bookName,
                "ownerId":ownerId,
                "bookId":bookId,
                "owner_flat":owner_flat,
                "owner_mob":owner_mobile,
                "owner_role":owner_role,
                "requester_name":requester_Name,
                "requester_flatno":requester_flatno,
                "r_phno":r_phno,
                "duration_value":duration_value,
                "duration_unit":duration_unit,
                "Start_time":DateTime.now(),
                "End_time":await _bookReceived(duration_value,duration_unit,data),
                "loan_status":"not returned"
                
              }); 
     print(owner_mobile);
     print(owner_flat);
              
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



  Future<DateTime> _bookReceived(duration_value,duration_unit,data) async {
    

    int durationValue = int.tryParse(duration_value) ?? 0;
    if (durationValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a valid duration."),
      ));
     
    }

    DateTime startDate = DateTime.now();
    DateTime endDate;

    // Add based on selected unit
    if (duration_unit == 'Seconds') {
    endDate = startDate.add(Duration(seconds: durationValue));}
    else if (duration_unit== 'Days') {
    endDate = startDate.add(Duration(days: durationValue));
    } else if (duration_unit == 'Months') {
      endDate = DateTime(
        startDate.year,
        startDate.month + durationValue,
        startDate.day,
      );
    } else {
      endDate = DateTime(
        startDate.year + durationValue,
        startDate.month,
        startDate.day,
      );
    }
   


    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          "Timer started! Ends on: ${DateFormat('dd MMM yyyy').format(endDate)}"),
    ));
    return endDate;

    // return to home
  }
 



Future<void>remove_After_Receiving(String owner_role, String? ownerId, dynamic bookId, dynamic bookName, dynamic book_author, dynamic book_genre,Map<String, dynamic> data,dynamic owner_flat,var owner_mobile,duration_value,duration_unit,r_phno,image)async{
 if(image==null){
   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("no image data"))) ;
   return;
 }
 print(data['image']);
 await create_loan(owner_role, ownerId, bookId, bookName,  book_author, book_genre, data, owner_flat,owner_mobile,duration_value,duration_unit,r_phno);

  await FirebaseFirestore.instance
                  .collection('communities')
                  .doc(Cid)
                  .collection(owner_role)
                  .doc(ownerId)
                  .update({
                  "books": FieldValue.arrayRemove([{
                  "book-id": data['bookId'],
                  "name": data['bookName'],
                  "authorname":data['book_author'],
                  "genre": data['book_genre'],
                  "owner-id": data['requested-To'],
                  "flatno":data['ownerflatno']  ,
                  "role":data['owner_role'],
                  'image_url':data['image'],
                  "duration_unit":data['duration_unit'],
                  "duration_value":data['duration_value'],

     
                 
    }]),
    "no_of_books": FieldValue.increment(-1),
  });


    print("book deleted successfully");
   await FirebaseFirestore.instance.collection('communities').doc(Cid).collection(UserType!).doc(CustomUid).update({
   'books_read':FieldValue.increment(1)
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
              String requester = data['requesterName']??"unknown";
              String owner = data['requested-To']??"unknown";
              String r_mobile = data['r_phno']??"unknown";
              bool isRequester = requester == CustomUid;
              return ListTile(
                title: Text("$bookName - $status"),
                onTap: () => showDialog(
                  context: context,
                  builder: (dialogContext) => isRequester
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
    String image=data['image_url']??"";
    

    return AlertDialog(
      title: Text(data['bookName'],style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),),
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
        :Text("You requested this book from ${data['ownername']} ($status)"),
        
      actions: [
       if (status == "accepted") ...[
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                try{
               String owner_role=data['owner_role']??"unknown";
               String ownerId=data['requested-To']??"unknown";
               dynamic bookId=data['bookId']??"unknown";
               String bookName=data['bookName']??"unknown";
               String book_author=data['book_author']??"unknown";
               String book_genre=data['book_genre']??"unknown";
               String owner_flat=data['ownerflatno']??"unknown";
               String owner_mobile=data['ownermobno']??"unknown";
               String duration_unit=data["duration_unit"]??"unknown";
               String duration_value=data["duration_value"]??"unknown" ;
               String r_phno=data["r_phno"]??"unknown";


               print(owner_role);
               print(ownerId);
               print(bookId);
               print(bookName);
               print(book_author);
               print(book_genre);
               print(duration_value);
               print(duration_unit);
               print(r_phno);
                   //await create_loan(owner_role, ownerId, bookId, bookName, book_author, book_genre, data,owner_flat,owner_mobile);
                   print(image);
                   await remove_After_Receiving(owner_role, ownerId, bookId, bookName, book_author, book_genre, data,owner_flat,owner_mobile,duration_value,duration_unit,r_phno,image);
                   
                    await FirebaseFirestore.instance
                    .collection("communities")
                    .doc(Cid)
                    .collection("requests")
                    .doc(docId)
                    .delete();
            
                   
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }}catch(e){
                print("Error requesting book: $e");   
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



 

Widget ownerDialog(
  BuildContext context,
  Map<String, dynamic> data,
  String docId,
  String Cid,
) {
  final bool accepted = data['status'] == "accepted";

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    title: const Text(
      "Request Received",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),

    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${data['requesterName']} from ${data['requester-flatno']} has requested",
        ),
        const SizedBox(height: 6),
        Text(
          data['bookName'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text("Phone: ${data['r_phno']}"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accepted
                ? Colors.green.shade100
                : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            accepted ? "Accepted" : "Pending",
            style: TextStyle(
              color: accepted ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),

    actions: accepted
        ? [
            // ✅ Disabled Accepted Button
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Accepted",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]
        : [
            // ✅ Accept Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("communities")
                    .doc(Cid)
                    .collection("requests")
                    .doc(docId)
                    .update({"status":"accepted"});

                Navigator.pop(context);
              },
              child: const Text("Accept"),
            ),

            //  Decline Button
            TextButton(
              onPressed: () async {
                
                await FirebaseFirestore.instance
                    .collection("communities")
                    .doc(Cid)
                    .collection("requests")
                    .doc(docId)
                    .delete();
                 if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text(
                "Decline",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
  );
}

  
}




