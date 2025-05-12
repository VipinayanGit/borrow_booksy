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
    
  }
  String?CustomUid;
  String?Cid;
  String? UserType;
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
    
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }
  Stream<QuerySnapshot> getUserRequests() {
  return FirebaseFirestore.instance
    .collection('communities')
    .doc(Cid)
    .collection('requests')
    .where(
      Filter.or(
        Filter('requested-To', isEqualTo: CustomUid), // You are owner
        Filter('requesterName', isEqualTo: CustomUid)    // You are requester
      )
    )
    .orderBy('timestamp', descending: true)
    .snapshots();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title:Text("request screen"),

      ),
      body:(CustomUid == null || Cid == null)
         ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
        stream:getUserRequests(),
        builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(!snapshot.hasData||snapshot.data!.docs.isEmpty){
             return Center(child: Text("No requests found"));
          }
          print("Documents found: ${snapshot.data!.docs.length}");
for (var doc in snapshot.data!.docs) {
  print(doc.data());
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
}


 Widget requesterDialog(BuildContext context, Map<String, dynamic> data, String docId,String Cid) {
    return AlertDialog(
      title: Text("Request Info"),
      content: Text("You requested this book from ${data['ownername']}"),
      actions: [
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
    );
  }


Widget ownerDialog(BuildContext context, Map<String, dynamic> data, String docId,Cid) {
    return AlertDialog(
      title: Text("Request Received"),
      content: Text("${data['requesterName']} from ${data['flatno']} has requested this book."),
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
// Future<void> acceptRequest({
//   required String communityId,
//   required String requestId,
// })async{
//    try {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Update the request status to 'accepted'
//     await firestore
//         .collection('communities')
//         .doc(communityId)
//         .collection('requests')
//         .doc(requestId)
//         .update({
//           'status': 'accepted',
//         });

//     print('✅ Request accepted successfully.');
//   } catch (e) {
//     print('❌ Error accepting request: $e');
//   }
// }
// void _showrequestdetails(String bookname,String requesterName,String flatno,String requestId){
//   showDialog(context: context,
//    builder:(context) => AlertDialog(
//     title:Text(bookname),
//     content: Text("${requesterName} from ${flatno} has requested ${bookname} do u like to accept or reject "),
//    actions: [
//     TextButton(onPressed:(){
//       acceptRequest(
//         communityId: Cid!,
//         requestId: requestId
//         );
//     },
//     child:Text("Accept"),),
//     TextButton(onPressed: (){},
//      child:Text("reject")),
//    ],
//    ),);
// }

