import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

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

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // PICK PROFILE
  // ─────────────────────────────────────────────
  Future<void> pickProfile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        profileFile = File(result.files.single.path!);
        profileBytes = result.files.single.bytes;
        profileName = result.files.single.name;
      });
    }
  }

  // ─────────────────────────────────────────────
  // SNACK
  // ─────────────────────────────────────────────
  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
        success ? ColorManager.success : ColorManager.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // VALIDATION (PASSWORD OPSIONAL)
  // ─────────────────────────────────────────────
  bool _validate() {
    if (nameCtrl.text.trim().isEmpty) {
      _showSnack("Nama tidak boleh kosong");
      return false;
    }

    if (emailCtrl.text.trim().isEmpty) {
      _showSnack("Email tidak boleh kosong");
      return false;
    }

    final emailRegex =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailCtrl.text.trim())) {
      _showSnack("Format email tidak valid");
      return false;
    }

    // ✅ PASSWORD OPSIONAL
    if (passCtrl.text.isNotEmpty && passCtrl.text.length < 6) {
      _showSnack("Password minimal 6 karakter");
      return false;
    }

    if (phoneCtrl.text.trim().isEmpty) {
      _showSnack("Nomor telepon tidak boleh kosong");
      return false;
    }

    final phone = phoneCtrl.text.trim();

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      _showSnack("Nomor telepon hanya boleh angka");
      return false;
    }

    if (!phone.startsWith('8')) {
      _showSnack("Nomor telepon harus diawali angka 8");
      return false;
    }

    if (phone.length < 10 || phone.length > 13) {
      _showSnack("Nomor telepon harus 10–13 digit");
      return false;
    }

    if (profileBytes == null && profileFile == null) {
      _showSnack("Foto profile wajib diisi");
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────────
  // SUBMIT UPDATE
  // ─────────────────────────────────────────────
  Future<void> _submitUpdate() async {
    if (!_validate()) return;

    setState(() => isLoading = true);

    final result = await _userManager.updateUser(
      id: widget.id,
      email: emailCtrl.text.trim(),
      password:
      passCtrl.text.trim().isEmpty ? '' : passCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      avatarFile: profileFile,
    );

    setState(() => isLoading = false);
    if (!mounted) return;

    _showSnack(result.message, success: result.success);

    if (result.success) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MobileWrapper(
            child: AppLayout(initialIndex: 4),
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
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

              _inputField(
                "Email",
                emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _inputField(
                "Password (opsional)",
                passCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              _inputField(
                "Phone (contoh: 89644447777)",
                phoneCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
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

  // ─────────────────────────────────────────────
  // COMPONENTS
  // ─────────────────────────────────────────────
  Widget _profilePicker() {
    return GestureDetector(
      onTap: pickProfile,
      child: Container(
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
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
      }) {
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
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
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
