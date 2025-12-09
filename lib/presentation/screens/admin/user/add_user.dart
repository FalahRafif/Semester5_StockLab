import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';

class UserAddPage extends StatefulWidget {
  const UserAddPage({super.key});

  @override
  State<UserAddPage> createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  Uint8List? profileBytes;
  String? profileName;

  Future<void> pickProfile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      setState(() {
        profileBytes = result.files.first.bytes;
        profileName = result.files.first.name;
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

              // ─────────────────────────────────────────────
              // TITLE
              // ─────────────────────────────────────────────
              Text(
                "Tambah User Baru",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              // ─────────────────────────────────────────────
              // FOTO PROFIL PICKER
              // ─────────────────────────────────────────────
              _profilePicker(),

              const SizedBox(height: 26),

              _inputField("Nama", nameCtrl),
              const SizedBox(height: 16),

              _inputField("Email", emailCtrl),
              const SizedBox(height: 16),

              _inputField("Password", passCtrl, isPassword: true),
              const SizedBox(height: 16),

              _inputField("Phone", phoneCtrl),
              const SizedBox(height: 32),

              Column(
                children: [
                  _buttonSave(),
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

  Widget _profilePicker() {
    return GestureDetector(
      onTap: pickProfile,
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
                image: profileBytes != null
                    ? DecorationImage(
                  image: MemoryImage(profileBytes!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: profileBytes == null
                  ? Icon(Icons.person, size: 32, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                profileName ?? "Pilih Foto Profile",
                style: TextStyle(
                  color: profileBytes == null
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

  Widget _inputField(
      String label,
      TextEditingController ctrl, {
        bool isPassword = false,
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
          obscureText: isPassword,
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
}
