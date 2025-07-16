import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path ini benar

class CopyrightWatermark extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double rotationAngle;

  const CopyrightWatermark({
    super.key,
    this.text = '© 2025 - IN - OUT. All rights reserved',
    this.fontSize = 15.0,
    this.textColor,
    this.fontWeight = FontWeight.bold,
    this.rotationAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: rotationAngle * (3.1415926535 / 180),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppColors.textDark.withOpacity(0.1),
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
