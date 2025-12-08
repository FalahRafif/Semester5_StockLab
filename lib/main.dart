import 'package:flutter/material.dart';
import 'presentation/shared/wrappers/mobile_wrapper.dart';
import 'presentation/screens/auth/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env
  await dotenv.load();

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
      // home: const MobileWrapper(child: LoginScreen()),
      home: const MobileWrapper(child: SplashScreen()),

    );
  }
}
