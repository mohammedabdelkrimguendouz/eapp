import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentPage({super.key, required this.orderId, required this.totalAmount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = "الدفع عند الاستلام";
  bool isProcessing = false;

  // متحكمات إدخال بيانات الدفع
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController paypalEmailController = TextEditingController();

  // ✅ التحقق من صحة البيانات وإتاحة زر الدفع فقط عند إدخال البيانات الصحيحة
  bool get isPaymentValid {
    if (selectedPaymentMethod == "البطاقة البنكية") {
      return cardNumberController.text.isNotEmpty &&
          expiryDateController.text.isNotEmpty &&
          cvvController.text.isNotEmpty;
    } else if (selectedPaymentMethod == "باي بال") {
      return paypalEmailController.text.isNotEmpty;
    }
    return true; // ✅ الدفع عند الاستلام لا يحتاج تحقق
  }

  Future<void> processPayment() async {
    if (!isPaymentValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ يرجى إدخال جميع بيانات الدفع المطلوبة!")),
      );
      return; // 🚫 منع تأكيد الدفع إذا كانت البيانات غير مكتملة
    }

    setState(() => isProcessing = true);
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "❌ المستخدم غير مسجل الدخول";

      // بيانات الدفع
      Map<String, dynamic> paymentData = {
        'paymentMethod': selectedPaymentMethod,
        'paymentStatus': 'تم الدفع',
      };

      if (selectedPaymentMethod == "البطاقة البنكية") {
        paymentData.addAll({
          'cardNumber': cardNumberController.text,
          'expiryDate': expiryDateController.text,
          'cvv': cvvController.text,
        });
      } else if (selectedPaymentMethod == "باي بال") {
        paymentData.addAll({'paypalEmail': paypalEmailController.text});
      }

      // تحديث الطلب في Firestore
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update(paymentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم الدفع بنجاح!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ فشل الدفع: $e")),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("💳 الدفع"), backgroundColor: Colors.pinkAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("اختر طريقة الدفع:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            RadioListTile(
              title: const Text("💵 الدفع عند الاستلام"),
              value: "الدفع عند الاستلام",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() => selectedPaymentMethod = value.toString()),
            ),
            RadioListTile(
              title: const Text("💳 بطاقة بنكية (Visa / MasterCard)"),
              value: "البطاقة البنكية",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() {
                selectedPaymentMethod = value.toString();
                setState(() {}); // تحديث الواجهة بعد اختيار طريقة الدفع
              }),
            ),
            RadioListTile(
              title: const Text("💰 باي بال (PayPal)"),
              value: "باي بال",
              groupValue: selectedPaymentMethod,
              onChanged: (value) => setState(() {
                selectedPaymentMethod = value.toString();
                setState(() {}); // تحديث الواجهة بعد اختيار طريقة الدفع
              }),
            ),

            const SizedBox(height: 20),

            // 🔹 عرض إدخال بيانات البطاقة عند اختيار "البطاقة البنكية"
            if (selectedPaymentMethod == "البطاقة البنكية") ...[
              _buildTextField("💳 رقم البطاقة", cardNumberController, TextInputType.number),
              _buildTextField("📅 تاريخ الانتهاء", expiryDateController, TextInputType.datetime),
              _buildTextField("🔒 CVV", cvvController, TextInputType.number, isPassword: true),
            ],

            // 🔹 عرض إدخال بريد PayPal عند اختيار "باي بال"
            if (selectedPaymentMethod == "باي بال") ...[
              _buildTextField("📧 بريد PayPal", paypalEmailController, TextInputType.emailAddress),
            ],

            Text("💰 المبلغ الإجمالي: ${widget.totalAmount} DZ",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing || !isPaymentValid ? null : processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaymentValid ? Colors.pink : Colors.grey, // تعطيل الزر إذا لم يُدخل البيانات
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إتمام الدفع", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 دالة لإنشاء حقول الإدخال
  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (_) => setState(() {}), // تحديث الزر عند إدخال البيانات
      ),
    );
  }
}
