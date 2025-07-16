import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/user_model.dart';
import 'package:in_out_2/presentation/profile/services/profile_service.dart';
import 'package:in_out_2/services/session_manager.dart';
import 'package:in_out_2/utils/app_colors.dart';

class ProfileAvatarSection extends StatefulWidget {
  final User? currentUser;
  final VoidCallback
  onProfileUpdated; 

  const ProfileAvatarSection({
    super.key,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileAvatarSection> createState() => _ProfileAvatarSectionState();
}

class _ProfileAvatarSectionState extends State<ProfileAvatarSection> {
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  final SessionManager _sessionManager = SessionManager();
  bool _isUploadingPhoto = false;

  String? _getFullProfilePhotoUrl(String? profilePhotoPath) {
    if (profilePhotoPath == null || profilePhotoPath.isEmpty) {
      return null;
    }
    if (profilePhotoPath.startsWith('http://') ||
        profilePhotoPath.startsWith('https://')) {
      return profilePhotoPath;
    }
    const String publicStorageSegment = 'public/';
    String cleanedPhotoPath =
        profilePhotoPath.startsWith('/')
            ? profilePhotoPath.substring(1)
            : profilePhotoPath;
    return '${ApiService.baseUrl}/$publicStorageSegment$cleanedPhotoPath';
  }

  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      if (!mounted) return;
      setState(() => _isUploadingPhoto = true);

      try {
        final String? token = await _sessionManager.getToken();
        if (token == null) {
          throw Exception('Token tidak ditemukan. Mohon login kembali.');
        }

        final result = await _profileService.updateProfilePhoto(
          token,
          base64Image,
        );

        if (mounted) {
          final String? message = result.message;
          if (message != null && message.contains('berhasil diperbarui')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto profil berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
            debugPrint(
              'ProfileAvatarSection: Foto profil berhasil diunggah. Memanggil onProfileUpdated...',
            );
            widget.onProfileUpdated(); // Memicu refresh di ProfilePage
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message ?? 'Gagal update foto.'),
                backgroundColor: Colors.orange,
              ),
            );
            debugPrint(
              'ProfileAvatarSection: Update foto gagal: ${message ?? "Pesan tidak diketahui."}',
            );
          }
        }
      } catch (e) {
        debugPrint(
          'ProfileAvatarSection: Terjadi kesalahan saat mengupdate foto: $e',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Terjadi kesalahan saat mengupdate foto: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingPhoto = false);
        }
        debugPrint('ProfileAvatarSection: _changePhoto selesai.');
      }
    } else {
      debugPrint('ProfileAvatarSection: Pemilihan foto dibatalkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? photoUrl =
        widget.currentUser?.profilePhotoPath != null
            ? _getFullProfilePhotoUrl(widget.currentUser!.profilePhotoPath)
            : null;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.homeTopBlue, width: 3),
          ),
          child: ClipOval(
            child:
                _isUploadingPhoto
                    ? const Center(child: CircularProgressIndicator())
                    : (photoUrl != null && photoUrl.isNotEmpty)
                    ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                          'ProfileAvatarSection: Error loading network image: $error',
                        );
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        );
                      },
                    )
                    : Image.asset(
                      'assets/images/background.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                          'ProfileAvatarSection: Error loading default asset avatar: $error',
                        );
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        );
                      },
                    ),
          ),
        ),
        const SizedBox(height: 10),
        // TextButton.icon(
        //   icon: const Icon(Icons.photo_camera, size: 18),
        //   label:
        //       _isUploadingPhoto
        //           ? const Text("Mengunggah...")
        //           : const Text("Ubah Foto"),
        //   onPressed: _isUploadingPhoto ? null : _changePhoto,
        //   style: TextButton.styleFrom(foregroundColor: AppColors.textDark),
        // ),
      ],
    );
  }
}
