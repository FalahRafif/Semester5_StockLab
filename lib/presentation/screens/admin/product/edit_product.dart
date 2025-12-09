import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';

class ProductEditPage extends StatefulWidget {
  final String productName;
  final String category;
  final String? productImageUrl; // opsional jika ingin tampilkan foto awal

  const ProductEditPage({
    super.key,
    required this.productName,
    required this.category,
    this.productImageUrl,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  late TextEditingController nameCtrl;

  Uint8List? photoBytes;
  String? photoName;

  String? selectedCategory;

  final List<String> categories = [
    "Elektronik",
    "Fashion",
    "Makanan & Minuman",
    "Kesehatan",
    "Kosmetik",
  ];

  @override
  void initState() {
    nameCtrl = TextEditingController(text: widget.productName);
    selectedCategory = widget.category;
    super.initState();
  }

  Future<void> pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      setState(() {
        photoBytes = result.files.first.bytes;
        photoName = result.files.first.name;
      });
    }
  }

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
                "Edit Produk",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              _photoPicker(),

              const SizedBox(height: 26),

              _inputField("Nama Produk", nameCtrl),

              const SizedBox(height: 16),

              _categoryDropdown(),

              const SizedBox(height: 32),

              Column(
                children: [
                  _buttonUpdate(),
                  const SizedBox(height: 12),
                  _buttonCancel(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FOTO PRODUK — IDENTIK DENGAN USER EDIT
  // =============================================================
  Widget _photoPicker() {
    return GestureDetector(
      onTap: pickPhoto,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
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
                image: photoBytes != null
                    ? DecorationImage(
                  image: MemoryImage(photoBytes!),
                  fit: BoxFit.cover,
                )
                    : (widget.productImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(widget.productImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null),
              ),
              child: (photoBytes == null && widget.productImageUrl == null)
                  ? Icon(Icons.image, size: 32, color: Colors.grey.shade600)
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                photoName ?? "Pilih Foto Produk",
                style: TextStyle(
                  color: photoBytes == null
                      ? Colors.grey.shade700
                      : ColorManager.textDark,
                  fontSize: 15,
                ),
              ),
            ),

            Icon(Icons.upload_file, color: ColorManager.primary),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // INPUT FIELD — IDENTIK DENGAN USER EDIT
  // =============================================================
  Widget _inputField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ColorManager.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
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

  // =============================================================
  // DROPDOWN KATEGORI
  // =============================================================
  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori",
            style: TextStyle(
              color: ColorManager.textDark,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ColorManager.inputFill,
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text("Pilih Kategori",
                style: TextStyle(color: Colors.grey.shade700)),
            items: categories.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => selectedCategory = val);
            },
          ),
        ),
      ],
    );
  }

  // =============================================================
  // BUTTON UPDATE — IDENTIK DENGAN USER UPDATE
  // =============================================================
  Widget _buttonUpdate() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Update Produk",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          "Batal",
          style: TextStyle(
            color: ColorManager.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
