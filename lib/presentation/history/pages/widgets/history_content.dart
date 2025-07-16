
import 'package:flutter/material.dart';
import 'package:in_out_2/models/attandance_model.dart';
import 'package:in_out_2/utils/app_colors.dart';
import 'package:intl/intl.dart'; 

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

class HistoryContent extends StatelessWidget {
  final List<Attendance> attendanceRecords;
  final bool isLoading;
  final String? historyError;
  final String selectedMonth;
  final Future<void> Function(int recordId)
  onDeleteRecord; // Callback untuk delete record

  const HistoryContent({
    super.key,
    required this.attendanceRecords,
    required this.isLoading,
    required this.historyError,
    required this.selectedMonth,
    required this.onDeleteRecord,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            historyError!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (attendanceRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada riwayat absensi untuk bulan $selectedMonth ini.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Managed by SingleChildScrollView in parent
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          final record = attendanceRecords[index];

          final dayOfWeek = DateFormat('EEEE', 'id_ID').format(record.date);
          final date = DateFormat('dd-MMM-yy').format(record.date);
          final checkInTimeDisplay = record.checkIn ?? 'N/A';
          final checkOutTimeDisplay = record.checkOut ?? 'Belum Check Out';

          bool isLate = false;
          if (record.checkIn != null && record.checkIn!.contains(':')) {
            try {
              final parts = record.checkIn!.split(':');
              final hour = int.tryParse(parts[0]);
              final minute = int.tryParse(parts[1]);
              if (hour != null && minute != null) {
                if (hour > 8 || (hour == 8 && minute > 0)) {
                  // Assuming 8:00 AM is the cutoff
                  isLate = true;
                }
              }
            } catch (e) {
              debugPrint(
                'HistoryContent: Error parsing check-in time for isLate: $e',
              );
            }
          }
          if (record.status == 'izin') {
            isLate = false; // Izin status should not be marked as late
          }

          return Dismissible(
            key: ValueKey(record.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text(
                      'Apakah Anda yakin ingin menghapus catatan absensi ini?',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Hapus'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              onDeleteRecord(record.id); // Panggil callback
            },
            child: HistoryAttendanceCard(
              dayOfWeek: dayOfWeek,
              date: date,
              checkInTime: checkInTimeDisplay,
              checkOutTime: checkOutTimeDisplay,
              isLate: isLate,
              status: record.status,
              reason: record.reason,
            ),
          );
        },
      );
    }
  }
}
