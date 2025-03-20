import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eapp/pages/order.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Details extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String detail;
  final int price;

  const Details({super.key, required this.name, required this.imageUrl, required this.detail, required this.price});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  int quantity = 1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();

    // إعداد الأنيميشن
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
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
    return Directionality(
      textDirection: TextDirection.rtl, // دعم الواجهة العربية
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(widget.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              onPressed: toggleFavorite,
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: widget.imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SpinKitFadingCircle(color: Colors.pink, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

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
                        Text("💰 السعر: ${widget.price} DZ",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                      ScaleTransition(
                        scale: _animation,
                        child: Text('$quantity', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
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
        ),
      ),
    );
  }
}
