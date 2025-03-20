import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:eapp/service/database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OrderPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int price;
  final int quantity;

  const OrderPage({super.key, required this.name, required this.imageUrl, required this.price, required this.quantity});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("تأكيد الطلب", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.pinkAccent,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 5,
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
                        _buildInfoRow(Icons.attach_money, "السعر: ${widget.price} DZ", Colors.green),
                        _buildInfoRow(Icons.shopping_cart, "الكمية: ${widget.quantity}", Colors.blue),
                        _buildInfoRow(Icons.calculate, "الإجمالي: ${widget.price * widget.quantity} DZ", Colors.redAccent, bold: true),
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
                        ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                        : const Text("تأكيد الطلب", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color, {bool bold = false}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: bold ? Colors.redAccent : Colors.black),
      ),
    );
  }
}
