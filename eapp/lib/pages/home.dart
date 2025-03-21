import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eapp/admin/add_produit.dart';
import 'package:eapp/pages/details.dart';
import 'package:eapp/service/database.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool hala = true, iksis = false, khyata = false, malabs = false;
  Stream<QuerySnapshot>? produititemStream;
  List<DocumentSnapshot> products = [];
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
    onTheLoad("حلويات");
  }

  void checkAdminStatus() async {
    Map<String, String?> userData = await UserPreferences.getUser();
    String role = userData['role'] ?? "Client";
    setState(() {
      isAdmin = (role.trim() == "Admin");
    });
  }

  void onTheLoad(String category) {
    setState(() {
      isLoading = true;
      produititemStream = DatabaseMethods().getProductbyCategory(category);
    });

    produititemStream!.listen((snapshot) {
      setState(() {
        products = snapshot.docs;
        isLoading = false;
      });
    });
  }

  Widget allItemsVertically() {
    if (isLoading) {
      return Expanded(
        child: Center(
          child: SpinKitFadingCircle(color: Colors.pink, size: 50),
        ),
      );
    }

    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Text("⚠️ لا توجد منتجات متاحة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          DocumentSnapshot ds = products[index];

          return AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: 1.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    isAdmin
                        ? AddProduit(
                      productId: ds.id.toString(),
                      initialName: ds["Name"],
                      initialImageUrl: ds["Image"],
                      initialDetail: ds["Detail"],
                      initialPrice: ds["Price"].toString(),
                      initialCategory: ds["Category"],
                    )
                        : Details(
                      name: ds["Name"],
                      imageUrl: ds["Image"],
                      detail: ds["Detail"],
                      price: ds["Price"] is int
                          ? ds["Price"]
                          : int.tryParse(ds["Price"].toString()) ?? 0,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 6, spreadRadius: 2)
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        ds["Image"],
                        height: 130,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ds["Name"],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(ds["Detail"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700])),
                            SizedBox(height: 10),
                            Text("\dz${ds["Price"]}",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget showItem() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          categoryButton("images/halawyat.jpg", "حلويات", () {
            updateCategorySelection(true, false, false, false);
          }, hala),
          categoryButton("images/khiyata.jpg", "خياطة", () {
            updateCategorySelection(false, true, false, false);
          }, khyata),
          categoryButton("images/malabs.jpg", "ملابس", () {
            updateCategorySelection(false, false, true, false);
          }, malabs),
          categoryButton("images/iksiswar.jpg", "اكسيسورات", () {
            updateCategorySelection(false, false, false, true);
          }, iksis),
        ],
      ),
    );
  }

  Widget categoryButton(
      String imagePath, String category, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: () {
        onTheLoad(category);
        onTap();
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.pink : Colors.grey,
                width: isSelected ? 3 : 1.5,
              ),
            ),
            padding: EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.pink : Colors.black,
            ),
          )
        ],
      ),
    );
  }

  void updateCategorySelection(bool h, bool k, bool m, bool i) {
    setState(() {
      hala = h;
      khyata = k;
      malabs = m;
      iksis = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // دعم اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            showItem(),
            allItemsVertically(),
          ],
        ),
      ),
    );
  }
}
