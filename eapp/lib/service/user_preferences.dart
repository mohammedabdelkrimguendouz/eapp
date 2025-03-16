import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String? imageURL,
    required String role,
    required String? address
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('imageURL', imageURL??"");
    await prefs.setString('role', role);
    await prefs.setString('address', address??"");
  }

  static Future<Map<String, String?>> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString('uid'),
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'role': prefs.getString('role'),
      'phone': prefs.getString('phone'),
      'imageURL': prefs.getString('imageURL'),
      'address': prefs.getString('address'),
    };
  }

  static Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
