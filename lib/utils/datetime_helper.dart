import 'package:flutter/foundation.dart';

DateTime? tryParseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(dateString);
  } catch (e) {
    if (dateString.length >= 19 && dateString.contains(' ')) {
      try {
        final String reformattedString = dateString.replaceFirst(' ', 'T') + 'Z';
        return DateTime.parse(reformattedString);
      } catch (e2) {
        debugPrint('Warning: Gagal mengurai string tanggal "$dateString" dengan format alternatif: $e2');
      }
    }
    debugPrint('Warning: Gagal mengurai string tanggal "$dateString" dengan DateTime.parse: $e');
  }
  return null;
}