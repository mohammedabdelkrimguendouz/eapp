import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:eapp/service/database.dart';
class OrderPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final int quantity;

  const OrderPage({super.key, required this.name, required this.imageUrl, required this.price, required this.quantity});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool isLoading = false;

  void confirmOrder() async {
    setState(() => isLoading = true);
    try {
      Map<String, String?> userData = await UserPreferences.getUser();
      String? userId = userData['uid'];
      if (userId == null) throw "المستخدم غير مسجل الدخول";

      DatabaseMethods databaseMethods = DatabaseMethods();
      await databaseMethods.addOrder(
        userId: userId,
        name: widget.name,
        imageUrl: widget.imageUrl,
        price: widget.price,
        quantity: widget.quantity,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم تأكيد الطلب بنجاح!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل تأكيد الطلب: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تأكيد الطلب"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(widget.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 15),
                    Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1.2),
                    ListTile(
                      leading: const Icon(Icons.attach_money, color: Colors.green),
                      title: Text("السعر: ${widget.price} DZ", style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text("الكمية: ${widget.quantity}", style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calculate, color: Colors.red),
                      title: Text(
                        "الإجمالي: ${widget.price * widget.quantity} DZ",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد الطلب", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
