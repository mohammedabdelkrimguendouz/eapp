import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminStatisticsPage extends StatefulWidget {
  const AdminStatisticsPage({Key? key}) : super(key: key);

  @override
  _AdminStatisticsPageState createState() => _AdminStatisticsPageState();
}

class _AdminStatisticsPageState extends State<AdminStatisticsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int totalOrders = 0;
  int deliveredOrders = 0;
  int processingOrders = 0;
  int readyOrders = 0;
  int cancelledOrders = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  void fetchStatistics() async {
    QuerySnapshot ordersSnapshot = await _firestore.collection('orders').get();

    int delivered = 0, processing = 0, ready = 0, cancelled = 0;
    double revenue = 0.0;

    for (var order in ordersSnapshot.docs) {
      var data = order.data() as Map<String, dynamic>;
      String status = data['status'] ?? '';

      switch (status) {
        case 'تم التسليم':
        case 'تم الإيفاء':
          delivered++;
          revenue += (data['price'] ?? 0) * (data['quantity'] ?? 1);
          break;
        case 'قيد المعالجة':
          processing++;
          break;
        case 'جاهز للاستلام':
          ready++;
          break;
        case 'تم الإلغاء':
          cancelled++;
          break;
      }
    }

    setState(() {
      totalOrders = ordersSnapshot.size;
      deliveredOrders = delivered;
      processingOrders = processing;
      readyOrders = ready;
      cancelledOrders = cancelled;
      totalRevenue = revenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildRevenueCard().animate().fade(duration: 500.ms).slideY(),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    buildStatisticTile("إجمالي الطلبات", totalOrders, Icons.list, Colors.blue),
                    buildStatisticTile("تم التسليم", deliveredOrders, Icons.check_circle, Colors.green),
                    buildStatisticTile("قيد المعالجة", processingOrders, Icons.hourglass_empty, Colors.amber),
                    buildStatisticTile("جاهز للاستلام", readyOrders, Icons.storefront, Colors.blueAccent),
                    buildStatisticTile("تم الإلغاء", cancelledOrders, Icons.cancel, Colors.red),
                  ]
                      .animate()
                      .fade(duration: 500.ms, delay: 300.ms)
                      .slideX(begin: -0.3),
                ),
              ),
              const SizedBox(height: 10),
              buildPieChart().animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRevenueCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "إجمالي الأرباح",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const SizedBox(height: 4),
          Text(
            "${totalRevenue.toStringAsFixed(2)} د.ج",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
        ],
      ),
    );
  }

  Widget buildStatisticTile(String title, int value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        trailing: Text(
          value.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: deliveredOrders.toDouble(), color: Colors.green, title: 'تم التسليم', radius: 40),
            PieChartSectionData(value: processingOrders.toDouble(), color: Colors.amber, title: 'قيد المعالجة', radius: 40),
            PieChartSectionData(value: readyOrders.toDouble(), color: Colors.blueAccent, title: 'جاهز', radius: 40),
            PieChartSectionData(value: cancelledOrders.toDouble(), color: Colors.red, title: 'تم الإلغاء', radius: 40),
          ],
          sectionsSpace: 4,
          centerSpaceRadius: 35,
        ),
      ),
    );
  }
}
