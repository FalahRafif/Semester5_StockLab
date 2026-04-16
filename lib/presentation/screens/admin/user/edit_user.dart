import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../application/user_manager.dart';

class UserEditPage extends StatefulWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarBase64;

  const UserEditPage({
    super.key,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarBase64,
  });

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  final passCtrl = TextEditingController();

  Uint8List? profileBytes;
  String? profileName;
  File? profileFile;

  bool isLoading = false;

  late UserManager _userManager;

  @override
  void initState() {
    super.initState();

    _userManager = UserManager();

    nameCtrl = TextEditingController(text: widget.name);
    emailCtrl = TextEditingController(text: widget.email);
    phoneCtrl = TextEditingController(text: widget.phone);

    if (widget.avatarBase64 != null && widget.avatarBase64!.isNotEmpty) {
      try {
        profileBytes =
            Uint8List.fromList(base64Decode(widget.avatarBase64!));
      } catch (_) {}
    }
  }

  // =============================================================
  // PICK PROFILE
  // =============================================================
  Future<void> pickProfile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      setState(() {
        profileFile = File(result.files.single.path!);
        profileBytes = result.files.single.bytes;
        profileName = result.files.single.name;
      });
    }
  }

  // =============================================================
  // SUBMIT UPDATE (FIXED FLOW)
  // =============================================================
  Future<void> _submitUpdate() async {
    setState(() => isLoading = true);

    final result = await _userManager.updateUser(
      id: widget.id,
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      avatarFile: profileFile,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    // 1️⃣ TAMPILKAN NOTIFIKASI DULU
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 2️⃣ JIKA SUKSES → DELAY → PINDAH HALAMAN
    if (result.success) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MobileWrapper(
            child: AppLayout(initialIndex: 1),
          ),
        ),
      );
    }
  }

  // =============================================================
  // UI
  // =============================================================
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
                "Edit User",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              _profilePicker(),
              const SizedBox(height: 26),

              _inputField("Nama", nameCtrl),
              const SizedBox(height: 16),

              _inputField("Email", emailCtrl),
              const SizedBox(height: 16),

              _inputField(
                "Password (opsional)",
                passCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              _inputField("Phone", phoneCtrl),
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

  // =============================================================
  // PROFILE PICKER
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
                  ? Icon(Icons.person,
                  size: 32, color: Colors.grey.shade600)
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
