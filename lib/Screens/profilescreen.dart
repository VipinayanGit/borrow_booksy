import 'package:borrow_booksy/Screens/signupscreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, String>> books = []; // List to store books (initially empty)

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _ScaffoldKey,
        appBar: AppBar(
          title: Text("profilescreen"),
          actions: [
            Icon(Icons.person_pin),
            SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {
                _ScaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Container(
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the drawer
                        },
                        icon: Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text("Contact"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("Support"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("help"),
                  onTap: () {},
                ),
                ListTile(
                  title: Text("Log out"),
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => signupscreen()));
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(radius: 50),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Apartment name",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text("Name"),
                            Text("flat no"),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 5),
                                Container(
                                    height: 30,
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: () => _showdialoguebox(context),
                                      child: Text(
                                        "Manage Books",
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.book),
                    text: "your Rack",
                  ),
                  Tab(
                    icon: Icon(Icons.book),
                    text: "History",
                  ),
                ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // "Your Rack" tab: Grid of books
                      books.isEmpty
                          ? Center(child: Text("your rack is empty"))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 3 / 4,
                                crossAxisCount: 2, // Number of columns
                                crossAxisSpacing: 10, // Spacing between columns
                                mainAxisSpacing: 10, // Spacing between rows
                              ),
                              itemCount: books.length, // Example: number of books
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showbookdetails(context, book, index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.white)),
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          //padding: EdgeInsets.all(10),
                                          height: 100,
                                          width: 90,
                                          color: Colors.red,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          book["name"]!,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(book["author"]!)
                                      ],
                                    )),
                                  ),
                                );
                              },
                            ),
                      // "History" tab: Single container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          //color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Container(
                          //color: Colors.blue,
                          height: 250,
                          width: 250,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 50,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 130,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 130,
                                left: 70,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.greenAccent.withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Text("Book donated"),
                                      Text("30"),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Manage book dialogue box
  void _showdialoguebox(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Manage Books"),
            content: Text("choose any option"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addbookdialogue(context);
                },
                child: Text("add"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("remove"),
              ),
            ],
          );
        });
  }

  //Add book dialogue box
  void _addbookdialogue(BuildContext context) {
    final _bookcontroller = TextEditingController();
    final _authorcontroller = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add book"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Text("Upload book image"),
                      icon: Icon(Icons.upload_file),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _bookcontroller,
                    decoration: InputDecoration(
                      hintText: "Book name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _authorcontroller,
                    decoration: InputDecoration(
                      hintText: "Author name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      String Bookname = _bookcontroller.text;
                      String authorname = _authorcontroller.text;
                      if (Bookname.isNotEmpty && authorname.isNotEmpty) {
                        setState(() {
                          books.add({
                            "name": Bookname,
                            "author": authorname,
                          });
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("please fill all the fields"),
                        ));
                      }
                    },
                    child: Text("add"),
                  ),
                ],
              ),
            ],
          );
        });
  }

//book detail dialogue box
  void _showbookdetails(BuildContext context, Map<String, String> book, int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(book["name"]!),
            content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  //padding: EdgeInsets.all(10),
                  height: 50,
                  width: 50,
                  color: Colors.red,
                ),
                SizedBox( width: 10),
                Column(
                  children: [
                    Text(book["name"]!),
                    Text(book["author"]!)
                  ],
                )
              ],
            ),
          );
        });
  }
}
