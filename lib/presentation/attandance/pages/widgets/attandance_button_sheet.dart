
import 'package:flutter/material.dart';
import 'package:in_out_2/presentation/attandance/pages/widgets/attandance_actions_button.dart';
import 'package:in_out_2/utils/app_colors.dart';

class AttendanceBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final String currentAddress;
  final double distanceFromOffice;
  final double allowedRadius;
  final String currentStatusText;
  final String actionButtonText;
  final bool showActionButton;
  final bool isFetchingInitialData;
  final bool isLoadingApiAction;
  final Future<void> Function() onRefresh;
  final VoidCallback? onActionButtonPressed;
  final Color statusTextColor;

  const AttendanceBottomSheet({
    super.key,
    required this.scrollController,
    required this.currentAddress,
    required this.distanceFromOffice,
    required this.allowedRadius,
    required this.currentStatusText,
    required this.actionButtonText,
    required this.showActionButton,
    required this.isFetchingInitialData,
    required this.isLoadingApiAction,
    required this.onRefresh,
    this.onActionButtonPressed,
    required this.statusTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool interactionDisabled = isLoadingApiAction || isFetchingInitialData;

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
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.loginButtonColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                'Absensi Hari Ini',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi Anda',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                        ),
                        const SizedBox(height: 5),
                        isFetchingInitialData &&
                                currentAddress.contains('Mendapatkan lokasi')
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : Text(
                                currentAddress,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                              ),
                        if (!isFetchingInitialData &&
                            !currentAddress.contains('Mendapatkan lokasi') &&
                            !currentAddress.contains('Alamat tidak ditemukan'))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Jarak dari kantor: ${distanceFromOffice.toStringAsFixed(0)} meter',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: distanceFromOffice > allowedRadius
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: interactionDisabled
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(
                        'Status Absensi : $currentStatusText',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: statusTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
              ),
              const SizedBox(height: 10),
              AttendanceActionButton(
                buttonText: actionButtonText,
                isLoading: isLoadingApiAction,
                isDisabled: interactionDisabled || !showActionButton,
                onPressed: onActionButtonPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}