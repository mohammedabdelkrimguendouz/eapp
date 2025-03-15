import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eapp/service/user_preferences.dart';

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
  String selectedPaymentMethod = "الدفع عند الاستلام";
  bool isLoading = false;

  void confirmOrder() async {
    setState(() => isLoading = true);
    try {
      Map<String, String?> userData = await UserPreferences.getUser();
      String? userId = userData['uid'];
      if (  userId == null) throw "المستخدم غير مسجل الدخول";

      DocumentReference orderRef = FirebaseFirestore.instance.collection('orders').doc();

      await orderRef.set({
        'userId': userId,
        'name': widget.name,
        'imageUrl': widget.imageUrl,
        'price': widget.price,
        'quantity': widget.quantity,
        'totalPrice': widget.price * widget.quantity,
        'paymentMethod': selectedPaymentMethod,
        'status': 'قيد المعالجة',
        'timestamp': Timestamp.now(),
      });

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
      appBar: AppBar(title: const Text("تأكيد الطلب")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.imageUrl, height: 200, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("السعر: ${widget.price} DZ", style: const TextStyle(fontSize: 18, color: Colors.grey)),
            Text("الكمية: ${widget.quantity}", style: const TextStyle(fontSize: 18, color: Colors.black)),
            Text("الإجمالي: ${widget.price * widget.quantity} DZ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 20),
            const Text("💳 اختر طريقة الدفع", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            RadioListTile(
              title: const Text("الدفع عند الاستلام"),
              value: "الدفع عند الاستلام",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value.toString()),
            ),
            RadioListTile(
              title: const Text("الدفع الإلكتروني (فيزا / ماستر كارد)"),
              value: "الدفع الإلكتروني",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value.toString()),
            ),
            RadioListTile(
              title: const Text("باي بال"),
              value: "باي بال",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value.toString()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تأكيد الطلب", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
