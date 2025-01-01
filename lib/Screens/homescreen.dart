import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  List<Map<String, String>> books = [];
  String selectedgenre = "All";

  final List<String> genre = [
    "All",
    "Fiction",
    "Non-Fiction",
    "Fantasy",
    "Mystery",
    "Science Fiction",
    "Biography",
    "History"
  ];

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
   final filteredBooks = selectedGenre == "All"
        ? books
        : books.where((book) => book["genre"] == selectedGenre).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Homescreen"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  width: 170,
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(filled: true, border: OutlineInputBorder(borderSide: BorderSide.none)),
                  ),
                ),
                Container(
                  
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
