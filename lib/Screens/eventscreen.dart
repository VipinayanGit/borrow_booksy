import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Eventscreen extends StatefulWidget {
  const Eventscreen({super.key});

  @override
  State<Eventscreen> createState() => _EventscreenState();
}

class _EventscreenState extends State<Eventscreen> {

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
  Future<void> postMessage(String message) async {
    if (Cid == null || message.isEmpty) return;
    await FirebaseFirestore.instance
        .collection("communities")
        .doc(Cid)
        .collection("messages")
        .add({
      "message": message,
      "timestamp": FieldValue.serverTimestamp(), // For sorting
    });
  }

  // 🔹 Show Message Input Dialog
  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Write a Message"),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: InputDecoration(hintText: "Enter your message..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              messageController.clear();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                postMessage(messageController.text);
              }
              Navigator.pop(context);
              messageController.clear();
            },
            child: Text("Publish"),
          ),
        ],
      ),
    );
  }
 void _showMessageDetails(String message, String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Message Details"),
        content: Text(message),
        actions: [
          
          UserType=='admins'?  TextButton(
            onPressed: () {
              _deleteMessage(messageId);
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ):Container()
        ],
      ),
    );
  }
    Future<void> _deleteMessage(String messageId) async {
    if (Cid == null) return;
    await FirebaseFirestore.instance
        .collection("communities")
        .doc(Cid)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

   List<String> messages = []; // Stores messages temporarily
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      body: Cid == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("communities")
                  .doc(Cid)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index];
                    String messageId = messageData.id;
                    String messageText = messageData["message"];

                    return GestureDetector(
                      onTap: () => _showMessageDetails(messageText, messageId),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            messageText,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          
       floatingActionButton: UserType=='admins'?  FloatingActionButton(
        onPressed: _showMessageDialog,
        child: Icon(Icons.add),
      ):null,
    );
  }
}