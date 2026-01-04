import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

import '../../../../application/product_manager.dart';
import '../../../../application/category_manager.dart';
import '../../../../data/models/category_response.dart';

class ProductEditPage extends StatefulWidget {
  final int id;
  final String name;
  final String brand;
  final int categoryId;
  final String? avatarBase64;

  const ProductEditPage({
    super.key,
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    this.avatarBase64,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late TextEditingController nameCtrl;
  late TextEditingController brandCtrl;

  final ProductManager _productManager = ProductManager();
  final CategoryManager _categoryManager = CategoryManager();

  List<CategoryData> categories = [];
  CategoryData? selectedCategory;
  bool isCategoryLoading = true;

  Uint8List? imageBytes;
  File? imageFile;
  String? imageName;

  bool isLoading = false;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.name);
    brandCtrl = TextEditingController(text: widget.brand);

    if (widget.avatarBase64 != null && widget.avatarBase64!.isNotEmpty) {
      try {
        imageBytes =
            Uint8List.fromList(base64Decode(widget.avatarBase64!));
      } catch (_) {}
    }

    _loadCategories();
  }

  // ------------------------------------------------------------
  // LOAD CATEGORIES
  // ------------------------------------------------------------
  Future<void> _loadCategories() async {
    final result = await _categoryManager.getCategories();

    if (!mounted) return;

    if (result.success) {
      final foundCategory = result.categories.firstWhere(
            (c) => c.id == widget.categoryId,
        orElse: () => result.categories.first,
      );

      setState(() {
        categories = result.categories;
        selectedCategory = foundCategory;
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
  // PICK IMAGE
  // ------------------------------------------------------------
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
        imageBytes = result.files.single.bytes;
        imageName = result.files.single.name;
      });
    }
  }

  // ------------------------------------------------------------
  // SUBMIT UPDATE
  // ------------------------------------------------------------
  Future<void> _submitUpdate() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category wajib dipilih"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _productManager.updateProduct(
      id: widget.id,
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

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
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
                "Edit Product",
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

              _buttonUpdate(),
              const SizedBox(height: 12),
              _buttonCancel(context),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WIDGETS
  // ------------------------------------------------------------
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
                image: imageBytes != null
                    ? DecorationImage(
                  image: MemoryImage(imageBytes!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: imageBytes == null
                  ? Icon(Icons.inventory,
                  size: 30, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                imageName ?? "Pilih Foto Product",
                style: TextStyle(
                  color: imageBytes == null
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

  Widget _buttonUpdate() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitUpdate,
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
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          "Update Product",
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
}
