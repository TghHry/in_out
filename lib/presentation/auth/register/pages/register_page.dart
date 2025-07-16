
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_out_2/data/registration_dropdown_data.dart';
import 'package:in_out_2/models/batch_model.dart';
import 'package:in_out_2/models/training_model.dart';
import 'package:in_out_2/presentation/auth/register/pages/widgest/login_redirect_section.dart';
import 'package:in_out_2/presentation/auth/register/pages/widgest/register_button.dart';
import 'package:in_out_2/presentation/auth/register/pages/widgest/register_header.dart';
import 'package:in_out_2/presentation/auth/register/pages/widgest/registrations_form_field.dart';
import 'package:in_out_2/presentation/auth/services/auth_service.dart';
import 'package:in_out_2/utils/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Datum? _selectedTraining;
  BatchData? _selectedBatch;
  String? _selectedJenisKelaminValue;

  bool _obscureText = true;
  bool _isLoading = false;

  final List<Map<String, String>> _jenisKelaminOptions = kJenisKelaminOptions;
  final List<Datum> _trainings = kTrainingOptions;
  final List<BatchData> _batches = kBatchOptions;

  @override
  void initState() {
    super.initState();
    debugPrint('RegisterPage: initState terpanggil.');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onRegisterButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon lengkapi semua kolom yang wajib diisi dengan benar.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (_selectedTraining == null ||
        _selectedBatch == null ||
        _selectedJenisKelaminValue == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mohon pilih Jurusan/Training, Batch, dan Jenis Kelamin.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final int trainingId = _selectedTraining!.id;
    final int batchId = _selectedBatch!.id;
    final String jenisKelamin = _selectedJenisKelaminValue!;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('RegisterPage: Memulai panggilan AuthService.register.');
      final response = await AuthService().register(
        name: name,
        email: email,
        password: password,
        jenisKelamin: jenisKelamin,
        trainingId: trainingId,
        batchId: batchId,
        profilePhoto: null,
      );
      debugPrint('RegisterPage: Respon API register: ${response.message}');

      if (!mounted) return;

      if (response.message.contains('berhasil')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint(
          'RegisterPage: Registrasi berhasil, navigasi kembali ke login.',
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        debugPrint('RegisterPage: Registrasi gagal: ${response.message}');
      }
    } catch (e) {
      debugPrint('RegisterPage: Error umum saat registrasi: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrasi gagal: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('RegisterPage: Proses registrasi selesai.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: screenHeight * 0.1),
                  const RegisterHeader(), // Menggunakan widget terpisah
                  SizedBox(height: screenHeight * 0.03),
                  RegistrationFormFields(
                    // Menggunakan widget terpisah
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscureText: _obscureText,
                    togglePasswordVisibility: _togglePasswordVisibility,
                    jenisKelaminOptions: _jenisKelaminOptions,
                    selectedJenisKelaminValue: _selectedJenisKelaminValue,
                    onJenisKelaminChanged: (newValue) {
                      setState(() {
                        _selectedJenisKelaminValue = newValue;
                      });
                    },
                    trainings: _trainings,
                    selectedTraining: _selectedTraining,
                    onTrainingChanged: (newValue) {
                      setState(() {
                        _selectedTraining = newValue;
                      });
                    },
                    batches: _batches,
                    selectedBatch: _selectedBatch,
                    onBatchChanged: (newValue) {
                      setState(() {
                        _selectedBatch = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  RegisterButton(
                    // Menggunakan widget terpisah
                    isLoading: _isLoading,
                    onPressed: _onRegisterButtonPressed,
                  ),
                  const SizedBox(height: 20),
                  LoginRedirectSection(
                    // Menggunakan widget terpisah
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
