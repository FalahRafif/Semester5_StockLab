import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

import '../../../../application/category_manager.dart';

class CategoryEditPage extends StatefulWidget {
  final String id;
  final String name;

  const CategoryEditPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late TextEditingController nameCtrl;
  final CategoryManager _categoryManager = CategoryManager();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
  }

  Future<void> _submitUpdate() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama kategori wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _categoryManager.updateCategory(
      id: widget.id,
      name: nameCtrl.text.trim(),
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
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MobileWrapper(
            child: AppLayout(initialIndex: 5),
          ),
        ),
      );
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
                "Edit Kategori",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              _inputField("Nama Kategori", nameCtrl),
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

  Widget _buttonUpdate() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          "Update Kategori",
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
