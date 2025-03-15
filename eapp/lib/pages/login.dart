import 'package:eapp/pages/forgotpassword.dart';
import 'package:eapp/pages/signup.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eapp/service/database.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // هاد المفتاح نتأكدوا من صحة البيانات لي دخل المستخدم
  final _formKey = GlobalKey<FormState>();

  // هنا عندنا المتغيرات لي غادي نخزنو فيها البريد الإلكتروني و المودباس لي دخل المستخدم
  TextEditingController useremailController = TextEditingController();
  TextEditingController userpasswordController = TextEditingController();

  // دالة تسجيل الدخول باستعمال Firebase Authentication
  void loginUser() async {
    DatabaseMethods db = DatabaseMethods();
    String? role = await db.userLogin(
      email: useremailController.text,
      password: userpasswordController.text,
    );

    if (role != null) {
      if (role == "Admin") {
        Navigator.pushReplacementNamed(context, "/adminHome");
      } else {
        Navigator.pushReplacementNamed(context, "/clientPage");
      }
      } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول، تحقق من بياناتك")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // هنا درنا خلفية فيها تدرج ألوان باش يعطي شكل زوين
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [Colors.pinkAccent, Colors.white],
              ),
            ),
          ),
          // الخلفية الرئيسية لصفحة تسجيل الدخول
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xFFF49CBC),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
          ),
          // الحاوية لي فيها النموذج ديال تسجيل الدخول
          Container(
            margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                SizedBox(height: 50.0),
                Material(
                  borderRadius: BorderRadius.circular(20),
                  elevation: 5.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 30.0),
                          Text("Login", style: AppWidget.semiBooldTexeFeildStyle()),

                          // هنا كاين حقل إدخال البريد الإلكتروني
                          TextFormField(
                            controller: useremailController,
                            validator: (value) => value!.isEmpty ? 'enter email' : null,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: AppWidget.semiBooldTexeFeildStyle(),
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          SizedBox(height: 30.0),

                          // هنا كاين حقل إدخال المودباس
                          TextFormField(
                            controller: userpasswordController,
                            validator: (value) => value!.isEmpty ? 'Enter password' : null,
                            obscureText: true,
                             decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: AppWidget.semiBooldTexeFeildStyle(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          SizedBox(height: 40.0),

                          // رابط استرجاع المودباس
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text("Forgot password", style: AppWidget.semiBooldTexeFeildStyle()),
                            ),
                          ),
                          SizedBox(height: 40.0),

                          // زر تسجيل الدخول
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                            child: Material(
                              elevation: 6.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text("LOGIN",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
