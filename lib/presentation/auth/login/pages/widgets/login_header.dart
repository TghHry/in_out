
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang ',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.darkBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan masuk ke akun Anda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.darkBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
