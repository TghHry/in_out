//
import 'package:flutter/material.dart';
import 'package:in_out_2/utils/app_colors.dart';
import 'package:intl/intl.dart';

class LiveAttendanceCard extends StatelessWidget {
  final Stream<DateTime> clockStream;

  const LiveAttendanceCard({
    super.key,
    required this.clockStream,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.homeCardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Live Attendance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Center(
            child: StreamBuilder<DateTime>(
              stream: clockStream,
              builder: (context, snapshot) {
                final currentTime = snapshot.data ?? DateTime.now();
                return Text(
                  DateFormat('HH:mm:ss', 'id_ID').format(currentTime),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.homeTopBlue,
                      ),
                );
              },
            ),
          ),
          Center(
            child: Text(
              DateFormat('EEE, dd MMMM yyyy', 'id_ID').format(now),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const Divider(height: 30, thickness: 1),
          Text(
            'Office Hours',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            '08:00 AM - 05:00 PM',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}