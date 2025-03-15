import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eapp/service/user_preferences.dart';

class DatabaseMethods {

   final FirebaseAuth _auth = FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> addUser({
      required String uid,
      required String name,
      required String email,
      required String phone,
      String role = "Client",
      String? imageURL = null,
   }) async {
      await _firestore.collection("users").doc(uid).set({
         "uid": uid,
         "name": name,
         "email": email,
         "phone":phone,
         "role": role,
         "imageURL":imageURL,
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

         // جلب بيانات المستخدم من Firestore
         DocumentSnapshot userDoc = await _firestore
             .collection("users")
             .doc(userCredential.user!.uid)
             .get();

         if (userDoc.exists) {
            // حفظ بيانات المستخدم في الجهاز
            await UserPreferences.saveUser(
               uid: userCredential.user!.uid,
               name: userDoc["name"],
               email: userDoc["email"],
               role: userDoc["role"],
               imageURL: userDoc["imageURL"],
                phone: userDoc["phone"]
            );

            return userDoc["role"]; // إرجاع دور المستخدم
         } else {
            return null; // المستخدم غير موجود
         }
      } on FirebaseAuthException catch (e) {

         return null; // خطأ أثناء تسجيل الدخول
      }
   }

   Future<void> updateUser({
      required String uid,
      String? name,
      String? phone,
      String? imageURL,
   }) async {
      try {
         Map<String, dynamic> updatedData = {};
         if (name != null) updatedData["name"] = name;
         if (phone != null) updatedData["phone"] = phone;
         if (imageURL != null) updatedData["imageURL"] = imageURL;

         if (updatedData.isNotEmpty) {
            await _firestore.collection("users").doc(uid).update(updatedData);

            // تحديث البيانات المخزنة في SharedPreferences
            Map<String, String?> userData = await UserPreferences.getUser();
            await UserPreferences.saveUser(
               uid: uid,
               name: name ?? userData["name"] ?? "",
               email: userData["email"] ?? "",
               phone: phone ?? userData["phone"] ?? "",
               imageURL: imageURL ?? userData["imageURL"],
               role: userData["role"] ?? "Client",
            );
         }
      } catch (e) {
         print("❌ فشل تحديث البيانات: $e");
      }
   }

   // إضافة منتج إلى Firestore
   Future<void> addProduct({
      required String name,
      required String detail,
      required String imageUrl,
      required String price, // يتم استقباله كنص
      required String category,
   }) async {
      await FirebaseFirestore.instance.collection("products").add({
         "Name": name,
         "Detail": detail,
         "Image": imageUrl,
         "Price": num.tryParse(price) ?? 0, // تحويل إلى رقم مع قيمة افتراضية 0
         "Category": category,
         "timestamp": FieldValue.serverTimestamp(),
      });
   }

   // جلب المنتجات حسب الفئة
   Stream<QuerySnapshot> getProductbyCategory(String category) {
      return FirebaseFirestore.instance
          .collection("products")
          .where("Category", isEqualTo: category)
          .orderBy("timestamp", descending: true)
          .snapshots();
   }
}
