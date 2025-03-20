import 'package:eapp/pages/forgotpassword.dart';
import 'package:eapp/pages/signup.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      Navigator.pushReplacementNamed(
        context,
        role == "Admin" ? "/adminHome" : "/clientPage",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل تسجيل الدخول، تحقق من بياناتك")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم الواجهة من اليمين لليسار
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackground(),
            _buildLoginCard().animate().fade(duration: 500.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade700, Colors.pink.shade300],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Center(
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
            child: SingleChildScrollView(
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
                    _buildForgotPassword(),
                    SizedBox(height: 20.0),
                    _buildLoginButton(),
                    SizedBox(height: 20.0),
                    _buildSignupOption(),
                  ],
                ),
              ),
            ),
          ).animate().fade(duration: 700.ms),
        ),
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

  Widget _buildForgotPassword() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ForgotPassword(),
            transitionsBuilder: (_, anim, __, child) {
              return SlideTransition(
                position: Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim),
                child: child,
              );
            },
          ),
        );
      },
      child: Align(
        alignment: Alignment.topRight,
        child: Text("نسيت كلمة المرور؟", style: AppWidget.semiBooldTexeFeildStyle()),
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
              style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ).animate().scaleXY(duration: 300.ms, begin: 0.9, end: 1.0),
    );
  }

  Widget _buildSignupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("ليس لديك حساب؟", style: TextStyle(fontSize: 16.0)),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
          },
          child: Text("إنشاء حساب", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 16.0)),
        ),
      ],
    );
  }
}
