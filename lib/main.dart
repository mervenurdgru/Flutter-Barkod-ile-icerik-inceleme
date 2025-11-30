import 'screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';

// İleride buraya ekran importları gelecek

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barkod İçerik İnceleme',
      debugShowCheckedModeBanner: false, // Sağ üstteki "Debug" bandını kaldırır
      // Uygulamanın Teması
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

      // Henüz Login ekranını yapmadığımız için geçici olarak boş bir ekran açıyoruz
      home: const Scaffold(
        body: Center(child: Text("Barkod Uygulaması Hazırlanıyor...")),
      ),
    );
  }
}
