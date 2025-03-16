import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eapp/service/user_preferences.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseMethods {
   final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> addUser({
      required String uid,
      required String name,
      required String email,
      required String phone,
      String role = "Client",
      String? imageURL,
      String? address,
   }) async {
      await _firestore.collection("users").doc(uid).set({
         "uid": uid,
         "name": name,
         "email": email,
         "phone": phone,
         "role": role,
         "imageURL": imageURL,
         "address": address,
         "createdAt": FieldValue.serverTimestamp(),
      });
   }

   Future<String?> userLogin({
      required String email,
      required String password,
   }) async {
      try {
         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
         );

         DocumentSnapshot userDoc =
         await _firestore.collection("users").doc(userCredential.user!.uid).get();

         if (userDoc.exists) {
            await UserPreferences.saveUser(
               uid: userCredential.user!.uid,
               name: userDoc["name"],
               email: userDoc["email"],
               role: userDoc["role"],
               imageURL: userDoc["imageURL"],
               phone: userDoc["phone"],
               address: userDoc["address"],
            );

            return userDoc["role"];
         } else {
            return null;
         }
      } on FirebaseAuthException {
         return null;
      }
   }

   Future<Map<String, dynamic>?> getAdminInfo() async {
      try {
         QuerySnapshot adminQuery = await _firestore
             .collection("users")
             .where("role", isEqualTo: "Admin")
             .limit(1)
             .get();

         if (adminQuery.docs.isNotEmpty) {
            return adminQuery.docs.first.data() as Map<String, dynamic>;
         }
      } catch (e) {
         print(e);
      }
      return null;
   }

   Future<Map<String, dynamic>?> getUserInfo(String userID) async {
      try {
         DocumentSnapshot userDoc = await _firestore.collection('users').doc(userID).get();
         return userDoc.exists ? userDoc.data() as Map<String, dynamic>? : null;
      } catch (e) {
         return null;
      }
   }

   Future<void> updateUser({
      required String uid,
      String? name,
      String? phone,
      String? imageURL,
      String? address,
   }) async {
      try {
         Map<String, dynamic> updatedData = {};
         if (name != null) updatedData["name"] = name;
         if (phone != null) updatedData["phone"] = phone;
         if (imageURL != null) updatedData["imageURL"] = imageURL;
         if (address != null) updatedData["address"] = address;

         if (updatedData.isNotEmpty) {
            await _firestore.collection("users").doc(uid).update(updatedData);

            Map<String, String?> userData = await UserPreferences.getUser();
            await UserPreferences.saveUser(
               uid: uid,
               name: name ?? userData["name"] ?? "",
               email: userData["email"] ?? "",
               phone: phone ?? userData["phone"] ?? "",
               imageURL: imageURL ?? userData["imageURL"],
               role: userData["role"] ?? "Client",
               address: address ?? userData["address"] ?? "",
            );
         }
      } catch (e) {
         print(e);
      }
   }

   // إضافة منتج جديد
   Future<void> addProduct({
      required String name,
      required String detail,
      required String imageUrl,
      required String price,
      required String category,
   }) async {
      await _firestore.collection("products").add({
         "Name": name,
         "Detail": detail,
         "Image": imageUrl,
         "Price": num.tryParse(price) ?? 0,
         "Category": category,
         "timestamp": FieldValue.serverTimestamp(),
      });
   }

   // حذف منتج معين
   Future<void> deleteProduct(String productId) async {
      await _firestore.collection("products").doc(productId).delete();
   }

   // تحديث بيانات المنتج
   Future<void> updateProduct({
      required String productId,
      String? name,
      String? detail,
      String? imageUrl,
      String? price,
      String? category,
   }) async {
      Map<String, dynamic> updatedData = {};
      if (name != null) updatedData["Name"] = name;
      if (detail != null) updatedData["Detail"] = detail;
      if (imageUrl != null) updatedData["Image"] = imageUrl;
      if (price != null) updatedData["Price"] = num.tryParse(price) ?? 0;
      if (category != null) updatedData["Category"] = category;

      if (updatedData.isNotEmpty) {
         await _firestore.collection("products").doc(productId).update(updatedData);
      }
   }

   // جلب المنتجات حسب الفئة
   Stream<QuerySnapshot> getProductbyCategory(String category) {
      return _firestore
          .collection("products")
          .where("Category", isEqualTo: category)
          .snapshots();
   }

   // إضافة طلب جديد
   Future<void> addOrder({
      required String userId,
      required String name,
      required String imageUrl,
      required int price,
      required int quantity,
   }) async {
      try {
         await _firestore.collection('orders').add({
            'userId': userId,
            'name': name,
            'imageUrl': imageUrl,
            'price': price,
            'quantity': quantity,
            'totalPrice': price * quantity,
            'status': 'قيد المعالجة',
            'timestamp': FieldValue.serverTimestamp(),
         });
      } catch (e) {
         throw e;
      }
   }


   Stream<List<QueryDocumentSnapshot>> getAllOrdersByTimeAndStatus() {
      var pendingOrdersStream = _firestore
          .collection("orders")
          .where("status", isEqualTo: "قيد المعالجة")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs);

      var otherOrdersStream = _firestore
          .collection("orders")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.where((doc) => doc["status"] != "قيد المعالجة").toList());

      return Rx.combineLatest2<List<QueryDocumentSnapshot>, List<QueryDocumentSnapshot>, List<QueryDocumentSnapshot>>(
         pendingOrdersStream,
         otherOrdersStream,
             (pendingOrders, otherOrders) => [...pendingOrders, ...otherOrders],
      );
   }


   Stream<List<QueryDocumentSnapshot>> getUserOrders(String userId) {
      try {
         return FirebaseFirestore.instance
             .collection('orders')
             .where('userId', isEqualTo: userId)
             .orderBy('timestamp', descending: true)
             .snapshots()
             .map((snapshot) => snapshot.docs);
      } catch (e) {
         return const Stream.empty();
      }
   }


   // تحديث حالة الطلب
   Future<void> updateOrderStatus(String orderId, String newStatus) async {
      await _firestore.collection("orders").doc(orderId).update({"status": newStatus});
   }
}
