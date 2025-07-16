import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_out_2/data/copyright_watermark.dart';
import 'package:in_out_2/models/profile_model.dart';
import 'package:in_out_2/models/user_model.dart';
import 'package:in_out_2/presentation/auth/services/auth_service.dart';
import 'package:in_out_2/presentation/profile/pages/widgets/profile_actions.dart';
import 'package:in_out_2/presentation/profile/pages/widgets/profile_avatar_section.dart';
import 'package:in_out_2/presentation/profile/pages/widgets/profile_error_loading_view.dart';
import 'package:in_out_2/presentation/profile/pages/widgets/profile_info_card.dart';
import 'package:in_out_2/presentation/profile/services/profile_service.dart';
import 'package:in_out_2/services/session_manager.dart';
import 'package:in_out_2/utils/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    debugPrint('ProfilePage: initState terpanggil. Memuat data profil...');
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) {
      debugPrint('ProfilePage: _fetchUserProfile: Widget tidak mounted.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? cachedUser = await _sessionManager.getUser();
      if (cachedUser != null) {
        setState(() {
          _currentUser = cachedUser;
        });
        debugPrint('ProfilePage: Profil dimuat dari SessionManager (cache).');
      }

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
          'ProfilePage: Profil user berhasil dimuat dan diperbarui dari API.',
        );
      } else {
        debugPrint(
          'ProfilePage: Data profil null dari API: ${response.message}',
        );
      }
    } catch (e) {
      debugPrint('ProfilePage: Error fetching user profile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      if (e.toString().contains('token tidak valid') ||
          e.toString().contains('Sesi Anda telah berakhir') ||
          e.toString().contains('Token has expired')) {
        _authService.logout().then((_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesi Anda telah berakhir. Mohon login kembali.'),
            ),
          );
        });
      } else {
        if (_currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat profil: $_errorMessage')),
          );
        }
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('ProfilePage: _fetchUserProfile selesai.');
    }
  }

  void _showEditNameDialog() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil belum dimuat atau terjadi kesalahan.'),
        ),
      );
      return;
    }

    final TextEditingController nameController = TextEditingController(
      text: _currentUser!.name,
    );
    final GlobalKey<FormState> _formKeyDialog = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Nama Lengkap'),
          content: Form(
            key: _formKeyDialog,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
              onPressed:
                  _isLoading
                      ? null
                      : () async {
                        if (!_formKeyDialog.currentState!.validate()) {
                          return;
                        }

                        final String newName = nameController.text.trim();

                        if (newName == _currentUser!.name) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama tidak berubah.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          Navigator.of(dialogContext).pop();
                          return;
                        }

                        Navigator.of(dialogContext).pop();
                        _updateProfileOnServer(newName);
                      },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileOnServer(String newName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? token = await _sessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Token otentikasi tidak ditemukan. Mohon login kembali.',
        );
      }

      if (_currentUser == null) {
        throw Exception('Profil tidak dimuat, tidak bisa menyimpan perubahan.');
      }

      final ProfileResponse response = await _profileService.updateProfileData(
        token,
        name: newName,
      );
      if (!mounted) return;
      if (response.data != null) {
        final User? oldUserFromSession = await _sessionManager.getUser();
        if (oldUserFromSession == null) {
          throw Exception('Sesi pengguna tidak valid saat memperbarui profil.');
        }

        final DateTime userCreatedAt =
            response.data!.createdAt ?? oldUserFromSession.createdAt;
        final DateTime userUpdatedAt =
            response.data!.updatedAt ?? oldUserFromSession.updatedAt;

        final User mergedUser = User(
          id: oldUserFromSession.id,
          name: response.data!.name,
          email: oldUserFromSession.email,
          emailVerifiedAt: oldUserFromSession.emailVerifiedAt,
          createdAt: userCreatedAt,
          updatedAt: userUpdatedAt,
          batchId: oldUserFromSession.batchId,
          trainingId: oldUserFromSession.trainingId,
          jenisKelamin: oldUserFromSession.jenisKelamin,
          profilePhotoPath: oldUserFromSession.profilePhotoPath,
          onesignalPlayerId: oldUserFromSession.onesignalPlayerId,
          batch: oldUserFromSession.batch,
          training: oldUserFromSession.training,
        );

        await _sessionManager.saveUser(mergedUser);

        setState(() {
          _currentUser = mergedUser;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Profil berhasil diperbarui.'),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('ProfilePage: Nama profil berhasil diperbarui.');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal memperbarui profile'),
            backgroundColor: Colors.orange,
          ),
        );
        debugPrint('ProfilePage: Update profil gagal: ${response.message}');
      }
    } catch (e) {
      debugPrint('ProfilePage: Update profile failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan perubahan: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      debugPrint('ProfilePage: _updateProfileOnServer selesai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProfilePage: build terpanggil.');

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
            child: ProfileLoadingErrorView(
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              hasCurrentUser: _currentUser != null,
            ),
          ),
          if (!_isLoading && _currentUser != null && _errorMessage == null)
            RefreshIndicator(
              onRefresh: _fetchUserProfile,
              color: AppColors.homeTopBlue,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    ProfileAvatarSection(
                      currentUser: _currentUser,
                      onProfileUpdated: _fetchUserProfile,
                    ),
                    const SizedBox(height: 20),
                    ProfileInfoCard(
                      currentUser: _currentUser!,
                      onEditProfilePressed: _showEditNameDialog,
                    ),

                    ProfileActions(
                      onEditProfilePressed: _showEditNameDialog,
                      onLogoutPressed:
                          () => _authService.logout().then((_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anda telah keluar.'),
                              ),
                            );
                          }),
                    ),
                    const SizedBox(height: 50),
                    CopyrightWatermark(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
