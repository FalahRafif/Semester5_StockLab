import 'package:flutter/material.dart';

class MobileWrapper extends StatelessWidget {
  final Widget child;
  const MobileWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430, // width maksimum seperti HP
          ),
          child: child,
        ),
      ),
    );
  }
}
