import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddBooks extends StatefulWidget {
  const AddBooks({super.key});

  @override
  State<AddBooks> createState() => _AddBooksState();
}

class _AddBooksState extends State<AddBooks> {
  @override
  void initState(){
    super.initState();
    _loaduserData();
  }
   File? _imagefile;
   final ImagePicker _picker=ImagePicker();
   String BookName="";
   bool _isLoading=false;
   TextEditingController _authornamecontroller=TextEditingController();
    List<String> d_units=["Hours","days","months","years"];
    String? final_du=null;
    List<String> genres = ["Fiction", "Non-Fiction", "Mystery", "Fantasy", "Science Fiction", "Biography", "History", "Poetry"];
    String? selectedGenre=null;
    String?CustomUid;
  String?Cid;
  String? UserType;
  String?flat;
  Map<String, dynamic>? userData;
  TextEditingController _dvController=TextEditingController();
   String d_value="";
   
 
  final List<String> forbiddenWords = ["badword","block","fuck","bitch","ass","fuck","no title","not a book"];
 
  
  Future<void>_loaduserData()async{
    print("Loading user data from SharedPreferences...");
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? storeduserid=prefs.getString('userId');
    String? storedcommunityid=prefs.getString('communityId');
    String? storedflatno=prefs.getString('flat');
    bool isAdmin=prefs.getBool('isadmin')??false;

    print("Stored User ID: $storeduserid");
    print("Stored Community ID: $storedcommunityid");
    print("Is Admin: $isAdmin");
    

    if(storeduserid!=null&&storedcommunityid!=null){
      setState(() {
        CustomUid=storeduserid;
        Cid=storedcommunityid;
        flat=storedflatno;
        UserType=isAdmin?'admins':'users';

      });

      print("calling _fetchuserdata()..");
      _fetchuserdata();
    }
    else{
      print("Error: User ID or Community ID is null.");
    }
  }
 


  Future<void>_fetchuserdata()async{
    FirebaseFirestore firestore=FirebaseFirestore.instance;
     print("Fetching user data from Firestore...");
     print("Checking collection: communities -> $Cid -> $UserType -> $CustomUid->$flat");

     print("Fetching user data...");
     print("Community ID: $Cid");
     print("Custom User ID: $CustomUid");
     print('flat no: $flat');
     print("User Type: $UserType");

    if (Cid == null || CustomUid == null || UserType == null) {
    print("Error: Missing required values for fetching user data.");
    return;
  }
    DocumentSnapshot UserDoc=await firestore
    .collection("communities")
    .doc(Cid)
    .collection(UserType!)
    .doc(CustomUid)
    .get();

    if(UserDoc.exists){
      print("User data fetched successfully: ${UserDoc.data()}");
      setState(() {
        userData=UserDoc.data() as Map<String,dynamic>;
      });
    }else {
    print("Error: User document not found in Firestore.");
  }
  }
   
   Future<void> pickImage(ImageSource source)async{
   final PickedFile=await _picker.pickImage(source: source);
   if(PickedFile!=null){
    setState(() {
      _imagefile=File(PickedFile.path);
    });
   }  
    }


   void showpickeroption(BuildContext context){
  showModalBottomSheet(context: context,
   builder:(BuildContext bc){
    return SafeArea(
      child:Wrap(
      children:<Widget>[
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
    ));
   });
} 


   Future<void>sendImagetoPython()async{
  if(_imagefile==null) return;

  setState(() {
    _isLoading=true;
  });

  try{
   // print("📤 Sending request to: $uri");

//print("📥 Response status: ${res.statusCode}");
//print("📥 Response body: ${res.body}");
    var uri = Uri.parse("http://131.131.70.3:5000/process_image");
    var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          _imagefile!.path,
        ));

              var response = await request.send();

      if (response.statusCode == 200) {
          var res = await http.Response.fromStream(response);
           var data = jsonDecode(res.body);
        setState(() {
            print(data['gemini_response']);    
            BookName=data['gemini_response'];                
        });
      } else {
        print("❌ Upload failed: ${response.statusCode}");
      }

  }   catch (e) {
      print("⚠️ Error: $e");
    }finally{
      setState(() {
        _isLoading=false;
      });
    }
  }

