
import 'package:in_out_2/models/batch_model.dart';
import 'package:in_out_2/models/training_model.dart'; 

final List<Datum> kTrainingOptions = [
  Datum(id: 1, title: 'Data Management Staff (Operator Komputer)'),
  Datum(id: 2, title: 'Bahasa Inggris'),
  Datum(id: 3, title: 'Desainer Grafis Madya'),
  Datum(id: 4, title: 'Tata Boga'),
  Datum(id: 5, title: 'Tata Busana'),
  Datum(id: 6, title: 'Perhotelan'),
  Datum(id: 7, title: 'Teknisi Komputer'),
  Datum(id: 8, title: 'Teknisi Jaringan'),
  Datum(id: 9, title: 'Barista'),
  Datum(id: 10, title: 'Bahasa Korea'),
  Datum(id: 11, title: 'Make Up Artist'),
  Datum(id: 12, title: 'Desainer Multimedia'),
  Datum(id: 13, title: 'Content Creator'),
  Datum(id: 14, title: 'Web Programming'),
  Datum(id: 15, title: 'Digital Marketing'),
  Datum(id: 16, title: 'Mobile Programming'),
  Datum(id: 17, title: 'Akuntansi Junior'),
  Datum(id: 18, title: 'Konstruksi Bangunan dengan CAD'),
];

final List<BatchData> kBatchOptions = [
  BatchData(id: 1, batchKe: 'Batch 1 (Juni - Juli 2025)', startDate: DateTime(2025, 6, 2), endDate: DateTime(2025, 7, 17)),
  // Anda bisa menambahkan batch lain di sini jika diperlukan:
  // BatchData(id: 2, batchKe: 'Batch 2 (Agustus - Oktober 2025)', startDate: DateTime(2025, 8, 1), endDate: DateTime(2025, 10, 31)),
];

final List<Map<String, String>> kJenisKelaminOptions = const [
  {'display': 'Laki-laki', 'value': 'L'},
  {'display': 'Perempuan', 'value': 'P'},
];