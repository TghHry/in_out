import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:in_out_2/models/login_response.dart';
import 'package:in_out_2/presentation/auth/login/pages/widgets/login_button.dart';
import 'package:in_out_2/presentation/auth/login/pages/widgets/login_form_card.dart';
import 'package:in_out_2/presentation/auth/login/pages/widgets/login_header.dart';
import 'package:in_out_2/presentation/auth/login/pages/widgets/signup_section.dart';
import 'package:in_out_2/presentation/auth/services/auth_service.dart';

import 'package:in_out_2/services/session_manager.dart';
import 'package:in_out_2/utils/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  final SessionManager _sessionManager = SessionManager();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    debugPrint('LoginPage: initState terpanggil.');
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _loadRememberedEmail() async {
    try {
      final String? rememberedEmail =
          await _sessionManager.getRememberedEmail();
      if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
        setState(() {
          _emailController.text = rememberedEmail;
          _rememberMe = true;
        });
      }
      debugPrint('LoginPage: Remembered email dimuat: $rememberedEmail');
    } catch (e) {
      debugPrint('LoginPage: Error memuat remembered email: $e');
    }
  }

  void _onLoginButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    debugPrint('LoginPage: Tombol Login ditekan.');
    debugPrint('LoginPage: Mencoba login dengan email: $email');

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('LoginPage: Memulai panggilan AuthService.login.');
      final LoginResponse response = await _authService.login(email, password);
      debugPrint('LoginPage: Respon API berhasil diparsing ke LoginResponse.');

      if (!mounted) return;

      if (response.token != null && response.user != null) {
        debugPrint(
          'LoginPage: Token dan User ditemukan. Memulai penyimpanan sesi.',
        );
        if (_rememberMe) {
          await _sessionManager.saveRememberedEmail(email);
          debugPrint('LoginPage: Email diingat: $email');
        } else {
          await _sessionManager.deleteRememberedEmail();
          debugPrint('LoginPage: Email tidak diingat, data dihapus.');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('LoginPage: SnackBar sukses ditampilkan.');

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (Route<dynamic> route) => false,
        );
        debugPrint('LoginPage: Navigasi ke /main selesai.');
      } else {
        debugPrint('LoginPage: Login gagal (token atau user null).');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('LoginPage: SnackBar error ditampilkan.');
      }
    } catch (e) {
      debugPrint('LoginPage: ERROR umum saat login: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login gagal: ${e.toString().contains('Failed host lookup') ? 'Tidak ada koneksi internet.' : e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('LoginPage: Loading state diset false.');
      }
    }
  }

  void _onForgotPasswordPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda menekan Lupa Password! (Belum diimplementasikan)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSignUpPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda menekan Daftar!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginPage: build terpanggil.');
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.loginBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/home2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.20),
                  const LoginHeader(),
                  SizedBox(height: screenHeight * 0.02),
                  LoginFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscureText: _obscureText,
                    togglePasswordVisibility: _togglePasswordVisibility,
                    rememberMe: _rememberMe,
                    onRememberMeChanged: (newValue) {
                      setState(() {
                        _rememberMe = newValue!;
                      });
                    },
                    onForgotPasswordPressed: _onForgotPasswordPressed,
                  ),
                  const SizedBox(height: 20),
                  LoginButton(
                    isLoading: _isLoading,
                    onPressed: _onLoginButtonPressed,
                  ),
                  const SizedBox(height: 20),
                  SignUpSection(
                    // Menggunakan widget terpisah
                    onSignUpPressed: _onSignUpPressed,
                  ),
                
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
