import 'dart:io';
import 'package:eapp/service/cloudinary_service.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:eapp/service/database.dart';


class AddProduit extends StatefulWidget {
  const AddProduit({super.key});

  @override
  State<AddProduit> createState() => _AddProduitState();
}

class _AddProduitState extends State<AddProduit> {
  final List<String> items = ['حلويات', 'خياطة', 'ملابس', 'اكسيسورات'];
  String? selectedCategory;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  final ImagePicker _picker=ImagePicker();
  File? selectImage;

  Future getImage()async{
    var image=await _picker.pickImage(source: ImageSource.gallery);
    selectImage=File(image!.path);
    setState(() {

    });
  }
  UploadItem() async {
    if (selectImage != null &&
        nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        detailController.text.isNotEmpty &&
        selectedCategory != null) {

      // تحميل الصورة إلى Cloudinary
      CloudinaryService cloudinaryService = CloudinaryService();
      String? imageUrl = await cloudinaryService.uploadImage(selectImage!);

      if (imageUrl != null) {
        // رفع المنتج إلى Firestore
        await DatabaseMethods().addProduct(
          name: nameController.text,
          detail: detailController.text,
          imageUrl: imageUrl,
          price: priceController.text,
          category: selectedCategory!,
        );

        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "✅ تمت إضافة المنتج بنجاح!",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      } else {
        // عرض رسالة خطأ عند فشل رفع الصورة
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "❌ فشل في تحميل الصورة",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      }
    } else {
      // عرض رسالة خطأ عند نقص المعلومات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            "⚠️ الرجاء ملء جميع الحقول!",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.pink),
        ),
        centerTitle: true,
        title: Text("Add Item", style: AppWidget.semiBooldTexeFeildStyle()),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload the Item picture", style: AppWidget.semiBooldTexeFeildStyle()),
              SizedBox(height: 20.0),


              selectImage== null ?GestureDetector(
                onTap: (){
                  getImage();
                },
                child: Center(
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.pinkAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.camera_alt_outlined, color: Colors.pinkAccent),
                    ),
                  ),
                ),
              ):
              Center(
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.pinkAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(selectImage!,fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.0),

              _buildTextField("Item Name", "Enter Item Name", nameController),
              _buildTextField("Item Price", "Enter Item Price", priceController),
              _buildTextField("Item Detail", "Enter Item Detail", detailController, maxLines: 6),

              SizedBox(height: 20.0),
              Text("Select Category", style: AppWidget.semiBooldTexeFeildStyle()),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: TextStyle(fontSize: 18.0, color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                    dropdownColor: Colors.white,
                    hint: Text("Select Category"),
                    iconSize: 36,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black87),
                  ),
                ),
              ),

              SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () {
                    UploadItem();
                  },
                  child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppWidget.semiBooldTexeFeildStyle()),
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: AppWidget.semiBooldTexeFeildStyle(),
            ),
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}
