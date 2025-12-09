import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';

class UserEditPage extends StatefulWidget {
  final String name;
  final String email;

  const UserEditPage({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  final passCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  Uint8List? profileBytes;
  String? profileName;

  @override
  void initState() {
    nameCtrl = TextEditingController(text: widget.name);
    emailCtrl = TextEditingController(text: widget.email);
    super.initState();
  }

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

              // TITLE SAMA DENGAN ADD
              Text(
                "Edit User",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              // PROFILE PICKER — SAMA 100% DENGAN TAMBAH USER
              _profilePicker(),

              const SizedBox(height: 26),

              _inputField("Nama", nameCtrl),
              const SizedBox(height: 16),

              _inputField("Email", emailCtrl),
              const SizedBox(height: 16),

              _inputField("Password (opsional)", passCtrl, isPassword: true),
              const SizedBox(height: 16),

              _inputField("Phone", phoneCtrl),
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
  //  PROFILE PICKER — SAMA DENGAN USER ADD
  // =============================================================
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

  // =============================================================
  // INPUT FIELD — SAMA DENGAN USER ADD
  // =============================================================
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

  // =============================================================
  // BUTTON UPDATE — DISAMAKAN STYLE
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
          "Update User",
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
