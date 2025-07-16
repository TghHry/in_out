import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onEditProfilePressed;
  final VoidCallback onLogoutPressed;

  const ProfileActions({
    super.key,
    required this.onEditProfilePressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          SizedBox(width: double.infinity),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLogoutPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Keluar', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
