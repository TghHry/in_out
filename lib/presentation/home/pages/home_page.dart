import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:in_out_2/data/copyright_watermark.dart';
import 'package:in_out_2/presentation/home/pages/widgets/attandance_stats_card.dart';
import 'package:in_out_2/presentation/home/pages/widgets/home_header.dart';
import 'package:in_out_2/presentation/home/pages/widgets/live_attandance.dart';
import 'package:in_out_2/presentation/home/services/home_service.dart';
import 'package:in_out_2/presentation/profile/services/profile_service.dart';
import 'package:in_out_2/models/profile_model.dart';
import 'package:in_out_2/models/user_model.dart';
import 'package:in_out_2/services/session_manager.dart';
import 'dart:async';
import 'package:in_out_2/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _attendanceStats;
  bool _isLoadingStats = true;
  String? _statsErrorMessage;
  User? _currentUser;
  bool _isLoadingProfile = true;
  String? _profileErrorMessage;

  late Stream<DateTime> _clockStream;

  final HomeService _homeService = HomeService();
  final ProfileService _profileService = ProfileService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    debugPrint('HomePage: initState terpanggil.');
    _fetchHomePageData();

    _clockStream =
        Stream.periodic(
          const Duration(seconds: 1),
          (_) => DateTime.now(),
        ).asBroadcastStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchHomePageData() async {
    // Menggunakan Future.wait untuk menjalankan keduanya secara paralel
    await Future.wait([_fetchUserProfile(), _fetchAttendanceStats()]);
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
      _currentUser = null; // Reset current user saat fetching
    });

    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final ProfileResponse response = await _profileService.fetchUserProfile(
        token,
      );
      if (!mounted) return;

      if (response.data != null) {
        final DateTime userCreatedAt =
            response.data!.createdAt ?? DateTime(2000, 1, 1);
        final DateTime userUpdatedAt =
            response.data!.updatedAt ?? DateTime(2000, 1, 1);

        final User fetchedUser = User(
          id: response.data!.id,
          name: response.data!.name,
          email: response.data!.email,
          emailVerifiedAt: response.data!.emailVerifiedAt,
          createdAt: userCreatedAt,
          updatedAt: userUpdatedAt,
          batchId: response.data!.batchId,
          trainingId: response.data!.trainingId,
          jenisKelamin: response.data!.jenisKelamin,
          profilePhotoPath: response.data!.profilePhoto,
          onesignalPlayerId: response.data!.onesignalPlayerId,
          batch: response.data!.batch,
          training: response.data!.training,
        );
        await _sessionManager.saveUser(fetchedUser);

        setState(() {
          _currentUser = fetchedUser;
        });
        debugPrint(
          'HomePage: Profil user berhasil dimuat dan diperbarui dari API.',
        );
      } else {
        if (_currentUser == null) {
          // Hanya set error message jika belum ada user yang di-cache
          _profileErrorMessage =
              response.message ?? 'Tidak ada data profil ditemukan.';
        }
        debugPrint('HomePage: Data profil null dari API: ${response.message}');
      }
    } catch (e) {
      debugPrint('HomePage: Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _profileErrorMessage = e.toString().replaceFirst('Exception: ', '');
        _currentUser = null; // Set null jika ada error
      });
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
      } else {
        if (_currentUser == null) {
          // Hanya tampilkan snackbar jika belum ada user yang di-cache
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memuat profil: $_profileErrorMessage'),
            ),
          );
        }
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingProfile = false;
      });
      debugPrint('HomePage: _fetchUserProfile selesai.');
    }
  }

  Future<void> _fetchAttendanceStats() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStats = true;
      _statsErrorMessage = null;
      _attendanceStats = null; // Reset stats saat fetching
    });

    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }
      final Map<String, dynamic> fetchedStats = await _homeService
          .getAttendanceStats(token);
      debugPrint('HomePage: Absen Stats API response raw: $fetchedStats');
      if (!mounted) return;
      setState(() {
        _attendanceStats = fetchedStats;

        // Pastikan parsing aman, gunakan operator null-aware dan default value
        _attendanceStats!['total_absen_count'] =
            int.tryParse(_attendanceStats!['total_absen']?.toString() ?? '0') ??
            0;
        _attendanceStats!['total_masuk_count'] =
            int.tryParse(_attendanceStats!['total_masuk']?.toString() ?? '0') ??
            0;
        _attendanceStats!['total_izin_count'] =
            int.tryParse(_attendanceStats!['total_izin']?.toString() ?? '0') ??
            0;
        _attendanceStats!['has_checked_in_today'] =
            _attendanceStats!['sudah_absen_hari_ini'] == true;

        _attendanceStats!['has_checked_out_today'] = false;
        debugPrint(
          'HomePage: _attendanceStats setelah parsing: $_attendanceStats',
        );
      });
    } catch (e) {
      debugPrint('HomePage: Error fetching attendance stats: $e');
      if (!mounted) return;
      setState(() {
        _statsErrorMessage = e.toString().replaceFirst('Exception: ', '');
        _attendanceStats = null;
      });
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat statistik: $_statsErrorMessage'),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingStats = false;
      });
      debugPrint('HomePage: _fetchAttendanceStats selesai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomePage: build terpanggil.');

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Gambar latar belakang yang mengisi penuh
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/home2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Konten halaman utama yang bisa di-scroll dan di-refresh
          Positioned.fill(
            // Penting: SingleChildScrollView harus dibatasi di dalam Stack
            child: RefreshIndicator(
              // <--- RefreshIndicator kembali di sini
              onRefresh: _fetchHomePageData, // <--- Callback refresh
              color: AppColors.homeTopBlue,
              backgroundColor:
                  Colors
                      .transparent, // Ubah agar gambar latar belakang terlihat
              child: SingleChildScrollView(
                // <--- SingleChildScrollView kembali di sini
                physics:
                    const AlwaysScrollableScrollPhysics(), // Selalu bisa digulir
                padding: const EdgeInsets.all(
                  0.0,
                ), // <--- Padding diubah menjadi 0.0
                child: SafeArea(
                  // <--- Membungkus Column dengan SafeArea
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ), // Padding awal di dalam SafeArea
                      HomeHeader(
                        currentUser: _currentUser,
                        isLoadingProfile: _isLoadingProfile,
                        profileErrorMessage: _profileErrorMessage,
                        clockStream: _clockStream,
                      ),
                      const SizedBox(height: 30),
                      LiveAttendanceCard(clockStream: _clockStream),
                      const SizedBox(height: 30),
                      // Menambahkan AttendanceStatsCard kembali
                      AttendanceStatsCard(
                        // <--- AttendanceStatsCard kembali di sini
                        attendanceStats: _attendanceStats,
                        isLoadingStats: _isLoadingStats,
                        statsErrorMessage: _statsErrorMessage,
                      ),
                      const SizedBox(
                        height: 50,
                      ), // Padding di bagian bawah konten
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Watermark COPYRIGHT di bagian bawah
          Positioned(
            // Menggunakan Positioned untuk kontrol posisi yang lebih presisi
            bottom: 10.0, // Jarak dari bawah layar
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CopyrightWatermark(
                text: '© 2025 - IN - OUT. All rights reserved',
                fontSize: 15.0,
                rotationAngle: 0.0, // Tidak perlu rotasi jika di bagian bawah
                textColor: AppColors.textDark.withOpacity(
                  0.5,
                ), // Sesuaikan warna agar terlihat jelas
              ),
            ),
          ),
        ],
      ),
    );
  }
}
