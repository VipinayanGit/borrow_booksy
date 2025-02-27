// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:file_picker/file_picker.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis/vmwareengine/v1.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:googleapis_auth/googleapis_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'package:borrow_booksy/Screens/profilescreen.dart';

// class GoogleDriveService{
  
//  // late drive.DriveApi _drive;
//   String parentFoldername='communities'; //Mainfolder

//  // Initialize Google Drive API
// Future<void> init() async{
//   final credentials =await _loadserviceAccountCredentials();
//   final client = await clientViaServiceAccount(credentials,[drive.DriveApi.driveScope]
//  ,);
//  _drive=drive.DriveApi(client);
//  }


//  // Load service account credentials
//  Future<ServiceAccountCredentials> _loadserviceAccountCredentials() async{
//   File file=File("C:/Users/Vipinayan/Downloads/agile-genius-446705-p5-f24f8c715a1a.json");

//  String jsonString = await file.readAsString();
//   return ServiceAccountCredentials.fromJson(json.decode(jsonString));
//  }

//  Future<String?> getorCreatefolder(String foldername,{String? parentID})async{
//    final query = "name = '$foldername' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
//    final filelist=await _drive.files.list(q:query);
  
//    if (filelist.files != null && filelist.files!.isNotEmpty) {
//       return filelist.files!.first.id; // Return existing folder ID
//     }

//   //create new folder if it does not exist
//   var folder =drive.File()
//       ..name=foldername
//       ..mimeType="application/vnd.google-apps.folder"
//       ..parents=parentID!=null?[parentID]:[];

//       var createdfolder=await _drive.files.create(folder);
//       return createdfolder.id;

//  }

//  // Function to get the user's community from Firestore (Checks both Users and Admins collections)

//   Future<String?> getUserCommunity(String userId) async {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Check if user exists in "Users" collection
//     QuerySnapshot usersSnapshot = await firestore.collectionGroup('users').where(FieldPath.documentId, isEqualTo: userId).get();
//     if (usersSnapshot.docs.isNotEmpty) {
//       return usersSnapshot.docs.first["communityid"]; // Return community ID
//     }

//     // Check if user exists in "Admins" collection
//     QuerySnapshot adminsSnapshot = await firestore.collectionGroup('admins').where(FieldPath.documentId, isEqualTo: userId).get();
//     if (adminsSnapshot.docs.isNotEmpty) {
//       return adminsSnapshot.docs.first["communityid"]; // Return community ID
//     }

//     return null; // Return null if user not found in both collections
//   }
//   // Function to upload image into correct folder structure
//   Future<void> uploadImage(File file, String userId) async {
//     // Find the user's community from both Users and Admins collections
//     String? communityName = await getUserCommunity(userId);
//     if (communityName == null) return;

//     // Get or create community folder inside "Communities"
//     String? communityFolderId = await getorCreatefolder(communityName, parentID: await getorCreatefolder(parentFoldername));
//     if (communityFolderId == null) return;

//     // Get or create user folder inside the community folder
//     String? userFolderId = await getorCreatefolder(userId, parentID: communityFolderId);
//     if (userFolderId == null) return;

//     // Upload file inside the user's folder
//     var media = drive.Media(file.openRead(), file.lengthSync());
//     var driveFile = drive.File()
//       ..name = file.path.split('/').last
//       ..parents = [userFolderId];

//     await _drive.files.create(driveFile, uploadMedia: media);
//   }


// }