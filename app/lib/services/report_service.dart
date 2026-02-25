import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  ReportService._();

  static final instance = ReportService._();
  final CollectionReference<Map<String, dynamic>> _reports =
      FirebaseFirestore.instance.collection('reports');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReports() {
    return _reports.orderBy('createdAt', descending: true).limit(100).snapshots();
  }

  Future<void> createReport({
    required String departmentCode,
    required String type,
    required int severity,
    required String location,
    required String needs,
    required String details,
  }) {
    return _reports.add({
      'departmentCode': departmentCode,
      'type': type,
      'severity': severity,
      'location': location,
      'needs': needs,
      'details': details,
      'status': 'new',
      'source': 'app',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
