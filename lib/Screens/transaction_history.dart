import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {

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







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction History"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream:FirebaseFirestore.instance
            .collection("communities")
            .doc(Cid)
            .collection("loans")
           // .where('status', isEqualTo:"pending")
            .snapshots(),
            builder:(context,snapshot){

            if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No transactions till now "));
            }

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder:(context,index){
                    var doc=snapshot.data!.docs[index];
                    var data=doc.data() as Map<String,dynamic>;

                    String requester = data['requester_name']??"none";
                    String owner = data['ownerId']??"none";
                    String duration_value=data["duration_value"]??0 ;
                    String duration_unit=data["duration_unit"]??"";
                    print(data);
                    for (var doc in snapshot.data!.docs) {
                    print("Doc ID: ${doc.id}, Data: ${doc.data()}");
                    }
                   print("requester $requester");
                    print("owner $owner");
                final docs = snapshot.data!.docs;
                
                print("Documents found: ${docs.length}");
                
                if (docs.isEmpty) {
                  return Center(child: Center(child: Text("No requests found")));
                }else{
                  return ListTile(
                    
                  title: Text("$owner to $requester for $duration_value $duration_unit "),
                  onTap: (){},
                );
                }
                      
                  } ),
              );
            })
        ),
      ),
    );
  }
  void showDetails
}

