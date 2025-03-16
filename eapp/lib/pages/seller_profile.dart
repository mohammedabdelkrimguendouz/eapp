import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("معلومات البائع"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminData == null
          ? const Center(
        child: Text(
          "❌ لا يوجد بيانات للبائع",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: adminData!["imageURL"] != null
                  ? NetworkImage(adminData!["imageURL"])
                  : const AssetImage("assets/default_user.png") as ImageProvider,
            ),
            const SizedBox(height: 15),
            Text(
              adminData!["name"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            infoRow(Icons.phone, "رقم الهاتف", adminData!["phone"]),
            infoRow(Icons.location_on, "الموقع", adminData!["address"] ?? "غير متوفر"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label: $value",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
