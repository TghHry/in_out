// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out_2/presentation/auth/login/pages/login_page.dart';
import 'package:in_out_2/presentation/auth/register/pages/register_page.dart';
import 'package:in_out_2/presentation/home/pages/main_page.dart';
import 'package:intl/date_symbol_data_local.dart'; 

/// Fungsi utama yang menjalankan aplikasi Flutter.
void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await initializeDateFormatting('id_ID', null);


  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, 
      statusBarBrightness: Brightness.dark, 
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
      title: 'in_out', 
     
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
   
        scaffoldBackgroundColor: const Color(
          0xFFF5F5F5,
        ), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5373E0),
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

      initialRoute: '/login', 
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) =>
            const MainPage(), 
      },
    );
  }
}
