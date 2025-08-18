import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'theme/fit_theme.dart';

void main() {
  runApp(const FITMobileApp());
}

class FITMobileApp extends StatelessWidget {
  const FITMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIT',
      theme: FITTheme.lightTheme,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
