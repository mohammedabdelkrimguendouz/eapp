import 'package:eapp/admin/admin_orders_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/order.dart';
import 'package:eapp/pages/profile.dart';
import 'package:eapp/pages/favorites.dart';
import 'package:eapp/pages/cart.dart';
import 'package:eapp/admin/home_admin.dart';
import 'package:eapp/admin/add_produit.dart';

class BottomnavAdmin extends StatefulWidget {
  const BottomnavAdmin({super.key});

  @override
  State<BottomnavAdmin> createState() => _BottomnavAdminState();
}

class _BottomnavAdminState extends State<BottomnavAdmin> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homepages;
  late Profile profile;
  late AdminOrdersPage adminOrdersPage;
  late AddProduit addProduit;

  @override
  void initState() {
    homepages =Home();
    profile = Profile();
    addProduit = AddProduit();
    adminOrdersPage = AdminOrdersPage();
    pages = [homepages,addProduit,adminOrdersPage, profile];
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
          Icon(Icons.add_box, size: 30, color: Colors.pink),
          Icon(Icons.list_alt, size: 30, color: Colors.pink),
          Icon(Icons.person, size: 30, color: Colors.pink),
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
