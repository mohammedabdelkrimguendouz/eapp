import 'package:eapp/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController mailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني!",
              style: TextStyle(fontSize: 16.0)),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("لا يوجد مستخدم مرتبط بهذا البريد الإلكتروني.",
                style: TextStyle(fontSize: 16.0)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.pink.shade700, Colors.pink.shade300],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  elevation: 10.0,
                  shadowColor: Colors.black45,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("استعادة كلمة المرور",
                              style: AppWidget.semiBooldTexeFeildStyle())
                              .animate()
                              .fade(duration: 500.ms)
                              .slideY(begin: -0.5, end: 0),
                          SizedBox(height: 20.0),
                          Text(
                            "أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور",
                            style: TextStyle(fontSize: 16.0, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: mailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال البريد الإلكتروني';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "البريد الإلكتروني",
                              hintStyle: AppWidget.semiBooldTexeFeildStyle(),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.pinkAccent),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                resetPassword();
                              }
                            },
                            child: Material(
                              elevation: 6.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15.0),
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.pink.shade700, Colors.pink.shade300],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "إرسال البريد الإلكتروني",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().scaleXY(duration: 300.ms, begin: 0.9, end: 1.0),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("ليس لديك حساب؟", style: TextStyle(fontSize: 16.0)),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                                },
                                child: Text(
                                  "إنشاء حساب",
                                  style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fade(duration: 600.ms).slideY(begin: 0.5, end: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}