Future<void> _storebookindb( String bookname, String authorname, String genre,String final_du, d_value) async {
   
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  DocumentReference userDocRef = firestore.collection("communities").doc(Cid).collection(UserType!).doc(CustomUid);
   
   setState(() {
     _isLoading=true;
   });
   var uuid=Uuid();
  String bookId = uuid.v4();

   String? imageUrl;
  if (_imagefile != null) {
    imageUrl = await uploadImageToCloudinary(_imagefile!, bookId, Cid!);
  }

  await userDocRef.update({
    "books": FieldValue.arrayUnion([
      { 
        "book-id":bookId,
        "name": bookname,
        "authorname": authorname,
        "genre": genre,
        "owner-id":CustomUid,
      //  "timestamp": DateTime.now(),
        "flatno":flat,
        "role":UserType,
        "image_url":imageUrl??"",
        "duration_value":d_value,
         "duration_unit":final_du,
      }
    ]),
    "no_of_books": FieldValue.increment(1),
  }, 
  );
 setState(() {
   _isLoading=false;
 });
 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("book added successfully")));
} 

Future<String?> uploadImageToCloudinary(
  File imageFile, String bookId, String communityFolderName) async {
  const cloudName = 'di24ilgw4';
  const uploadPreset = 'borrowbooksy';

  try {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'communities/$communityFolderName'
      ..fields['public_id'] = bookId
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Adding books"),
         
      ),
      body: SafeArea(
        child:SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
               Center(
                 child: Column(
                   children: [
                     ElevatedButton(onPressed: (){showpickeroption(context);},
                      child:Text("add books")),
                    SizedBox(height: 20),
                    if(_imagefile!=null)...[
                      Image.file(_imagefile!,height: 150),
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: ()async{
                        sendImagetoPython();
                      },
                      child:Text("verify"))
                    ],
                    SizedBox(height:10),
                    
                    SizedBox(height:10),
                    TextField(
                      controller: TextEditingController(text: BookName??""),
                      readOnly:true,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Auto fetching the book name",
                        border: OutlineInputBorder()
                      ),
          
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _authornamecontroller,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText:"Author name",
                        border: OutlineInputBorder()
                      ),
          
                    ),
                    SizedBox(height: 10),
                    
                    DropdownButtonFormField<String>(
                      value:selectedGenre,
                      decoration: InputDecoration(
                        hintText: "select genre",
                        border: OutlineInputBorder(),
                      ),
                      items:genres.map((String genre){
                        return DropdownMenuItem<String>(
                          value: genre,                        
                          child: Text(genre),
                          );
                      }).toList(),
                      onChanged:(String? newvalue){
                        setState(() {
                             
                            selectedGenre=newvalue;
                        });
                      
                      }),
                      SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dvController,
                              decoration: InputDecoration(
                                hintText: "no of",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                            value:final_du,
                            decoration: InputDecoration(
                              hintText: "select duration",
                              border: OutlineInputBorder(),
                            ),
                            items:d_units.map((String du){
                              return DropdownMenuItem<String>(
                                value: du,                        
                                child: Text(du),
                                );
                            }).toList(),
                            onChanged:(String? newdu){
                              setState(() {
                                d_value= _dvController.text;
                                  final_du=newdu;
                              });
                            
                            }),
                          ),
                        ],
                      ),
                     
                      SizedBox(height: 20),
                      ElevatedButton(onPressed: ()async{
                       String authorname=_authornamecontroller.text;
          
                        if(_imagefile==null){
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please capture or pick an image")));
                             return;
                        }
                        if(BookName=="no title"){
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("there is no title for book")));
                            return ;
                        }
                        if(BookName=="not a book"){
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("It is not a book")));
                            return ;
                        }
                        if(authorname.isEmpty&&selectedGenre==null && BookName.isEmpty){
                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please Fill the columns")));
                              return;
                        }
                        final words =BookName
                        .toLowerCase()
                        .replaceAll(RegExp(r'[^\w\s]'), '') // remove punctuation
                        .split(RegExp(r'\s+')); // split by spaces

                          for (var word in forbiddenWords) {
                            if (words.contains(word.toLowerCase())) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Upload failed ❌: Response contains forbidden word '$word'")),
                              );
                             return; // Stop upload
                            }
                          }
                    //    d_value=_dvController.text;
                        if(BookName.isNotEmpty && authorname.isNotEmpty){
                           await _storebookindb(BookName,authorname,selectedGenre!,final_du!,d_value);
                          }
                        setState(() {
                          _imagefile=null;
                          selectedGenre=null;
                          BookName="";
                          authorname="";
                          d_value="";
                          final_du=null;
                          _dvController.clear();
                          _authornamecontroller.clear();
                          });
                      },
                      child:Text("upload book")),
                      SizedBox(height: 10),
                      if(_isLoading)CircularProgressIndicator(),
                   ],
                 ),
                
               )
              ],
            ),
          ),
        )
        ),
    );
  }
}