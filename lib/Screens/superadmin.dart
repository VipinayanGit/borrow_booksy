import 'package:borrow_booksy/Screens/signupscreen.dart';
import 'package:flutter/material.dart';
class Superadmin extends StatefulWidget {
  const Superadmin({super.key});

  @override
  State<Superadmin> createState() => _SuperadminState();
}

class _SuperadminState extends State<Superadmin> {
  final _Formkey=GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      actions: [IconButton(
        onPressed: (){
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>signupscreen()));}, icon:Icon(Icons.logout_outlined))],
      ),
      body:Center(
        child:Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
                   _manageusers(context);
              }, 
              child: Text("manage users")),),
              SizedBox(height: 50),
            Container(
              width: 200,
              height: 70,
              child:ElevatedButton(onPressed: (){
                _manageadmins(context);
              }, 
              child: Text("manage admins")), )
           

          ],
        ),
      )
    );
  }
  void _manageusers(BuildContext context){
     showDialog(context: context,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
          ),
          child: IntrinsicHeight(
            child: Padding(padding:EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
            //  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text("Manage users",
                  style: TextStyle(fontSize: 18),
                  
                  ),
                
                  ),
                  SizedBox(height:15),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _addusers(context);

                  
                },
                 child: Text("add users"),),
                 SizedBox(height: 5),
                 ElevatedButton(onPressed: (){},
                  child: Text("delete users")),
              ],
            ),),
          ),
        );
      });

  }
    void _manageadmins(BuildContext context){
     showDialog(context: context,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)
          ),
          child: IntrinsicHeight(
            child: Padding(padding:EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
            //  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text("Manage admins",
                  style: TextStyle(fontSize: 18),
                  
                  ),
                
                  ),
                  SizedBox(height:15),
                ElevatedButton(onPressed: (){},
                 child: Text("add admins"),),
                 SizedBox(height: 5),
                 ElevatedButton(onPressed: (){},
                  child: Text("delete admins")),
              ],
            ),),
          ),
        );
      });

  }
  void _addusers(BuildContext context){
    showDialog(context: context,
     builder:(BuildContext context){
      return Dialog(
        child: IntrinsicHeight(
          child: Padding(padding: EdgeInsets.all(8),
          child: Column(children: [
            Container(
               child: Text("add user"),
               
            ),
            Form(
              key:_Formkey ,
              child:Container(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(hintText:"enter the name"),
                    validator: (value){
                     if(value.toString().isEmpty){
                      return "the name should not be empty";
                     }
                     else{
                      return null;
                     }
                    },
                  ),
                    TextFormField(
                    decoration: InputDecoration(hintText:"enter the username"),
                    validator: (value){
                     if(value.toString().isEmpty){
                      return "the username should not be empty";
                     }
                     else{
                      return null;
                     }
                    },
                  ),
                    TextFormField(
                    decoration: InputDecoration(hintText:"enter the password"),
                    validator: (value){
                     if(value.toString().isEmpty){
                      return "the password should not be empty";
                     }
                     else{
                      return null;
                     }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText:"confirm password"),
                    validator: (value){
                     if(value.toString().isEmpty){
                      return "Rewrite the password";
                     }
                     else{
                      return null;
                     }
                    },
                  ),
                  ElevatedButton(onPressed: (){
                    if(!_Formkey.currentState!.validate()){
                      _Formkey.currentState!.validate();
                    }
                  },
                   child: Text("submit"))

                ],
              ),
            ), )
          ],),),
        ),
      );
     });
  }
}