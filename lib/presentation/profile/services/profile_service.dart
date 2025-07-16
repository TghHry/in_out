

import 'package:flutter/foundation.dart';
import 'package:in_out_2/api/api_service.dart';
import 'package:in_out_2/models/generic_api_response.dart';
import 'package:in_out_2/models/profile_model.dart';

class ProfileService {
  Future<ProfileResponse> fetchUserProfile(String token) async {
    debugPrint('ProfileService: Calling fetchUserProfile...');
    try {
      final Map<String, dynamic> responseData = await ApiService.get('api/profile', token: token);
      debugPrint('ProfileService: Raw response from ApiService.get (profile): $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('ProfileService: Error in fetchUserProfile service: $e');
      rethrow;
    }
  }

  Future<GenericApiResponse> updateProfilePhoto(String token, String base64Photo) async {
    debugPrint('ProfileService: Calling updateProfilePhoto...');
    try {
      final Map<String, dynamic> responseData = await ApiService.put(
        'api/profile/photo',
        {'profile_photo': 'data:image/png;base64,$base64Photo'},
        token: token,
      );
      debugPrint('ProfileService: Raw response from ApiService.put (photo): $responseData');
      return GenericApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('ProfileService: Error in updateProfilePhoto service: $e');
      rethrow;
    }
  }

  Future<ProfileResponse> updateProfileData(String token, {required String name}) async {
    debugPrint('ProfileService: Calling updateProfileData for name: $name');
    try {
      final Map<String, dynamic> responseData = await ApiService.put(
        'api/profile',
        {'name': name},
        token: token,
      );
      debugPrint('ProfileService: Raw response from ApiService.put (data): $responseData');
      return ProfileResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('ProfileService: Error in updateProfileData service: $e');
      rethrow;
    }
  }
}