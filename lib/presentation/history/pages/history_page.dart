import 'package:flutter/material.dart';
import 'package:in_out_2/data/copyright_watermark.dart';
import 'package:in_out_2/models/attandance_model.dart';
import 'package:in_out_2/presentation/history/pages/widgets/history_content.dart';
import 'package:in_out_2/presentation/history/pages/widgets/history_header.dart';
import 'package:in_out_2/presentation/history/pages/widgets/month_selector.dart';
import 'package:in_out_2/presentation/history/services/history_service.dart';
import 'package:in_out_2/services/session_manager.dart';
import 'package:in_out_2/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class HistoryPage extends StatefulWidget {
  final String userId;

  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  String _selectedMonth = DateFormat('MMMM', 'id_ID').format(DateTime.now());

  List<Attendance> _attendanceRecords = [];
  bool _isLoadingHistory = true;
  String? _historyError;

  final HistoryService _historyService = HistoryService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    debugPrint('HistoryPage: initState terpanggil.');
    _initializeSelectedMonth();
    _fetchHistoryData(_selectedMonth);
  }

  void _initializeSelectedMonth() {
    final currentMonthIndex = DateTime.now().month - 1;
    if (currentMonthIndex >= 0 && currentMonthIndex < _months.length) {
      _selectedMonth = _months[currentMonthIndex];
    } else {
      _selectedMonth = _months[0];
    }
  }

  int _getMonthNumber(String monthName) {
    try {
      final DateTime parsedDate = DateFormat('MMMM', 'id_ID').parse(monthName);
      return parsedDate.month;
    } catch (e) {
      debugPrint('HistoryPage: Error parsing month name "$monthName": $e');
      return DateTime.now().month;
    }
  }

  Future<void> _fetchHistoryData(String month) async {
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
      _attendanceRecords = [];
    });

    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final int currentYear = DateTime.now().year;
      final int selectedMonthNumber = _getMonthNumber(month);

      final DateTime startDate = DateTime(currentYear, selectedMonthNumber, 1);
      final DateTime endDate = DateTime(
        currentYear,
        selectedMonthNumber + 1,
        0,
      );

      final String formattedStartDate = DateFormat(
        'yyyy-MM-dd',
      ).format(startDate);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      debugPrint(
        'HistoryPage: Memanggil getAttendanceHistory dari $formattedStartDate sampai $formattedEndDate',
      );

      final List<Attendance> fetchedHistory = await _historyService
          .getAttendanceHistory(
            token: token,
            startDate: formattedStartDate,
            endDate: formattedEndDate,
          );

      if (!mounted) return;
      setState(() {
        _attendanceRecords = fetchedHistory;
      });
      debugPrint(
        'HistoryPage: Riwayat absensi berhasil dimuat: ${_attendanceRecords.length} record.',
      );
    } catch (e) {
      debugPrint('HistoryPage: Error fetching attendance history: $e');
      if (!mounted) return;
      setState(() {
        _historyError = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat riwayat: $_historyError'),
          backgroundColor: Colors.red,
        ),
      );
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
        _sessionManager.clearSession().then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Mohon login kembali.'),
            ),
          );
        });
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
      });
      debugPrint('HistoryPage: _fetchHistoryData selesai.');
    }
  }

  Future<void> _deleteAttendanceRecord(int recordId) async {
    debugPrint('HistoryPage: Mencoba menghapus record dengan ID: $recordId');
    if (!mounted) return;
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final response = await _historyService.deleteAttendanceRecord(
        token: token,
        recordId: recordId,
      );

      debugPrint(
        'HistoryPage: Respon dari deleteAttendanceRecord: ${response.message}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );
      // Panggil ulang data setelah penghapusan berhasil
      _fetchHistoryData(_selectedMonth);
    } catch (e) {
      debugPrint('HistoryPage: Error deleting attendance record: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus absensi: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/home2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () => _fetchHistoryData(_selectedMonth),
              color: AppColors.historyBlueShape,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HistoryHeader(),
                    const SizedBox(height: 20),
                    MonthSelector(
                      months: _months,
                      selectedMonth: _selectedMonth,
                      isLoading: _isLoadingHistory,
                      onMonthSelected: (month) {
                        setState(() {
                          _selectedMonth = month;
                        });
                        _fetchHistoryData(month);
                      },
                    ),
                    const SizedBox(height: 20),
                    HistoryContent(
                      attendanceRecords: _attendanceRecords,
                      isLoading: _isLoadingHistory,
                      historyError: _historyError,
                      selectedMonth: _selectedMonth,
                      onDeleteRecord: _deleteAttendanceRecord,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CopyrightWatermark(
                  text: '© 2025 - IN - OUT. All rights reserved',
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
