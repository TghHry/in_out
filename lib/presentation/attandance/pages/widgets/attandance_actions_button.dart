// lib/presentation/absensi/attandance/pages/widgets/attendance_action_button.dart
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path benar

class AttendanceActionButton extends StatelessWidget {
  final String buttonText;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const AttendanceActionButton({
    super.key,
    required this.buttonText,
    required this.isLoading,
    required this.isDisabled,
    this.onPressed,
  });

  Color _getButtonColor() {
    if (buttonText.contains('Aktifkan') || buttonText.contains('Coba Lagi')) {
      return Colors.orange;
    } else if (buttonText.contains('Check Out')) {
      return AppColors.accentColor;
    } else if (buttonText.contains('Absensi Selesai') ||
        buttonText.contains('Sedang Izin')) {
      return Colors.grey;
    }
    return AppColors.darkBackground;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(),
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
