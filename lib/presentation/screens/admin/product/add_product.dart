import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({super.key});

  @override
  State<ProductAddPage> createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final nameCtrl = TextEditingController();

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

  Future<void> pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
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
                "Tambah Produk Baru",
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
                  _buttonSave(),
                  const SizedBox(height: 12),
                  _buttonCancel(context),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPicker() {
    return GestureDetector(
      onTap: pickPhoto,
      child: Container(
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
                    : null,
              ),
              child: photoBytes == null
                  ? Icon(Icons.image, size: 32, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                photoName ?? "Pilih Foto Produk",
                style: TextStyle(
                  fontSize: 15,
                  color: photoBytes == null
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
            hint: Text(
              "Pilih Kategori",
              style: TextStyle(color: Colors.grey.shade700),
            ),
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
        )
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Simpan",
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
