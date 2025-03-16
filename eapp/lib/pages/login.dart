import 'package:eapp/pages/forgotpassword.dart';
import 'package:eapp/pages/signup.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController useremailController = TextEditingController();
  TextEditingController userpasswordController = TextEditingController();

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
          // الخلفية العلوية بتدرج ألوان جذاب
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
          // الخلفية السفلية مع تأثير شفاف
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
          // بطاقة تسجيل الدخول
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
                  child: SingleChildScrollView( // ✅ حل مشكلة Overflow
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("تسجيل الدخول", style: AppWidget.semiBooldTexeFeildStyle()),
                          SizedBox(height: 20.0),

                          _buildTextField(useremailController, "البريد الإلكتروني", Icons.email_outlined),
                          SizedBox(height: 20.0),

                          _buildTextField(userpasswordController, "كلمة المرور", Icons.lock_outline, isPassword: true),
                          SizedBox(height: 20.0),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text("نسيت كلمة المرور؟", style: AppWidget.semiBooldTexeFeildStyle()),
                            ),
                          ),
                          SizedBox(height: 20.0),

                          _buildLoginButton(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? 'يرجى إدخال $hint' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppWidget.semiBooldTexeFeildStyle(),
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          loginUser();
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
              "تسجيل الدخول",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
