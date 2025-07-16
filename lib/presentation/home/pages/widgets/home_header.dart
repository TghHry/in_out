
import 'package:flutter/material.dart';
import 'package:in_out_2/models/user_model.dart';
import 'package:in_out_2/utils/app_colors.dart';
// import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final User? currentUser;
  final bool isLoadingProfile;
  final String? profileErrorMessage;
  final Stream<DateTime> clockStream; 

  const HomeHeader({
    super.key,
    required this.currentUser,
    required this.isLoadingProfile,
    required this.profileErrorMessage,
    required this.clockStream,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child:
          isLoadingProfile
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : profileErrorMessage != null
              ? Center(
                child: Text(
                  'Error memuat profil: $profileErrorMessage',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              )
              : (currentUser == null
                  ? const Center(
                    child: Text(
                      'Data profil tidak tersedia.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [ 
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.homeTopBlue,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              (currentUser!.fullProfilePhotoUrl != null &&
                                      currentUser!
                                          .fullProfilePhotoUrl!
                                          .isNotEmpty)
                                  ? Image.network(
                                    currentUser!.fullProfilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint(
                                        'HomeHeader: Error loading profile photo: $error',
                                      );
                                      return Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    'assets/images/user_avatar.png', // Pastikan path ini benar di assets Anda
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint(
                                        'HomeHeader: Error loading default avatar: $error',
                                      );
                                      return Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey[600],
                                      );
                                    },
                                  ),
                        ),
                      ),
                      const SizedBox(width:20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser!.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentUser!.email,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textDark.withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
    );
  }
}
