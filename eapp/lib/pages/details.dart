import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eapp/pages/order.dart';

class Details extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String detail;
  final int price;

  const Details({super.key, required this.name, required this.imageUrl, required this.detail, required this.price});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  bool isFavorite = false;
  final TextEditingController reviewController = TextEditingController();
  double rating = 5.0;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  void checkFavoriteStatus() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.name)
        .get();

    setState(() {
      isFavorite = favoriteDoc.exists;
    });
  }

  void toggleFavorite() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentReference favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.name);

    if (isFavorite) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        "name": widget.name,
        "imageUrl": widget.imageUrl,
        "price": widget.price,
        "detail": widget.detail,
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.imageUrl, height: 300, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // معلومات المنتج داخل بطاقة
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(widget.detail, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text("💰 السعر: ${widget.price} DZ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // التحكم في الكمية
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                      });
                    },
                  ),
                  Text('$quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر الطلب الآن
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(
                        name: widget.name,
                        imageUrl: widget.imageUrl,
                        price: widget.price,
                        quantity: quantity,
                      ),
                    ),
                  );
                },
                child: const Text("🛒 الطلب الآن", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
