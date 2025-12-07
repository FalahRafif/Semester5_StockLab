import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          "Selamat datang di Dashboard Admin!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
