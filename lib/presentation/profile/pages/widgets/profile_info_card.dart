
import 'package:flutter/material.dart';
import 'package:in_out_2/models/user_model.dart';
import 'package:in_out_2/presentation/profile/pages/widgets/profile_info_row.dart';
import 'package:in_out_2/utils/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final User currentUser;
  final VoidCallback onEditProfilePressed; 

  const ProfileInfoCard({
    super.key,
    required this.currentUser,
    required this.onEditProfilePressed,
  });

  String _getJenisKelaminDisplay(String? jenisKelaminCode) {
    if (jenisKelaminCode == 'L') return 'Laki-laki';
    if (jenisKelaminCode == 'P') return 'Perempuan';
    return 'Tidak Tersedia';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(25.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Informasi Pribadi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                onPressed: onEditProfilePressed,
              ),
            ],
          ),
          const SizedBox(height: 15),
          ProfileInfoRow(
            icon: Icons.person,
            label: 'Nama Lengkap',
            value: currentUser.name,
          ),
          ProfileInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: currentUser.email,
          ),
          ProfileInfoRow(
            icon: Icons.wc,
            label: 'Jenis Kelamin',
            value: _getJenisKelaminDisplay(currentUser.jenisKelamin),
          ),
          ProfileInfoRow(
            icon: Icons.school,
            label: 'Jurusan/Training',
            value: currentUser.training?.title ?? 'Tidak Tersedia',
          ),
          ProfileInfoRow(
            icon: Icons.group,
            label: 'Batch Ke',
            value: currentUser.batch?.batchKe ?? 'Tidak Tersedia',
          ),
        ],
      ),
    );
  }
}