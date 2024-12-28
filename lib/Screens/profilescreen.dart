import 'package:flutter/material.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  void ontapped() {
    setState(() {
      return print("hello");
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("profilescreen"),
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
                                      onPressed: (){}, 
                                      child:Text("Add or remove books",
                                       style: TextStyle(
                                      fontSize: 10
                                    ),),
                                     ),
                                   ),
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
                      GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 10, // Spacing between columns
                          mainAxisSpacing: 10, // Spacing between rows
                        ),
                        itemCount: 8, // Example: number of books
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: ontapped,
                            child: Container(
                              
                              decoration: BoxDecoration(
                                
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Colors.white
                                )
                              ),
                              
                              child: Center(
                                child: Text(
                                  'Book ${index + 1}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // "History" tab: Single container
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "History Content",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
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
}
