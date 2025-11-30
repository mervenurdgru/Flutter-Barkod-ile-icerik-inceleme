import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../utils/colors.dart'; // Renk dosyamız
// Kayıt ol ekranını yapınca buraya import edeceğiz.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kullanıcı adı ve şifre girin.')),
      );
      return;
    }

    setState(() => _isLoading = true); // Yükleniyor başlat

    // API İsteği Gönder
    String? error = await _authService.login(username, password);

    setState(() => _isLoading = false); // Yükleniyor bitir

    if (error == null) {
      // BAŞARILI! Ana sayfaya yönlendir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Giriş Başarılı!'),
          ),
        );
        // İleride buraya: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } else {
      // HATA VAR
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A), // React Native'deki koyu renk
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Başlık ---
                  const Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Kullanıcı Adı Input ---
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: "Kullanıcı Adı",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Şifre Input ---
                  TextField(
                    controller: _passwordController,
                    obscureText: true, // Şifreyi gizle
                    decoration: InputDecoration(
                      hintText: "Şifre",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Giriş Butonu ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF075EEC,
                        ), // React'teki Mavi
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Giriş Yap",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Kayıt Ol Linki ---
                  TextButton(
                    onPressed: () {
                      // Kayıt ol sayfasına git
                      print("Kayıt ol'a tıklandı");
                    },
                    child: const Text(
                      "Hesabınız yok mu? Kayıt olun.",
                      style: TextStyle(color: Color(0xFFB0C4DE), fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
