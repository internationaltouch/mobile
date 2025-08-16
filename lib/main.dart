import 'package:flutter/material.dart';
import 'views/home_view.dart';

void main() {
  runApp(const FITMobileApp());
}

class FITMobileApp extends StatelessWidget {
  const FITMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIT Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
