import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:eapp/pages/home.dart';
import 'package:eapp/service/cloudinary_service.dart';
import 'package:eapp/widget/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eapp/service/database.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AddProduit extends StatefulWidget {
  final String? productId;
  final String? initialName;
  final String? initialPrice;
  final String? initialDetail;
  final String? initialImageUrl;
  final String? initialCategory;

  const AddProduit({
    super.key,
    this.productId,
    this.initialName,
    this.initialPrice,
    this.initialDetail,
    this.initialImageUrl,
    this.initialCategory,
  });

  @override
  State<AddProduit> createState() => _AddProduitState();
}

class _AddProduitState extends State<AddProduit> {
  final List<String> items = ['حلويات', 'خياطة', 'ملابس', 'إكسسوارات'];
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  String? selectedCategory;
  File? selectImage;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      nameController.text = widget.initialName ?? "";
      priceController.text = widget.initialPrice ?? "";
      detailController.text = widget.initialDetail ?? "";
      selectedCategory = widget.initialCategory;
      imageUrl = widget.initialImageUrl;
    }
  }

  Future<void> getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectImage = File(image.path);
      });
    }
  }

  Future<void> uploadItem() async {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        detailController.text.isNotEmpty &&
        selectedCategory != null) {
      String? finalImageUrl = imageUrl;

      if (selectImage != null) {
        CloudinaryService cloudinaryService = CloudinaryService();
        finalImageUrl = await cloudinaryService.uploadImage(selectImage!);
      }

      if (finalImageUrl != null) {
        if (widget.productId == null) {
          await DatabaseMethods().addProduct(
            name: nameController.text,
            detail: detailController.text,
            imageUrl: finalImageUrl,
            price: priceController.text,
            category: selectedCategory!,
          );
        } else {
          await DatabaseMethods().updateProduct(
            productId: widget.productId!,
            name: nameController.text,
            detail: detailController.text,
            imageUrl: finalImageUrl,
            price: priceController.text,
            category: selectedCategory!,
          );
        }

        showSnackBar("✅ تم ${widget.productId == null ? 'إضافة' : 'تعديل'} المنتج بنجاح!", Colors.green);
      }
    } else {
      showSnackBar("⚠️ الرجاء ملء جميع الحقول!", Colors.orange);
    }
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message, style: TextStyle(fontSize: 18.0)),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحذف"),
        content: Text("هل أنت متأكد أنك تريد حذف هذا المنتج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق نافذة التأكيد
              deleteProduct(); // تنفيذ الحذف
            },
            child: Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> deleteProduct() async {
    if (widget.productId != null) {
      await DatabaseMethods().deleteProduct(widget.productId!);
      showSnackBar("🗑️ تم حذف المنتج بنجاح!", Colors.red);
      Navigator.pop(context); // العودة بعد الحذف
    }
  }



  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.productId == null ? "إضافة منتج" : "تعديل المنتج"),
          actions: [
            if (widget.productId != null)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 26),
                onPressed: () => _showDeleteConfirmationDialog(),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: _buildImagePicker(),
                ),
                SizedBox(height: 30.0),
                _buildTextField("اسم المنتج", "أدخل اسم المنتج", nameController),
                _buildTextField("السعر", "أدخل السعر", priceController),
                _buildTextField("التفاصيل", "أدخل التفاصيل", detailController, maxLines: 6),
                SizedBox(height: 20.0),
                Text("الفئة", style: AppWidget.semiBooldTexeFeildStyle()),
                _buildDropdown(),
                SizedBox(height: 30.0),
                _buildButton(widget.productId == null ? "إضافة" : "تعديل", Colors.pink, uploadItem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: getImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(2, 2)),
            ],
          ),
          child: selectImage == null && imageUrl != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(imageUrl!, fit: BoxFit.cover),
          )
              : selectImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(selectImage!, fit: BoxFit.cover),
          )
              : Icon(Icons.camera_alt_outlined, color: Colors.pinkAccent, size: 50),
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (newValue) => setState(() => selectedCategory = newValue),
    );
  }
}
