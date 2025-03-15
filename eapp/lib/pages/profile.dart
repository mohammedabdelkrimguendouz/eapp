import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = "";
  String userEmail = "";
  String userImage = "https://via.placeholder.com/150";
  String accountType = "بائعة";
  String aboutMe = "";
  String contactInfo = "";
  int productCount = 0;
  int orderCount = 0;
  double rating = 4.5;
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "❌ المستخدم غير مسجل الدخول";

      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      var userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'name': "مستخدم جديد",
          'email': FirebaseAuth.instance.currentUser?.email ?? "غير معروف",
          'image': userImage,
          'accountType': "بائعة",
          'aboutMe': "",
          'contactInfo': "",
          'productCount': 0,
          'orderCount': 0,
          'rating': 5.0,
        });
        userDoc = await userRef.get();
      }

      setState(() {
        userName = userDoc['name'] ?? "مستخدم مجهول";
        userEmail = userDoc['email'] ?? "غير معروف";
        userImage = userDoc['image'] ?? "https://via.placeholder.com/150";
        accountType = userDoc['accountType'] ?? "بائعة";
        aboutMe = userDoc['aboutMe'] ?? "";
        contactInfo = userDoc['contactInfo'] ?? "";
        productCount = userDoc['productCount'] ?? 0;
        orderCount = userDoc['orderCount'] ?? 0;
        rating = userDoc['rating'] ?? 4.5;
        nameController.text = userName;
        aboutMeController.text = aboutMe;
        contactController.text = contactInfo;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ فشل تحديث البيانات: $e")));
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;
    setState(() {
      userImage = image.path;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', image.path);
  }

  Future<void> updateUserProfile() async {
    setState(() {
      isSaving = true;
    });
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "المستخدم غير مسجل الدخول";
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'name': nameController.text,
        'aboutMe': aboutMeController.text,
        'contactInfo': contactController.text,
        'accountType': accountType,
      });
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ تم تحديث الملف الشخصي بنجاح!")));
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ فشل تحديث البيانات: $e")));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text("$productCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("المنتجات"),
          ],
        ),
        Column(
          children: [
            Text("$orderCount", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("الطلبات"),
          ],
        ),
        Column(
          children: [
            Text("$rating ⭐", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("التقييم"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ملفي الشخصي"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: userImage.isNotEmpty && File(userImage).existsSync()
                      ? FileImage(File(userImage))
                      : NetworkImage(userImage) as ImageProvider,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.pink),
                  onPressed: () async {
                    final ImageSource? source = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("اختر صورة"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, ImageSource.camera),
                            child: const Text("📷 التقاط صورة"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, ImageSource.gallery),
                            child: const Text("🖼️ اختيار من المعرض"),
                          ),
                        ],
                      ),
                    );
                    if (source != null) pickImage(source);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField("👤 الاسم", nameController),
            _buildTextField("📝 نبذة عني", aboutMeController),
            _buildTextField("📱 وسائل التواصل", contactController),
            const SizedBox(height: 10),
            _buildStats(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : updateUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
