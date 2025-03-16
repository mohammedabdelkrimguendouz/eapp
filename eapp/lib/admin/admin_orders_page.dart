import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eapp/service/database.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updateOrderStatus(String orderId, String newStatus) {
    DatabaseMethods().updateOrderStatus(orderId, newStatus);
  }

  Stream<List<QueryDocumentSnapshot>> getAllOrdersByTimeAndStatus() {
    return DatabaseMethods().getAllOrdersByTimeAndStatus();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'تم التسليم':
        return Colors.green;
      case 'قيد المعالجة':
        return Colors.red;
      case 'جاهز للتسليم':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: getAllOrdersByTimeAndStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("حدث خطأ أثناء تحميل الطلبات ❌", style: TextStyle(fontSize: 18, color: Colors.red)),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 صورة المنتج
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

                      // 🔹 اسم المنتج
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            orderData['name'] ?? "منتج غير معروف",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 🔹 السعر
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "${orderData['price']} DZ",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 🔹 الكمية
                      Row(
                        children: [
                          const Icon(Icons.format_list_numbered, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            "الكمية: ${orderData['quantity'] ?? 0}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // 🔹 بيانات المستخدم (يتم جلبها من Firestore)
                      FutureBuilder<Map<String, dynamic>?>(
                        future: DatabaseMethods().getUserInfo(orderData['userId']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!userSnapshot.hasData) {
                            return const Text("مستخدم غير معروف", style: TextStyle(fontSize: 16));
                          }

                          var userData = userSnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Text(userData['name'] ?? "مستخدم غير معروف",
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(userData['phone'] ?? "غير متوفر",
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // 🔹 الحالة
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

                      const SizedBox(height: 12),

                      // 🔹 تحديث حالة الطلب
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("تحديث الحالة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: orderData['status'],
                            items: ["قيد المعالجة", "جاهز للتسليم", "تم التسليم"]
                                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                                .toList(),
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                updateOrderStatus(order.id, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
