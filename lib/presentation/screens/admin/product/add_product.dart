import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

import '../../../../application/product_manager.dart';

import '../../../../application/category_manager.dart';
import '../../../../data/models/category_response.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final nameCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final CategoryManager _categoryManager = CategoryManager();

  List<CategoryData> categories = [];
  CategoryData? selectedCategory;

  bool isCategoryLoading = true;

  File? imageFile;
  String? imageName;

  bool isLoading = false;
  final ProductManager _productManager = ProductManager();

  // ------------------------------------------------------------
  // PICK IMAGE
  // ------------------------------------------------------------
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
        imageName = result.files.single.name;
      });
    }
  }

  // ------------------------------------------------------------
  // SUBMIT
  // ------------------------------------------------------------
  Future<void> _submit() async {
    setState(() => isLoading = true);

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category wajib dipilih"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    final result = await _productManager.createProduct(
      name: nameCtrl.text.trim(),
      brand: brandCtrl.text.trim(),
      categoryId: selectedCategory!.id,
      imageFile: imageFile,
    );


    setState(() => isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (result.success) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const MobileWrapper(child: AppLayout(initialIndex: 4)),
        ),
      );
    }
  }

  Future<void> _loadCategories() async {
    final result = await _categoryManager.getCategories();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        categories = result.categories;
        isCategoryLoading = false;
      });
    } else {
      isCategoryLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text(
                "Tambah Product Baru",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),
              const SizedBox(height: 28),

              _imagePicker(),
              const SizedBox(height: 26),

              _inputField("Product Name", nameCtrl),
              const SizedBox(height: 16),

              _inputField("Brand", brandCtrl),
              const SizedBox(height: 16),

              _categoryDropdown(),
              const SizedBox(height: 32),

              _buttonSave(),
              const SizedBox(height: 12),
              _buttonCancel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ColorManager.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
                image: imageFile != null
                    ? DecorationImage(
                  image: FileImage(imageFile!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: imageFile == null
                  ? Icon(Icons.inventory,
                  size: 30, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                imageName ?? "Pilih Foto Product",
                style: TextStyle(
                  color: imageFile == null
                      ? Colors.grey.shade700
                      : ColorManager.textDark,
                ),
              ),
            ),
            Icon(Icons.upload_file, color: ColorManager.primary),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
      String label,
      TextEditingController ctrl, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              color: ColorManager.textDark,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonSave() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child:
          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          "Simpan",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buttonCancel(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: ColorManager.primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          "Batal",
          style: TextStyle(
              color: ColorManager.primary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category",
          style: TextStyle(
            color: ColorManager.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        isCategoryLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<CategoryData>(
          value: selectedCategory,
          items: categories.map((c) {
            return DropdownMenuItem<CategoryData>(
              value: c,
              child: Text(c.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedCategory = value);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text("Pilih Category"),
        ),
      ],
    );
  }

}
