
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart';

class LoginRedirectSection extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginRedirectSection({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sudah punya akun?",
          style: TextStyle(color: AppColors.darkBackground),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Masuk disini',
            style: TextStyle(
              color: AppColors.darkBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
