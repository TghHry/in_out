
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path benar

class MonthSelector extends StatelessWidget {
  final List<String> months;
  final String selectedMonth;
  final bool isLoading;
  final ValueChanged<String> onMonthSelected;

  const MonthSelector({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.isLoading,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month == selectedMonth;
          return GestureDetector(
            onTap: () {
              if (isLoading) return; // Disable tap when loading
              onMonthSelected(month);
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.historyBlueShape
                    : AppColors.historyBlueShape.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                month,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppColors.historyYellowShape : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}