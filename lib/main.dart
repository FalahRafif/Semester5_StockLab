import 'package:flutter/material.dart';
import 'presentation/screens/wrappers/mobile_wrapper.dart';
import 'presentation/screens/auth/login.dart';

void main() {
  runApp(const StockApp());
}

class StockApp extends StatelessWidget {
  const StockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: "Roboto",
      ),
      home: const MobileWrapper(child: LoginScreen()),
    );
  }
}
