import 'package:eapp/admin/add_produit.dart';
import 'package:eapp/admin/admin_login.dart';
import 'package:eapp/admin/home_admin.dart';
import 'package:eapp/pages/bottomnav.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/login.dart';
import 'package:eapp/pages/signup.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:eapp/pages/cart.dart';


Future<String> getInitialRoute() async {
  Map<String, String?> userData = await UserPreferences.getUser();

  if (userData['uid'] != null) {
    if (userData['role'] == "Admin") {
      return "/adminHome";
    } else {
      return "/clientPage";
    }
  }
  return "/login";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  String initialRoute = await getInitialRoute();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        "/login": (context) => Login(),
        "/adminHome": (context) => HomeAdmin(),
        "/clientPage": (context) => Bottomnav(),
      },
    );
  }
}

