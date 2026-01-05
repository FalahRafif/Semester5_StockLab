import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
  // LOAD USER DETAIL (FROM TOKEN USER ID)
  // ─────────────────────────────────────────────
  Future<void> _loadUser() async {
    final idStr = await TokenService.getUserId();

    if (idStr == null) {
      _showError("Session tidak valid, silakan login ulang");
      return;
    }

    userId = int.tryParse(idStr) ?? 0;
    if (userId <= 0) {
      _showError("ID user tidak valid");
      return;
    }

    final res = await _userManager.getUserDetail(userId);

    if (!mounted) return;

    if (!res.success || res.users.isEmpty) {
      _showError(res.message);
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

    if (result != null) {
      setState(() {
        profileFile = File(result.files.single.path!);
        profileBytes = result.files.single.bytes;
      });
    }
  }

  // ─────────────────────────────────────────────
  // SUBMIT UPDATE
  // ─────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => submitting = true);

    final res = await _userManager.updateUser(
      id: userId.toString(),
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(), // opsional
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      avatarFile: profileFile,
    );

    setState(() => submitting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res.message),
        backgroundColor:
        res.success ? ColorManager.primary : ColorManager.error,
      ),
    );

    if (res.success) {
      await Future.delayed(const Duration(seconds: 1));
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

  void _showError(String msg) {
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ColorManager.error),
    );
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
                  fontWeight: FontWeight.bold,
                  color: ColorManager.textDark,
                ),
              ),
              const SizedBox(height: 26),

              _avatarPicker(),
              const SizedBox(height: 26),

              _input("Nama", nameCtrl),
              const SizedBox(height: 14),
              _input("Email", emailCtrl),
              const SizedBox(height: 14),
              _input("Password (opsional)", passCtrl, isPassword: true),
              const SizedBox(height: 14),
              _input("Phone", phoneCtrl),
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
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorManager.textDark,
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
