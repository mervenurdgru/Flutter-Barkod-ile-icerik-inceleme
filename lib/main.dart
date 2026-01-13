import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'utils/colors.dart';
import 'screens/admin_product_list_screen.dart';
import 'screens/admin_product_add_screen.dart';
import 'screens/admin_product_edit_screen.dart';
import 'screens/admin_comment_list_screen.dart';
import 'screens/admin_report_list_screen.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barkod İçerik İnceleme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_panel': (context) => const AdminPanelScreen(),
        '/admin_products': (context) => const AdminProductListScreen(),
        '/admin_add': (context) => const AdminProductAddScreen(),
        '/admin_comments': (context) => const AdminCommentListScreen(),
        '/admin_reports': (context) => const AdminReportListScreen(),
      },
    );
  }
}
