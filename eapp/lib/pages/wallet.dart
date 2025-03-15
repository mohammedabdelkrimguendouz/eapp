import 'package:eapp/widget/widget_support.dart';
import 'package:flutter/material.dart';
class Wallet extends StatefulWidget {
  const Wallet ({super.key});

  @override
  State<Wallet> createState() => _WallwtState();
}

class _WallwtState extends State<Wallet> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(

        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Material(
            elevation: 2.0,
            child: Container(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Center(
              child: Text("Wallet",style: AppWidget.semiBooldTexeFeildStyle(),),),),),
          SizedBox(height: 30.0,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Image.asset("images/photo_5897867250445174432_x.jpg",height: 60,width: 60,fit: BoxFit.cover,),
                SizedBox(width: 40.0,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text("Your Wallit",style: AppWidget.boldTextFeildStyle(),),
                    SizedBox(height: 5.0,),
                    Text("100"+"\dz",style: AppWidget.boldTextFeildStyle(),),
                ],
                ),

              ],
            ),
          ),
          SizedBox(height: 20.0,),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text("Add money",style: AppWidget.semiBooldTexeFeildStyle(),),
          ),
            SizedBox(height: 16.0,),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),borderRadius: BorderRadius.circular(5),
                  ),
                 child:  Text("100"+"\dz",style: AppWidget.boldTextFeildStyle(),),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),borderRadius: BorderRadius.circular(5),
                  ),
                  child:  Text("500"+"\dz",style: AppWidget.boldTextFeildStyle(),),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),borderRadius: BorderRadius.circular(5),
                  ),
                  child:  Text("1000"+"\dz",style: AppWidget.boldTextFeildStyle(),),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),borderRadius: BorderRadius.circular(5),
                  ),
                  child:  Text("2000"+"\dz",style: AppWidget.boldTextFeildStyle(),),
                ),
              ],
            ),
            SizedBox(height: 50.0,),
            Container(
              margin: EdgeInsets.symmetric(horizontal:  20.0),
              padding: EdgeInsets.symmetric(vertical: 12.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.pinkAccent,borderRadius: BorderRadius.circular(10)
              ),
           child: Center(child: Text("Add Money",style: TextStyle(color: Colors.white,fontSize: 16.0,fontFamily: 'Poppins',fontWeight:FontWeight.bold),),), ),

        ],),

      ),
    );
  }
}
