import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  // ✅ تحديث حالة الطلب في Firestore
  void updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛒 طلباتي")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا توجد طلبات متاحة 🚀", style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];

              // ✅ جلب بيانات الطلب
              String orderId = order.id;
              String name = order.get('name') ?? 'منتج غير معروف';
              String imageUrl = order.get('imageUrl') ?? 'https://via.placeholder.com/150';
              int price = order.get('price') ?? 0;
              int quantity = order.get('quantity') ?? 1;
              String status = order.get('status') ?? 'قيد المعالجة';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("السعر: $price DZ × $quantity"),
                      Text("الحالة: $status", style: TextStyle(color: status == "تم التوصيل" ? Colors.green : Colors.orange)),
                    ],
                  ),
                  trailing: status == "تم التوصيل"
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : PopupMenuButton<String>(
                    onSelected: (newStatus) => updateOrderStatus(orderId, newStatus),
                    itemBuilder: (BuildContext context) {
                      return [
                        if (status == "قيد المعالجة")
                          const PopupMenuItem(value: "قيد التوصيل", child: Text("🔄 قيد التوصيل")),
                        if (status == "قيد التوصيل")
                          const PopupMenuItem(value: "تم التوصيل", child: Text("✅ تم التوصيل")),
                      ];
                    },
                    child: const Icon(Icons.more_vert),
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
