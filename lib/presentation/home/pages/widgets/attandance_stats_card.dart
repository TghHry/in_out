import 'package:flutter/material.dart';
import 'package:in_out_2/presentation/home/pages/widgets/stat_row.dart';
import 'package:in_out_2/utils/app_colors.dart'; // Pastikan path benar

class AttendanceStatsCard extends StatelessWidget {
  final Map<String, dynamic>? attendanceStats;
  final bool isLoadingStats;
  final String? statsErrorMessage;

  const AttendanceStatsCard({
    super.key,
    required this.attendanceStats,
    required this.isLoadingStats,
    required this.statsErrorMessage,
  });

  String _getTodayAttendanceStatusText(bool hasCheckedInToday) {
    if (attendanceStats == null) {
      return 'Memuat...';
    }
    return hasCheckedInToday ? 'Ya' : 'Belum';
  }

  Color _getTodayAttendanceStatusColor(bool hasCheckedInToday) {
    if (attendanceStats == null) {
      return Colors.grey;
    }
    return hasCheckedInToday ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Statistik Absensi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBackground,
            ),
          ),
        ),
        const SizedBox(height: 15),
        isLoadingStats
            ? const Center(child: CircularProgressIndicator())
            : statsErrorMessage != null
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gagal memuat statistik: $statsErrorMessage',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
            : attendanceStats == null || attendanceStats!.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Tidak ada data statistik tersedia.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
            : Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: AppColors.homeCardBackground,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  StatRow(
                    icon: Icons.calendar_today,
                    label: 'Total Absen',
                    value: '${attendanceStats!['total_absen_count']} hari',
                  ),
                  StatRow(
                    icon: Icons.check_circle_outline,
                    label: 'Total Masuk',
                    value: '${attendanceStats!['total_masuk_count']} hari',
                  ),
                  // StatRow(
                  //   icon: Icons.event_busy,
                  //   label: 'Total Izin',
                  //   value: '${attendanceStats!['total_izin_count']} hari',
                  // ),
                  StatRow(
                    icon: Icons.today,
                    label: 'Sudah Absen Hari Ini',
                    value: _getTodayAttendanceStatusText(
                      attendanceStats!['has_checked_in_today'] ?? false,
                    ),
                    valueColor: _getTodayAttendanceStatusColor(
                      attendanceStats!['has_checked_in_today'] ?? false,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
