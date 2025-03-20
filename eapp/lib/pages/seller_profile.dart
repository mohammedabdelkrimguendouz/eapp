import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui' as ui;

class SellerProfile extends StatefulWidget {
  const SellerProfile({super.key});

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  Map<String, dynamic>? adminData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    final data = await DatabaseMethods().getAdminInfo();
    if (mounted) {
      setState(() {
        adminData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl, // ✅ دعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: const Text("معلومات البائع"),
          backgroundColor: Colors.pinkAccent,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminData == null
            ? Center(
          child: FadeIn(
            child: const Text(
              "❌ لا يوجد بيانات للبائع",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        )
            : FadeIn(
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SlideInDown(
                  duration: const Duration(milliseconds: 500),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: adminData!["imageURL"] != null
                        ? NetworkImage(adminData!["imageURL"])
                        : const AssetImage("assets/default_user.png") as ImageProvider,
                  ),
                ),
                const SizedBox(height: 15),
                FadeIn(
                  child: Text(
                    adminData!["name"],
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 10),
                infoRow(Icons.phone, "📱 رقم الهاتف", adminData!["phone"]),
                infoRow(Icons.location_on, "📍 الموقع", adminData!["address"] ?? "غير متوفر"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return SlideInRight(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: ListTile(
            leading: Icon(icon, color: Colors.pinkAccent, size: 26),
            title: Text(
              "$label: $value",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
