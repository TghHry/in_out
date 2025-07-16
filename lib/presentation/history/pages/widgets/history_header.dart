
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path benar

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Riwayat Absensi',
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.historyBlueShape,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}