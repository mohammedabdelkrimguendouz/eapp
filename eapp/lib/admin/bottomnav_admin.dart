import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eapp/admin/admin_orders_page.dart';
import 'package:eapp/admin/admin_statistics_page.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/profile.dart';
import 'package:eapp/admin/add_produit.dart';

class BottomnavAdmin extends StatefulWidget {
  const BottomnavAdmin({super.key});

  @override
  State<BottomnavAdmin> createState() => _BottomnavAdminState();
}

class _BottomnavAdminState extends State<BottomnavAdmin> {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    pages = [
      Home(),
      AddProduit(),
      AdminOrdersPage(),
      AdminStatisticsPage(),
      Profile(),
    ];
    _pageController = PageController(initialPage: currentTabIndex);
  }

  void onTabTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: pages,
          physics: const NeverScrollableScrollPhysics(),
        ),
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
            Icon(Icons.bar_chart, size: 30, color: Colors.pink),
            Icon(Icons.person, size: 30, color: Colors.pink),
          ],
          index: currentTabIndex,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}
