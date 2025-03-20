import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/pages/my_orders.dart';
import 'package:eapp/pages/profile.dart';
import 'package:eapp/pages/seller_profile.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> with SingleTickerProviderStateMixin {
  int currentTabIndex = 0;
  late List<Widget> pages;
  late Home homepages;
  late Profile profile;
  late MyOrdersPage myOrdersPage;
  late SellerProfile sellerProfile;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    homepages = Home();
    profile = Profile();
    sellerProfile = SellerProfile();
    myOrdersPage = MyOrdersPage();

    pages = [homepages, myOrdersPage, profile, sellerProfile];
    _pageController = PageController(initialPage: currentTabIndex);
  }

  void onTabTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
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
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colors.pinkAccent,
          buttonBackgroundColor: Colors.white,
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: const [
            Icon(Icons.home, size: 30, color: Colors.pink),
            Icon(Icons.shopping_bag, size: 30, color: Colors.pink),
            Icon(Icons.person, size: 30, color: Colors.pink),
            Icon(Icons.store, size: 30, color: Colors.pink),
          ],
          index: currentTabIndex,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}
