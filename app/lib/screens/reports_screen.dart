import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/report.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ReportService.instance.streamReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun rapport pour le moment.'));
        }

        final reports = snapshot.data!.docs.map(Report.fromDoc).toList();
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${report.type} • ${report.departmentCode}'),
                subtitle: Text(
                  'Lieu: ${report.location}\n'
                  'Gravité: ${report.severity}/5 | Source: ${report.source}\n'
                  'Besoins: ${report.needs}\n'
                  'Date: ${report.createdAt != null ? dateFormat.format(report.createdAt!) : '...'}',
                ),
                isThreeLine: true,
                trailing: _StatusChip(status: report.status),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'resolved':
        color = Colors.green;
      case 'in_progress':
        color = Colors.orange;
      default:
        color = Colors.blueGrey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.15),
    );
  }
}
