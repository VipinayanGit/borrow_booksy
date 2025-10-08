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
                    String r_flat=data["requester-flatno"]??"null";
                    String r_phno=data["r_phno"]??"null";
                    
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
                  onTap: (){
                     show_t_Details(context,data);
                  },
                );
                }
                      
                  } ),
              );
            })
        ),
      ),
    );
  }
  void show_t_Details(Buildcontext,Map<String,dynamic>data){
    if(data.isEmpty){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book details not available.")));
    return;
  }
   String requester = data['requester_name']??"none";
                    String owner = data['ownerId']??"none";
                    String duration_value=data["duration_value"]??0 ;
                    String duration_unit=data["duration_unit"]??"";
                    String r_flat=data["requester_flatno"]??"null";
                    String r_phno=data["r_phno"]??"null";
                    String owner_flat=data["owner_flat"]??"null";
                    String owner_mobno=data["owner_mob"]??"null";
                    String book_name=data["bookName"]??"null";
                    
     showDialog(context: context,
     builder:(BuildContext context){
      return  Dialog(
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
          child: Text(book_name,
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
                    Text("Name : $requester",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Flat no : $r_flat",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Mob no : $r_phno",
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
                    Text("Name : $owner",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Flat no : $owner_flat",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text("Mob no : $owner_mobno",
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
                    Text("$duration_value $duration_unit",
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


     });


  }

}

