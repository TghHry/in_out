
import 'package:flutter/material.dart';

class ProfileLoadingErrorView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool hasCurrentUser; 

  const ProfileLoadingErrorView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.hasCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasCurrentUser && errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (!hasCurrentUser) {
      return const Center(
        child: Text(
          'Tidak ada data profil ditemukan.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}