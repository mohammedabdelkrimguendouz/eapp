import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/order.dart';
import 'package:eapp/pages/profile.dart';
import 'package:eapp/pages/favorites.dart';
import 'package:eapp/pages/cart.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homepages;
  late OrderPage orderPage;
  late Profile profile;
  late FavoritesPage favoritesPage;
  late CartPage cartPage;

  @override
  void initState() {
    homepages = Home();
    orderPage = OrderPage(name: "", imageUrl: "", price: 0, quantity: 0);
    profile = Profile();
    favoritesPage = const FavoritesPage();
    cartPage = const CartPage();

    pages = [homepages, orderPage, cartPage, profile, favoritesPage];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentTabIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.pinkAccent,
        buttonBackgroundColor: Colors.white,
        height: 60,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.pink),
          Icon(Icons.shopping_cart, size: 30, color: Colors.pink),
          Icon(Icons.shopping_bag, size: 30, color: Colors.pink),
          Icon(Icons.person, size: 30, color: Colors.pink),
          Icon(Icons.favorite, size: 30, color: Colors.pink),
        ],
        onTap: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
      ),
    );
  }
}
