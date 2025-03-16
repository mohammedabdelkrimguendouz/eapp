import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/order.dart';
import 'package:eapp/pages/profile.dart';
import 'package:eapp/pages/favorites.dart';
import 'package:eapp/pages/my_orders.dart';
import 'package:eapp/pages/seller_profile.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homepages;
  late Profile profile;
  late MyOrdersPage myOrdersPage;
  late SellerProfile sellerProfile;

  @override
  void initState() {
    homepages = Home();
    profile = Profile();
    sellerProfile = SellerProfile();
    myOrdersPage = MyOrdersPage();

    pages = [homepages,myOrdersPage, profile, sellerProfile];

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
          Icon(Icons.shopping_bag, size: 30, color: Colors.pink),
          Icon(Icons.person, size: 30, color: Colors.pink),
          Icon(Icons.store, size: 30, color: Colors.pink),
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

