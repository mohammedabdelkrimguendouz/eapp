import 'package:eapp/pages/login.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'bottomnav.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> registration() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: mailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await DatabaseMethods().addUser(
          uid: userCredential.user!.uid,
          name: nameController.text.trim(),
          email: mailController.text.trim(),
          phone: phoneController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("تم التسجيل بنجاح", style: TextStyle(fontSize: 18.0)),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bottomnav()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = "";
        if (e.code == 'weak-password') {
          errorMessage = "كلمة المرور ضعيفة جدًا";
        } else if (e.code == 'email-already-in-use') {
          errorMessage = "الحساب موجود بالفعل";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage, style: TextStyle(fontSize: 18.0)),
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
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade700, Colors.pink.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
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
                            children: [
                              Text("إنشاء حساب", style: AppWidget.semiBooldTexeFeildStyle()),
                              SizedBox(height: 20.0),
                              _buildTextField(nameController, "الاسم", Icons.person_outline),
                              SizedBox(height: 20.0),
                              _buildTextField(mailController, "البريد الإلكتروني", Icons.email_outlined),
                              SizedBox(height: 20.0),
                              _buildTextField(passwordController, "كلمة المرور", Icons.lock_outline, isPassword: true),
                              SizedBox(height: 20.0),
                              _buildTextField(phoneController, "رقم الهاتف", Icons.phone_outlined),
                              SizedBox(height: 30.0),
                              _buildSignupButton(),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("لديك حساب بالفعل؟", style: TextStyle(fontSize: 16.0)),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                                    },
                                    child: Text(
                                      "تسجيل الدخول",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? 'يرجى إدخال $hint' : null,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppWidget.semiBooldTexeFeildStyle(),
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
      ),
    );
  }

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: registration,
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
              "تسجيل",
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
