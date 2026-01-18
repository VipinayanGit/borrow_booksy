import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
    late String lend_docId;
  late Map<String, dynamic> lend_data;


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
  Map<String, dynamic> loanTimers = {};

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books lended"),
      ),
      body: !isUserDataLoaded
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
              .collection('communities')
              .doc(Cid)
              .collection('loans')
              .where(
                Filter.or(
                  Filter('ownerId', isEqualTo: CustomUid),
                  Filter('requester_name', isEqualTo: CustomUid),
                ),
              )
              .where(Filter('loan_status',isEqualTo: "not returned"))
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
              //String status = data['status'] ?? 'pending';
              String requester = data['requester_name'];
              String owner = data['ownerId'];
              String r_mobile=data['r_phno'];
              bool isRequester = requester == CustomUid;
                String typeLabel = isRequester ? "borrowed" : "donated";
              return ListTile(
                title: Text("$bookName - $typeLabel"),
                onTap: ()=> showDialog(
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
  
    

    return Dialog(
  backgroundColor: Colors.grey[900],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
         Center(
          child: Text(
            "Book Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(data["bookName"],
              style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            "Owner details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name : ${data["ownerId"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Flat no : ${data["owner_flat"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Mob no : ${data["owner_mob"]}",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
  
        const SizedBox(height: 30),
         Center(
          child: Text(
            "Duration ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${data["duration_value"]} ${data["duration_unit"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }


 
 Widget ownerDialog(BuildContext context, Map<String, dynamic> data, String docId,Cid) {
    return Dialog(
  backgroundColor: Colors.grey[900],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
         Center(
          child: Text(
            "Book Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(data["bookName"],
              style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            "Requester details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name : ${data["requester_name"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Flat no : ${data["requester_flatno"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Mob no : ${data["r_phno"]}",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
         Center(
          child: Text(
            "Duration ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${data["duration_value"]} ${data["duration_unit"]}",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(onPressed: ()async{
            await book_Returned(docId);
          },
           child:Text("book returned")),
        )
      ],
    ),
  ),
);
 }





 Future<void> book_Returned(docId)async{
       DocumentSnapshot<Map<String,dynamic>>lendchecking=await FirebaseFirestore.instance.collection('communities').doc(Cid).collection('loans').doc(docId).get();
       bool isreturned = lendchecking['loan_status']=='returned';
       if(!isreturned){
        await FirebaseFirestore.instance.collection('communities').doc(Cid).collection('loans').doc(docId).update(
          {
            'loan_status':'returned',
            'returned_on': DateTime.now().toIso8601String(),
          }
        );
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Book marked as returned")),
      );
       }
       else{
        return;
       }
 }
  
}
