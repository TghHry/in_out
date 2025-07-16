// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out_2/presentations/attandance/auth/login/pages/login_page.dart';
import 'package:in_out_2/presentations/attandance/auth/register/pages/register_page.dart';
import 'package:in_out_2/presentations/attandance/home/pages/main_page.dart';
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi lokal tanggal

/// Fungsi utama yang menjalankan aplikasi Flutter.
void main() async {
  // Memastikan semua widget Flutter binding sudah diinisialisasi.
  WidgetsFlutterBinding.ensureInitialized();

  // Memanggil initializeDateFormatting untuk mendukung format tanggal/waktu
  // dalam bahasa Indonesia ('id_ID') di seluruh aplikasi.
  await initializeDateFormatting('id_ID', null);

  // Mengatur gaya overlay UI sistem (status bar, navigation bar).
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Membuat status bar transparan
      statusBarIconBrightness: Brightness.light, // Warna ikon status bar
      statusBarBrightness: Brightness.dark, // Untuk iOS
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'in_out', // Nama aplikasi Anda
      // Tema terang aplikasi. Anda bisa sesuaikan sesuai desain AppColors.
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Contoh kustomisasi dari AppColors.dart
        scaffoldBackgroundColor: const Color(
          0xFFF5F5F5,
        ), // Contoh lightBackground
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5373E0), // Contoh homeTopBlue
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black54),
          headlineSmall: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),

      initialRoute: '/login', // Rute awal aplikasi (biasanya SplashPage)
      routes: {
        // '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) =>
            const MainPage(), // Halaman utama dengan BottomNavigationBar
      },
    );
  }
}
