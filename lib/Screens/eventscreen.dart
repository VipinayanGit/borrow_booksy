import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
class Eventscreen extends StatefulWidget {
  const Eventscreen({super.key});

  @override
  State<Eventscreen> createState() => _EventscreenState();
}

class _EventscreenState extends State<Eventscreen> {
 File? _imagefile;
 TextEditingController message_controller =TextEditingController();
  @override
  void initState(){
     super.initState();
     _loaduserData();
  }
  String?CustomUid;
  String?Cid;
  String? UserType;
   
   final ImagePicker _picker=ImagePicker();
  


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
     String? imageUrl;
  if (_imagefile != null) {
    imageUrl = await uploadImageToCloudinary(_imagefile!,Cid!);
  }
    if (Cid == null || message.isEmpty) return;
    await FirebaseFirestore.instance
        .collection("communities")
        .doc(Cid)
        .collection("messages")
        .add({
      "message": message,
      "image_url":imageUrl,
      "timestamp": FieldValue.serverTimestamp(), // For sorting
    });
  }
  


Future<String?> uploadImageToCloudinary(
  File imageFile, String communityFolderName) async {
  final cloudName=dotenv.env['CLOUD_NAME'];
  final uploadPreset=dotenv.env['UPLOAD_PRESET']; 

  try {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset??"unknown"
      ..fields['folder'] = 'communities/$communityFolderName'
      
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    print("📤 Cloudinary response: $resStr");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(resStr);
      return jsonResponse['secure_url'];
    } else {
      print("❌ Upload Failed: ${response.statusCode}");
      return null;
    }
  } catch (e, stack) {
    print("🔥 Upload error: $e");
    print(stack);
    return null;
  }
}




Future<void> pickImage(ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(source: source);

  if (!mounted) return;

  if (pickedFile != null) {
    setState(() {
      _imagefile = File(pickedFile.path);
    });
    print("image taken");
  }
}




void showpick(BuildContext context){
  showModalBottomSheet(context: context,
   builder: (BuildContext bc){
       return SafeArea(
        child:Wrap(
           children: <Widget>[
                   ListTile(
          leading: Icon(Icons.photo_library),
          title: Text("gallery"),
          onTap: (){
            pickImage(ImageSource.gallery);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: Icon(Icons.camera),
          title: Text("camera"),
          onTap: (){
            pickImage(ImageSource.camera);
            Navigator.of(context).pop();
          },
        )

           ],
        ) );
   });
}

  // 🔹 Show Message Input Dialog
void _showAddEventDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Add Event"),

            
            content: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // IMAGE
                  Container(
                    height: 150,
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _imagefile != null
                        ? Image.file(_imagefile!, fit: BoxFit.cover)
                        : TextButton(
                            onPressed: () async {
                              await pickImage(ImageSource.gallery);
                              setDialogState(() {});
                            },
                            child: const Text("Add image"),
                          ),
                  ),

                  const SizedBox(height: 10),

                
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: message_controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Enter about event...",
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _imagefile = null;
                            message_controller.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          if (message_controller.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter the message"),
                              ),
                            );
                          } else {
                            postMessage(message_controller.text);
                            setState(() {
                              _imagefile = null;
                              message_controller.clear();
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Post"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
           
          );
        },
      );
    },
  );
}



String extractPublicId(String imageUrl) {
  final uri = Uri.parse(imageUrl);
  final segments = uri.pathSegments;

  final uploadIndex = segments.indexOf('upload');
  if (uploadIndex == -1) return '';

  // Everything after 'upload'
  final afterUpload = segments.sublist(uploadIndex + 1);

  // Remove version segment like v123456
  final withoutVersion =
      afterUpload.where((s) => !s.startsWith('v')).toList();

  final publicIdWithExt = withoutVersion.join('/');

  // Remove file extension
  return publicIdWithExt.replaceAll(
    RegExp(r'\.(jpg|jpeg|png|webp)$'),
    '',
  );
}




Future<void> deleteImageUsingUrl(String imageUrl) async {
  String publicId = extractPublicId(imageUrl);
  if (publicId.isNotEmpty) {
    await deleteImageFromCloudinary(publicId);
  } else {
    print('❌ Failed to extract public_id from URL');
  }
}





