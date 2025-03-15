import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:eapp/service/database.dart';
import 'package:eapp/service/cloudinary_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = "";
  String userEmail = "";
  String userImage = "https://via.placeholder.com/150";
  String userPhone = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  bool isSaving = false;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final CloudinaryService cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() => isLoading = true);
    Map<String, String?> userData = await UserPreferences.getUser();
    setState(() {
      userName = userData['name'] ?? "مستخدم مجهول";
      userEmail = userData['email'] ?? "غير معروف";
      userImage = userData['imageURL'] ?? "https://via.placeholder.com/150";
      userPhone = userData['phone'] ?? "";
      nameController.text = userName;
      phoneController.text = userPhone;
    });
    setState(() => isLoading = false);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => userImage = image.path);
    }
  }

  Future<void> updateUserProfile() async {
    setState(() => isSaving = true);
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "المستخدم غير مسجل الدخول";

      String? imageUrl;
      if (File(userImage).existsSync()) {
        imageUrl = await cloudinaryService.uploadImage(File(userImage));
      }

      await _databaseMethods.updateUser(
        uid: userId,
        name: nameController.text,
        phone: phoneController.text,
        imageURL: imageUrl ?? null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم تحديث الملف الشخصي بنجاح!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل تحديث البيانات: $e")),
      );
    }
    setState(() => isSaving = false);
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    await UserPreferences.clearUser();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ملفي الشخصي"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
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
                  onPressed: pickImage,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(userEmail, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "👤 الاسم",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "📱 الهاتف",
                border: OutlineInputBorder(),
              ),
            ),
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



