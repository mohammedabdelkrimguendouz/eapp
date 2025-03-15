import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eapp/pages/order.dart';
import 'package:eapp/widget/widget_support.dart';

// نموذج لتمثيل المنتج داخل السلة
class CartItem {
  final String name;
  final String imageUrl;
  final int price;
  int quantity;

  CartItem({required this.name, required this.imageUrl, required this.price, this.quantity = 1});
}

// **🔹 مزود البيانات لإدارة السلة (يستخدم مع Provider)**
class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    bool productExists = _cartItems.any((element) => element.name == item.name);

    if (productExists) {
      _cartItems.firstWhere((element) => element.name == item.name).quantity += 1;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity > 0) {
      item.quantity = newQuantity;
    } else {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  int getTotalPrice() {
    return _cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
  }
}

// **📌 صفحة السلة (CartPage)**
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛒 سلة المشتريات")),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return cartProvider.cartItems.isEmpty
              ? const Center(child: Text("السلة فارغة 🛍️"))
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(item.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        title: Text(item.name, style: AppWidget.boldTextFeildStyle()),
                        subtitle: Text("${item.price} DZ", style: AppWidget.semiBooldTexeFeildStyle()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                cartProvider.updateQuantity(item, item.quantity - 1);
                              },
                            ),
                            Text("${item.quantity}", style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                cartProvider.updateQuantity(item, item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // **📌 المجموع الكلي وزر إتمام الطلب**
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)
                ]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("المجموع الكلي:", style: AppWidget.boldTextFeildStyle()),
                        Text("${cartProvider.getTotalPrice()} DZ", style: AppWidget.boldTextFeildStyle()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (cartProvider.cartItems.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(
                                  name: cartProvider.cartItems[0].name,
                                  imageUrl: cartProvider.cartItems[0].imageUrl,
                                  price: cartProvider.cartItems[0].price,
                                  quantity: cartProvider.cartItems[0].quantity,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("إتمام الطلب", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
