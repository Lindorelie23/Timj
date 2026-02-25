import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  Report({
    required this.id,
    required this.departmentCode,
    required this.type,
    required this.severity,
    required this.location,
    required this.needs,
    required this.details,
    required this.status,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final String departmentCode;
  final String type;
  final int severity;
  final String location;
  final String needs;
  final String details;
  final String status;
  final String source;
  final DateTime? createdAt;

  factory Report.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Report(
      id: doc.id,
      departmentCode: data['departmentCode'] as String? ?? 'N/A',
      type: data['type'] as String? ?? 'N/A',
      severity: data['severity'] as int? ?? 1,
      location: data['location'] as String? ?? 'N/A',
      needs: data['needs'] as String? ?? 'N/A',
      details: data['details'] as String? ?? '',
      status: data['status'] as String? ?? 'new',
      source: data['source'] as String? ?? 'app',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
