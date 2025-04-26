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
  Stream<QuerySnapshot> getOwnerRequests() {
  return FirebaseFirestore.instance
    .collection('communities')
    .doc(Cid)
    .collection('requests')
    .where('requested-To', isEqualTo: CustomUid)
    .where('status', isEqualTo: 'pending')
    .orderBy('timestamp', descending: true)
    .snapshots();
}
void _showrequestdetails(String bookname,String requesterName){
  showDialog(context: context,
   builder:(context) => AlertDialog(
    title:Text(bookname),
    content: Text("${requesterName} from flat no has requested ${bookname} do u like to accept or reject "),
   actions: [
    TextButton(onPressed:(){},
    child:Text("Accept"),),
    TextButton(onPressed: (){},
     child:Text("reject")),
   ],
   ),);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
          title: Text("requests"),
         ),
         body:  Cid == null
          ? Center(child: CircularProgressIndicator())
          :StreamBuilder(
            stream:getOwnerRequests() ,
            builder:(context,snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No pending requests."));
          }
          final requests=snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder:(context,index){
              var request =requests[index];
              return ListTile(
                
                title: Text(request['bookName'] ?? 'Unknown Book'),
                onTap: ()=>_showrequestdetails(request['bookName'],request['requesterName']),
              );
            } );
            }),
    );
  }
}