import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eapp/service/database.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({Key? key}) : super(key: key);

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String selectedStatus = "الكل"; // الحالة المختارة

  // 🔹 قائمة الحالات مع الأيقونات والألوان
  final List<Map<String, dynamic>> orderStatuses = [
    {"status": "الكل", "icon": Icons.list, "color": Colors.blueGrey},
    {"status": "قيد المعالجة", "icon": Icons.timelapse, "color": Colors.orange},
    {"status": "جاهز للتسليم", "icon": Icons.local_shipping, "color": Colors.blue},
    {"status": "تم التسليم", "icon": Icons.check_circle, "color": Colors.green},
    {"status": "تم الإلغاء", "icon": Icons.cancel, "color": Colors.red},
  ];

  void updateOrderStatus(String orderId, String newStatus) {
    DatabaseMethods().updateOrderStatus(orderId, newStatus);
  }

  Stream<List<QueryDocumentSnapshot>> getFilteredOrders() {
    return DatabaseMethods().getOrdersByStatus(selectedStatus == "الكل" ? null : selectedStatus);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'تم التسليم':
        return Colors.green.shade700;
      case 'قيد المعالجة':
        return Colors.amber.shade700;
      case 'جاهز للتسليم':
        return Colors.blue.shade600;
      case 'تم الإلغاء':
        return Colors.grey.shade600;
      default:
        return Colors.blueGrey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          // 🔹 شريط الأيقونات لتصفية الطلبات
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: orderStatuses.map((statusData) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatus = statusData["status"];
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        statusData["icon"],
                        size: 30,
                        color: selectedStatus == statusData["status"]
                            ? statusData["color"]
                            : Colors.grey,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        statusData["status"],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedStatus == statusData["status"]
                              ? statusData["color"]
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔹 قائمة الطلبات حسب الحالة المختارة
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: getFilteredOrders(),
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
                    child: Text("لا توجد طلبات بهذه الحالة", style: TextStyle(fontSize: 18)),
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
                                  orderData['name'] ?? "منتج غير معروف",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

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

                            Row(
                              children: [
                                const Icon(Icons.format_list_numbered, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Text("الكمية: ${orderData['quantity'] ?? 0}", style: const TextStyle(fontSize: 16)),
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

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("تحديث الحالة:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: orderData['status'],
                                  items: ["قيد المعالجة", "جاهز للتسليم", "تم التسليم", "تم الإلغاء"]
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
          ),
        ],
      ),
    );
  }
}
