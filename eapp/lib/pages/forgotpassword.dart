import 'package:eapp/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eapp/widget/widget_support.dart';

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
        const SnackBar(
          content: Text("تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني!", style: TextStyle(fontSize: 16.0)),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يوجد مستخدم مرتبط بهذا البريد الإلكتروني.", style: TextStyle(fontSize: 16.0)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية العلوية بتدرج لوني جذاب
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade700, Colors.pink.shade300],
              ),
            ),
          ),
          // الخلفية السفلية الشفافة
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
          // البطاقة الرئيسية
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 10.0,
                shadowColor: Colors.black45,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("استعادة كلمة المرور", style: AppWidget.semiBooldTexeFeildStyle()),
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
                                  colors: [Colors.pink.shade600, Colors.pink.shade400],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
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
                        ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
