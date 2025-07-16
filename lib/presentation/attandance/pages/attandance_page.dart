import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_out_2/data/copyright_watermark.dart';
import 'package:in_out_2/models/attandance_api_reponse.dart';
import 'package:in_out_2/models/attandance_model.dart';
import 'package:in_out_2/models/generic_api_response.dart';
import 'package:in_out_2/presentation/attandance/pages/widgets/attandance_button_sheet.dart';
import 'package:in_out_2/presentation/attandance/pages/widgets/attandance_map_section.dart';
import 'package:in_out_2/presentation/attandance/services/attandance_sevice.dart';
import 'package:in_out_2/services/session_manager.dart';
import 'package:in_out_2/utils/app_colors.dart';
import 'package:intl/intl.dart';

class AttandancePage extends StatefulWidget {
  const AttandancePage({super.key});

  @override
  State<AttandancePage> createState() => _AttandancePageState();
}

class _AttandancePageState extends State<AttandancePage> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  final TextEditingController _noteController = TextEditingController();

  Attendance? _todayAttendance;
  String _currentAddress = 'Mendapatkan lokasi...';
  double? _currentLat;
  double? _currentLng;

  bool _isFetchingInitialData = true;
  bool _isLoadingApiAction = false;
  String? _displayMessage;
  bool _isLocationPermissionsGrantedAndReady = false;

  final AttendanceService _attendanceService = AttendanceService();
  final SessionManager _sessionManager = SessionManager();

  late Stream<DateTime> _clockStream;

  final LatLng _officePosition = const LatLng(-6.2109, 106.8129);

  final double _allowedRadius = 200.0;
  double _distanceFromOffice = 0.0;

  DateTime? _selectedIzinDate;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    debugPrint('AttandancePage: initState terpanggil.');
    _initializePageData();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    debugPrint('AttandancePage: MapController dibuat.');
    _updateMapToCurrentLocation();
  }

  Future<void> _initializePageData() async {
    debugPrint('AttandancePage: _initializePageData dimulai.');
    if (!mounted) {
      debugPrint('AttandancePage: _initializePageData: Widget tidak mounted.');
      return;
    }
    setState(() {
      _isFetchingInitialData = true;
      _displayMessage = null;
      _isLocationPermissionsGrantedAndReady = false;
      _currentAddress = 'Mendapatkan lokasi...';
      _currentLat = null;
      _currentLng = null;
      _todayAttendance = null;
      _selectedIzinDate = null;
    });

    try {
      debugPrint('AttandancePage: Mencoba mendapatkan lokasi saat ini.');
      final Position position = await _getCurrentLocation();
      _currentLat = position.latitude;
      _currentLng = position.longitude;
      debugPrint(
        'AttandancePage: Lokasi didapat: Lat: $_currentLat, Lng: $_currentLng',
      );

      if (!mounted) return;
      setState(() {
        _isLocationPermissionsGrantedAndReady = true;
      });

      _updateMapToCurrentLocation();
      await _getAddressFromLatLng(position);
      debugPrint('AttandancePage: Alamat didapat: $_currentAddress');

      _distanceFromOffice = Geolocator.distanceBetween(
        _currentLat!,
        _currentLng!,
        _officePosition.latitude,
        _officePosition.longitude,
      );
      debugPrint(
        'AttandancePage: Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
      );

      await _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('AttandancePage: Error di _initializePageData: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
        _currentAddress = 'Alamat tidak ditemukan / Izin lokasi diperlukan.';
        _isLocationPermissionsGrantedAndReady = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Inisialisasi: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isFetchingInitialData = false;
      });
      debugPrint('AttandancePage: _initializePageData selesai.');
    }
  }

  Future<Position> _getCurrentLocation() async {
    debugPrint('AttandancePage: _getCurrentLocation dimulai.');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('AttandancePage: Layanan lokasi tidak diaktifkan.');
      return Future.error(
        'Layanan lokasi tidak diaktifkan. Mohon aktifkan GPS Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('AttandancePage: Izin lokasi ditolak, meminta izin.');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('AttandancePage: Izin lokasi masih ditolak.');
        return Future.error('Izin lokasi ditolak. Mohon izinkan akses lokasi.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('AttandancePage: Izin lokasi ditolak secara permanen.');
      return Future.error(
        'Izin lokasi ditolak secara permanen. Mohon ubah di pengaturan aplikasi.',
      );
    }

    debugPrint('AttandancePage: Mendapatkan posisi GPS saat ini.');
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    debugPrint('AttandancePage: _getAddressFromLatLng dimulai.');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          List<String> addressParts =
              [
                place.street ?? '',
                place.subLocality ?? '',
                place.locality ?? '',
                place.subAdministrativeArea ?? '',
                place.administrativeArea ?? '',
                place.country ?? '',
              ].where((s) => s.isNotEmpty).toList();

          _currentAddress = addressParts.join(', ');
          if (_currentAddress.isEmpty) {
            _currentAddress = 'Alamat tidak ditemukan.';
          }

          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(
                title: 'Lokasi Anda',
                snippet: _currentAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            ),
          );
          _markers.add(
            Marker(
              markerId: const MarkerId('officeLocation'),
              position: _officePosition,
              infoWindow: const InfoWindow(
                title: 'Lokasi Kantor',
                snippet: 'Titik pusat absensi',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          );
        });
        debugPrint(
          'AttandancePage: Alamat dari LatLng berhasil: $_currentAddress',
        );
      } else {
        setState(() {
          _currentAddress = 'Alamat tidak ditemukan.';
        });
        debugPrint('AttandancePage: Tidak ada placemarks ditemukan.');
      }
    } catch (e) {
      debugPrint('AttandancePage: Error mendapatkan alamat dari lokasi: $e');
      if (!mounted) return;
      setState(() {
        _currentAddress = 'Gagal mendapatkan alamat.';
      });
    }
  }

  void _updateMapToCurrentLocation() {
    debugPrint('AttandancePage: _updateMapToCurrentLocation dimulai.');
    if (mapController != null && _currentLat != null && _currentLng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_currentLat!, _currentLng!), 17.0),
      );
      debugPrint(
        'AttandancePage: Kamera peta diupdate ke lokasi: $_currentLat, $_currentLng',
      );
    } else {
      debugPrint(
        'AttandancePage: Tidak bisa update peta, lokasi atau mapController null. Akan menggunakan default atau menunggu.',
      );
    }
  }

  Future<void> _fetchTodayAttendanceStatus() async {
    debugPrint('AttandancePage: _fetchTodayAttendanceStatus dimulai.');
    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
      _displayMessage = null;
      _todayAttendance = null;
    });
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final AttendanceApiResponse response = await _attendanceService
          .getTodayAttendance(token);
      if (!mounted) return;

      setState(() {
        _todayAttendance = response.data;

        if (_todayAttendance == null) {
          if (response.message.contains('sudah melakukan absen')) {
            _displayMessage = response.message;
          }
        } else {
          _displayMessage = response.message;
        }
      });
      debugPrint(
        'AttandancePage: Status absensi hari ini berhasil diambil: ${_todayAttendance?.status ?? "Belum Absen"}',
      );
    } catch (e) {
      debugPrint('AttandancePage: Error fetching today attendance status: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
        _todayAttendance = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat status absensi: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _fetchTodayAttendanceStatus selesai.');
    }
  }

  void _showAttendanceActionDialog() {
    if (_isFetchingInitialData || _isLoadingApiAction) {
      debugPrint(
        'AttandancePage: Dialog aksi tidak ditampilkan karena sedang loading.',
      );
      return;
    }

    if (_currentLat == null ||
        _currentLng == null ||
        !_isLocationPermissionsGrantedAndReady) {
      if (_displayMessage != null &&
          (_displayMessage!.contains('Izin lokasi ditolak') ||
              _displayMessage!.contains('Layanan lokasi tidak diaktifkan'))) {
        _initializePageData();
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.loginCardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Pilih Aksi Absensi",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              if (_todayAttendance == null ||
                  _todayAttendance?.checkOut != null) ...[
                ListTile(
                  leading: const Icon(
                    Icons.login,
                    color: AppColors.loginButtonColor,
                  ),
                  title: const Text('Check In (Masuk)'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmCheckIn();
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.event_busy, color: Colors.orange),
                //   title: const Text('Ajukan Izin / Sakit'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _showIzinReasonDialog();
                //   },
                // ),
              ],
              if (_todayAttendance?.status == 'masuk' &&
                  _todayAttendance?.checkOut == null)
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.accentColor,
                  ),
                  title: const Text(
                    'Check Out',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmCheckOut();
                  },
                ),
              // if (_todayAttendance?.status == 'izin' ||
              //     (_todayAttendance?.checkIn != null &&
              //         _todayAttendance?.checkOut != null))
              //   ListTile(
              //     leading: const Icon(Icons.info_outline, color: Colors.grey),
              //     title: Text(
              //       _todayAttendance?.status == 'izin'
              //           ? 'Status Hari Ini: Izin'
              //           : 'Status Hari Ini: Sudah Check In & Check Out',
              //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //         color: AppColors.textDark,
              //       ),
              //     ),
              //     onTap: () {
              //       Navigator.pop(context);
              //     },
              //   ),
            ],
          ),
        );
      },
    );
  }

  void _confirmCheckIn() {
    if (_currentLat == null ||
        _currentLng == null ||
        _currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum siap. Mohon tunggu sesaat.'),
          backgroundColor: Colors.orange,
        ),
      );
      _initializePageData();
      return;
    }

    if (_distanceFromOffice > _allowedRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak bisa Check In. Anda berada di luar radius ${_allowedRadius.toStringAsFixed(0)} meter dari kantor. Jarak Anda: ${_distanceFromOffice.toStringAsFixed(0)} meter.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Check In'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anda akan melakukan Check In pada lokasi saat ini:',
                ),
                const SizedBox(height: 8),
                Text('Alamat: $_currentAddress'),
                Text(
                  'Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
                ),
                if (_noteController.text.isNotEmpty)
                  Text('Catatan: ${_noteController.text}'),
                const SizedBox(height: 10),
                const Text('Pastikan lokasi sudah benar.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performCheckIn(isIzin: false);
                },
                child: Text("Check In Sekarang"),
              ),
            ],
          ),
    );
  }

  void _confirmCheckOut() {
    if (_currentLat == null ||
        _currentLng == null ||
        _currentAddress.isEmpty ||
        _currentAddress.contains('Mendapatkan lokasi')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum siap. Mohon tunggu sesaat.'),
          backgroundColor: Colors.orange,
        ),
      );
      _initializePageData();
      return;
    }

    if (_distanceFromOffice > _allowedRadius) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak bisa Check Out. Anda berada di luar radius ${_allowedRadius.toStringAsFixed(0)} meter dari kantor. Jarak Anda: ${_distanceFromOffice.toStringAsFixed(0)} meter.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Check Out'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anda akan melakukan Check Out dari lokasi saat ini:',
                ),
                const SizedBox(height: 8),
                Text('Alamat: $_currentAddress'),
                Text(
                  'Jarak dari kantor: ${_distanceFromOffice.toStringAsFixed(0)} meter',
                ),
                if (_noteController.text.isNotEmpty)
                  Text('Catatan: ${_noteController.text}'),
                const SizedBox(height: 10),
                const Text('Pastikan lokasi sudah benar.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performCheckOut();
                },
                child: const Text('Check Out Sekarang'),
              ),
              // ),
            ],
          ),
    );
  }

  Future<void> _performCheckIn({bool isIzin = false}) async {
    debugPrint('AttandancePage: _performCheckIn dimulai. isIzin: $isIzin');

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      dynamic response;

      if (isIzin) {
        response = await _attendanceService.submitIzin(
          token: token,
          date: DateFormat(
            'yyyy-MM-dd',
          ).format(_selectedIzinDate!), // Hanya tanggal
          reason:
              _noteController.text.isNotEmpty
                  ? _noteController.text
                  : "Tidak ada alasan",
        );
      } else {
        response = await _attendanceService.checkIn(
          token: token,
          latitude: _currentLat!,
          longitude: _currentLng!,
          address: _currentAddress,
          status: 'masuk',
        );
      }

      if (!mounted) return;
      setState(() {
        _noteController.clear();

        if (response is AttendanceApiResponse) {
          _todayAttendance = response.data;
          _displayMessage = response.message;
        } else if (response is GenericApiResponse) {
          _displayMessage = response.message;
          _todayAttendance = null;
        } else {
          _displayMessage =
              'Aksi berhasil, namun format respons tidak dikenal.';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_displayMessage!),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('AttandancePage: Aksi absensi gagal: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aksi absensi gagal: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _performCheckIn (atau Izin) selesai.');
    }
  }

  Future<void> _showIzinReasonDialog() async {
    _noteController.clear();

    // Inisialisasi tanggal izin untuk dialog, default ke hari ini
    _selectedIzinDate = DateTime.now();

    final String? alasanIzin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajukan Izin / Sakit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan alasan izin Anda (wajib)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedIzinDate != null
                            ? 'Tanggal Izin: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedIzinDate!)}'
                            : 'Pilih Tanggal Izin',
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedIzinDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ), // 1 tahun ke belakang
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ), // 1 tahun ke depan
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            _selectedIzinDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(null);
                  },
                ),
                ElevatedButton(
                  child: const Text('Kirim'),
                  onPressed: () {
                    // Validasi input
                    if (_noteController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Alasan izin tidak boleh kosong.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    if (_selectedIzinDate == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Mohon pilih tanggal izin.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(_noteController.text.trim());
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (alasanIzin != null && alasanIzin.isNotEmpty) {
      // _performCheckIn akan menggunakan _selectedIzinDate
      _performCheckIn(isIzin: true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi izin dibatalkan atau alasan tidak diisi.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _performCheckOut() async {
    debugPrint('AttandancePage: _performCheckOut dimulai.');

    if (!mounted) return;
    setState(() {
      _isLoadingApiAction = true;
    });
    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      final AttendanceApiResponse response = await _attendanceService.checkOut(
        token: token,
        latitude: _currentLat!,
        longitude: _currentLng!,
        address: _currentAddress,
      );
      if (!mounted) return;
      setState(() {
        _todayAttendance = response.data;
        _noteController.clear();
        _displayMessage = response.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_displayMessage!),
          backgroundColor: Colors.green,
        ),
      );
      await _fetchTodayAttendanceStatus();
    } catch (e) {
      debugPrint('AttandancePage: Check-out gagal: $e');
      if (!mounted) return;
      setState(() {
        _displayMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-out gagal: $_displayMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingApiAction = false;
      });
      debugPrint('AttandancePage: _performCheckOut selesai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AttandancePage: build terpanggil.');

    String currentStatusText = '';
    String actionButtonText = '';
    bool showActionButton = true;

    if (_isFetchingInitialData) {
      currentStatusText = 'Memuat lokasi & status absensi...';
      actionButtonText = 'Memuat...';
      showActionButton = true;
    } else if (_displayMessage != null &&
        (_todayAttendance == null || _todayAttendance?.status == null)) {
      if (_displayMessage!.contains('sudah melakukan absen')) {
        currentStatusText = _displayMessage!;
        actionButtonText = 'Absensi Selesai Hari Ini';
        showActionButton = false;
      } else if (_displayMessage!.contains('Izin lokasi ditolak') ||
          _displayMessage!.contains('Layanan lokasi tidak diaktifkan')) {
        currentStatusText = 'Error Lokasi: $_displayMessage';
        actionButtonText = 'Aktifkan Lokasi';
        showActionButton = true;
      } else if (_displayMessage!.contains(
        'Belum ada data absensi pada tanggal tersebut',
      )) {
        currentStatusText = 'Anda belum absen hari ini.';
        actionButtonText = 'Mulai Absensi';
        showActionButton = true;
      } else {
        currentStatusText = 'Error: $_displayMessage';
        actionButtonText = 'Coba Lagi';
        showActionButton = true;
      }
    } else if (_todayAttendance?.status == 'masuk') {
      if (_todayAttendance!.checkOut == null) {
        currentStatusText =
            'Anda sudah Check In pada ${_todayAttendance!.checkIn ?? 'N/A'}.';
        actionButtonText = 'Check Out';
        showActionButton = true;
      } else {
        currentStatusText =
            'Anda sudah Check In & Check Out pada ${_todayAttendance!.checkOut ?? 'N/A'}.';
        actionButtonText = 'Absensi Selesai Hari Ini';
        showActionButton = false;
      }
    } else if (_todayAttendance?.status == 'izin') {
      currentStatusText =
          'Anda sudah Izin hari ini karena ${_todayAttendance!.reason ?? 'alasan tidak dicatat'}.';
      actionButtonText = 'Anda Sedang Izin';
      showActionButton = false;
    } else {
      currentStatusText = 'Status absensi tidak dikenal.';
      actionButtonText = 'Mulai Absensi';
      showActionButton = true;
    }

    Color statusTextColor;
    if (currentStatusText.contains('Error') ||
        currentStatusText.contains('ditolak')) {
      statusTextColor = Colors.red;
    } else if (currentStatusText.contains('Anda belum absen') ||
        currentStatusText.contains('tidak dikenal')) {
      statusTextColor = Colors.orange;
    } else if (currentStatusText.contains('Check In pada') ||
        currentStatusText.contains('Izin hari ini')) {
      statusTextColor = Colors.green;
    } else if (currentStatusText.contains('Absensi Selesai')) {
      statusTextColor = Colors.blue;
    } else {
      statusTextColor = AppColors.textDark;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          MapSection(
            markers: _markers,
            initialCameraTarget:
                _currentLat != null && _currentLng != null
                    ? LatLng(_currentLat!, _currentLng!)
                    : _officePosition,
            onMapCreated: _onMapCreated,
            myLocationEnabled: _isLocationPermissionsGrantedAndReady,
            onRefreshLocation: _initializePageData,
          ),
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.15,
              maxChildSize: 0.8,
              snap: true,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                return AttendanceBottomSheet(
                  scrollController: scrollController,
                  currentAddress: _currentAddress,
                  distanceFromOffice: _distanceFromOffice,
                  allowedRadius: _allowedRadius,
                  currentStatusText: currentStatusText,
                  actionButtonText: actionButtonText,
                  showActionButton: showActionButton,
                  isFetchingInitialData: _isFetchingInitialData,
                  isLoadingApiAction: _isLoadingApiAction,
                  onRefresh: _initializePageData,
                  onActionButtonPressed: _showAttendanceActionDialog,
                  statusTextColor: statusTextColor,
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: StreamBuilder<DateTime>(
                stream: _clockStream,
                builder: (context, snapshot) {
                  final currentTime = snapshot.data ?? DateTime.now();
                  return Text(
                    DateFormat('HH:mm:ss', 'id_ID').format(currentTime),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.historyBlueShape,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          CopyrightWatermark(),
        ],
      ),
    );
  }
}
