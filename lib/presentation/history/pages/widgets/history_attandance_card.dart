
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path benar

class HistoryAttendanceCard extends StatelessWidget {
  final String dayOfWeek;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final bool isLate;
  final String status;
  final String? reason;

  const HistoryAttendanceCard({
    super.key,
    required this.dayOfWeek,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isLate,
    required this.status,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (status == 'izin') {
      statusColor = Colors.orange;
      statusText = 'Izin';
    } else if (status == 'masuk') {
      if (isLate) {
        statusColor = AppColors.historyLateRed;
        statusText = 'Masuk (Terlambat)';
      } else {
        statusColor = Colors.green;
        statusText = 'Masuk';
      }
    } else {
      statusColor = Colors.grey;
      statusText = 'Tidak Diketahui';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.historyCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayOfWeek,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (status == 'izin' && reason != null && reason!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Alasan Izin: $reason',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check In',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkInTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            isLate && status == 'masuk'
                                ? AppColors.historyLateRed
                                : null,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right_alt, color: Colors.grey[600]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Check Out',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      checkOutTime,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
