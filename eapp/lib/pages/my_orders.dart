import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eapp/service/database.dart';
import 'package:flutter/material.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:animate_do/animate_do.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  String? usrId;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    Map<String, String?> userData = await UserPreferences.getUser();
    if (!mounted) return;
    setState(() {
      usrId = userData["uid"];
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'تم التسليم':
        return Colors.green.shade700;
      case 'قيد المعالجة':
        return Colors.amber.shade700;
      case 'جاهز للاستلام':
        return Colors.blue.shade600;
      case 'تم الإلغاء':
        return Colors.grey.shade600;
      default:
        return Colors.blueGrey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink,
        ),
        body: usrId == null
            ? const Center(
          child: Text(
            "يجب تسجيل الدخول لعرض الطلبات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: usrId!.isEmpty ? null : DatabaseMethods().getUserOrders(usrId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "حدث خطأ أثناء تحميل الطلبات ❌",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("لا توجد طلبات حتى الآن", style: TextStyle(fontSize: 18)),
              );
            }

            var orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                var order = orders[index];
                var orderData = order.data() as Map<String, dynamic>;

                return FadeInUp(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (orderData['imageUrl'] != null && orderData['imageUrl'].isNotEmpty)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  orderData['imageUrl'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(Icons.shopping_bag, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                orderData['name'] ?? "طلب غير معروف",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.format_list_numbered, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text("الكمية: ${orderData['quantity'] ?? 0}", style: const TextStyle(fontSize: 16)),
                            ],
                          ),

                          const Divider(thickness: 1, height: 20),

                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Colors.green),
                              const SizedBox(width: 8),
                              Text("${orderData['totalPrice']} DZ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                orderData['timestamp'] != null
                                    ? DateFormat('yyyy-MM-dd HH:mm').format((orderData['timestamp'] as Timestamp).toDate())
                                    : "غير متوفر",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                orderData['status'] ?? "غير محدد",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(orderData['status']),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
