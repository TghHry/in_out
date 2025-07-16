
import 'package:flutter/material.dart';

class SignUpSection extends StatelessWidget {
  final VoidCallback onSignUpPressed;

  const SignUpSection({super.key, required this.onSignUpPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Belum punya akun?",
          style: TextStyle(color: Colors.black87),
        ),
        TextButton(
          onPressed: onSignUpPressed,
          child: Text(
            'Daftar di sini',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