Future<void> deleteImageFromCloudinary(String publicId) async {
  final cloudName = dotenv.env['CLOUD_NAME'];
  final apiKey = dotenv.env['API_KEY'];
  final apiSecret = dotenv.env['API_SECRET'];

  final auth =
      'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload.json'
    '?public_ids[]=$publicId',
  );

  final response = await http.delete(
    url,
    headers: {'Authorization': auth},
  );

  print(
    '📩 Cloudinary Delete Response: '
    '${response.statusCode} ${response.body}',
  );

  if (response.statusCode == 200) {
    print('✅ Image deleted from Cloudinary');
  } else {
    print('❌ Failed to delete image');
  }
}



  Future<void> deletePost(
  String messageId,
  String imageUrl,
) async {
  if (imageUrl.isNotEmpty) {
    await deleteImageUsingUrl(imageUrl);
  }

  await FirebaseFirestore.instance
      .collection("communities")
      .doc(Cid)
      .collection("messages")
      .doc(messageId)
      .delete();
}




  Future<List<Map<String, dynamic>>> fetchTopReaders() async {
    if (Cid == null) return [];

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(Cid)
          .collection('users')
          .get();

      final adminsSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(Cid)
          .collection('admins')
          .get();

      // Merge both
      List<Map<String, dynamic>> allDocs = [
        ...usersSnapshot.docs.map((e) => e.data()),
        ...adminsSnapshot.docs.map((e) => e.data()),
      ];

      // Sort by books_read (descending)
      allDocs.sort((a, b) {
        final aBooks = (a['books_read'] ?? 0) as int;
        final bBooks = (b['books_read'] ?? 0) as int;
        return bBooks.compareTo(aBooks);
      });

      // Return top 3
      return allDocs.take(3).toList();
    } catch (e) {
      print("❌ Error fetching top readers: $e");
      return [];
    }
  }





   List<String> messages = []; // Stores messages temporarily
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Events")),
      body: Cid == null
          ? Center(child: CircularProgressIndicator())
          :Column(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchTopReaders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No readers yet.",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final topReaders = snapshot.data!;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "🏆 Top Readers",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: List.generate(topReaders.length, (index) {
                                final reader = topReaders[index];
                                final name = reader['name'] ?? 'Unknown';
                                final booksRead = reader['books_read'] ?? 0;

                                String medal = '';
                                if (index == 0) medal = '🥇';
                                if (index == 1) medal = '🥈';
                                if (index == 2) medal = '🥉';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "$medal  $name",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text("Books Read: $booksRead"),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                 Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                      String? imageUrl = messageData.data().toString().contains("image_url")
                     ? messageData["image_url"]
                     : null;
                    
                     
                      return GestureDetector(
                        onTap: (){
                           print(imageUrl);
                        },
                        child: Container(
                         // color: Colors.blueGrey,
                          child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // IMAGE SECTION
                                        if (imageUrl != null && imageUrl.isNotEmpty)
                                          ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                           top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: Icon(Icons.broken_image)),
                          );
                        },
                                            ),
                                          ),
                        
                                        // MESSAGE SECTION
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                            child: Text(
                                            messageText,
                                            style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                    UserType=="admins"? Center(
                                      child: ElevatedButton(onPressed: ()async{
                                      
                                        await deletePost(messageId, imageUrl!);
                                      
                                        
                                      print("IMAGE URL  => $imageUrl");
                                      print("PUBLIC ID  => ${extractPublicId(imageUrl)}"); 
                                      },
                                       style:ElevatedButton.styleFrom(
                                        foregroundColor: Colors.red
                                        ), child: Text("delete post")
                                        ),
                                    ):Center(child: Text("CONTACT ADMIN FOR QUERIES",style:TextStyle(fontSize: 15,color: Colors.blueGrey),)),
                                      
                                      
                                      ],
                                    ),
                          
                        ),
                      );
                     
                    },
                  );
                },
              ),
          ),
            ],
          ) ,
         
          
       floatingActionButton: UserType=='admins'?  FloatingActionButton(
        onPressed:_showAddEventDialog,
        child: Icon(Icons.add),
      ):null,
    );
  }
}