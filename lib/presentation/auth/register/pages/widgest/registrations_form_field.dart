
import 'package:flutter/material.dart';
import 'package:in_out_2/models/batch_model.dart';
import 'package:in_out_2/models/training_model.dart';
import 'package:in_out_2/utils/app_colors.dart';

class RegistrationFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback togglePasswordVisibility;
  final List<Map<String, String>> jenisKelaminOptions;
  final String? selectedJenisKelaminValue;
  final ValueChanged<String?> onJenisKelaminChanged;
  final List<Datum> trainings;
  final Datum? selectedTraining;
  final ValueChanged<Datum?> onTrainingChanged;
  final List<BatchData> batches;
  final BatchData? selectedBatch;
  final ValueChanged<BatchData?> onBatchChanged;

  const RegistrationFormFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.togglePasswordVisibility,
    required this.jenisKelaminOptions,
    required this.selectedJenisKelaminValue,
    required this.onJenisKelaminChanged,
    required this.trainings,
    required this.selectedTraining,
    required this.onTrainingChanged,
    required this.batches,
    required this.selectedBatch,
    required this.onBatchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.loginCardColor,
      elevation: 3,
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong.';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                value: selectedJenisKelaminValue,
                hint: const Text('Pilih Jenis Kelamin'),
                items:
                    jenisKelaminOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option['value'],
                        child: Text(option['display']!),
                      );
                    }).toList(),
                onChanged: onJenisKelaminChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis kelamin wajib dipilih.';
                  }
                  return null;
                },
                dropdownColor: AppColors.loginCardColor,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<Datum>(
                decoration: const InputDecoration(
                  labelText: 'Jurusan/Training',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                value: selectedTraining,
                hint: const Text('Pilih Jurusan/Training'),
                items:
                    trainings.map((training) {
                      return DropdownMenuItem<Datum>(
                        value: training,
                        child: Text(training.title ?? 'Tidak diketahui'),
                      );
                    }).toList(),
                onChanged: onTrainingChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Jurusan wajib dipilih.';
                  }
                  return null;
                },
                dropdownColor: AppColors.loginCardColor,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<BatchData>(
                decoration: const InputDecoration(
                  labelText: 'Batch',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                value: selectedBatch,
                hint: const Text('Pilih Batch'),
                items:
                    batches.map((batch) {
                      return DropdownMenuItem<BatchData>(
                        value: batch,
                        child: Text(batch.batchKe ?? 'Tidak diketahui'),
                      );
                    }).toList(),
                onChanged: onBatchChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Batch wajib dipilih.';
                  }
                  return null;
                },
                dropdownColor: AppColors.loginCardColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
