import 'package:eapp/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mailcontroler= new TextEditingController();
  String email="";
  final _formkey=GlobalKey<FormState>();
  restPassword()async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password Reset Email has been sent",style: TextStyle(fontSize: 18.0),),
        ),
      );
    }on FirebaseAuthException catch(e){
      if(e.code=="user-not-found"){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text( "No user found for email.",style: TextStyle(fontSize: 18.0),),));
      }

    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Container(child: Column(children: [
        SizedBox(height: 70.0,),
        Container(
          alignment: Alignment.center,
          child: Text("password Recovery",style: TextStyle(color: Colors.white,fontSize: 30.0,fontWeight: FontWeight.bold),),

        ),
        SizedBox(height: 10.0,),
        Text("Enter your Email",style: TextStyle(
          color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold
        ),),
        Expanded(
          child: Form(
            key: _formkey,
              child: Padding(padding: EdgeInsets.only(left: 10.0),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white,width: 2.0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextFormField(
                controller: mailcontroler,
                validator: (value){
                  if(value==null||value.isEmpty) {
                    return 'Please enter Eamil';
                  }
                  return null;
                  },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle:TextStyle(fontSize: 18.0,color: Colors.white),
                  prefixIcon: Icon(Icons.person,color: Colors.white60,size: 30.0,
                  ),
                    border: InputBorder.none),

                  ),
                ),
               SizedBox(height: 40.0,),

                  GestureDetector(
                    onTap: (){
                      if(_formkey.currentState!.validate()){
                        setState(() {
                          email=mailcontroler.text;
                        });
                        restPassword();
                      }
                    },
                    child: Container(
                      width: 140.0,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text("Send Email",style: TextStyle(color: Colors.black87,fontSize: 18.0,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 50.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an ccount?",style: TextStyle(fontSize: 18.0,color: Colors.white),),
                SizedBox(width: 20.0,),
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
                  },

               child:  Text("Create ",style: TextStyle(
                  color: Color.fromARGB(255, 184,166 ,6 ),
                  fontSize: 20.0,fontWeight: FontWeight.w500
                ),),
                ),

              ],

            )

                ],
              ),
            )

            ),
        ),
        ],
      ),
      ),
      );

  }
}
