import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/core/color_manager.dart';
import '../../shared/wrappers/mobile_wrapper.dart';
import '../../shared/widgets/app_layout.dart';

import '../../../application/user_manager.dart';
import '../../../data/services/token_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserManager _userManager = UserManager();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  Uint8List? profileBytes;
  File? profileFile;

  bool loading = true;
  bool submitting = false;
  int userId = 0;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ─────────────────────────────────────────────
  // LOAD USER DETAIL
  // ─────────────────────────────────────────────
  Future<void> _loadUser() async {
    final idStr = await TokenService.getUserId();

    if (idStr == null) {
      _showSnack("Session tidak valid, silakan login ulang");
      return;
    }

    userId = int.tryParse(idStr) ?? 0;
    if (userId <= 0) {
      _showSnack("ID user tidak valid");
      return;
    }

    final res = await _userManager.getUserDetail(userId);

    if (!mounted) return;

    if (!res.success || res.users.isEmpty) {
      _showSnack(res.message);
      return;
    }

    final user = res.users.first;

    nameCtrl.text = user.name;
    emailCtrl.text = user.email;
    phoneCtrl.text = user.phone;

    if (user.avatar.isNotEmpty) {
      try {
        profileBytes = base64Decode(user.avatar);
      } catch (_) {}
    }

    setState(() => loading = false);
  }

  // ─────────────────────────────────────────────
  // PICK AVATAR
  // ─────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        profileFile = File(result.files.single.path!);
        profileBytes = result.files.single.bytes;
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
  // VALIDATION (SAMA DENGAN EDIT USER)
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

    // PASSWORD OPSIONAL
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
  // SUBMIT
  // ─────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => submitting = true);

    final res = await _userManager.updateUser(
      id: userId.toString(),
      email: emailCtrl.text.trim(),
      password:
      passCtrl.text.trim().isEmpty ? '' : passCtrl.text.trim(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      avatarFile: profileFile,
    );

    setState(() => submitting = false);
    if (!mounted) return;

    _showSnack(res.message, success: res.success);

    if (res.success) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MobileWrapper(
            child: AppLayout(initialIndex: 7),
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
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),
              const SizedBox(height: 26),

              _avatarPicker(),
              const SizedBox(height: 26),

              _input("Nama", nameCtrl),
              const SizedBox(height: 14),

              _input(
                "Email",
                emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _input(
                "Password (opsional)",
                passCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 14),

              _input(
                "Phone (contoh: 89644447777)",
                phoneCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
              ),
              const SizedBox(height: 32),

              _btnUpdate(),
              const SizedBox(height: 12),
              _btnCancel(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // COMPONENTS
  // ─────────────────────────────────────────────
  Widget _avatarPicker() {
    return InkWell(
      onTap: _pickAvatar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorManager.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage:
              profileBytes != null ? MemoryImage(profileBytes!) : null,
              backgroundColor: Colors.grey.shade300,
              child: profileBytes == null
                  ? const Icon(Icons.person, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),
            const Expanded(child: Text("Ganti Foto Profile")),
            Icon(Icons.upload, color: ColorManager.primary),
          ],
        ),
      ),
    );
  }

  Widget _input(
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
            fontWeight: FontWeight.w600,
            color: ColorManager.textDark,
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

  Widget _btnUpdate() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: submitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Simpan Perubahan",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ColorManager.textWhite
          ),
        ),
      ),
    );
  }

  Widget _btnCancel() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Batal"),
      ),
    );
  }
}
