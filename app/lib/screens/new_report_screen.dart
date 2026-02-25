import 'package:flutter/material.dart';

import '../services/report_service.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departmentController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _needsController = TextEditingController();
  final _detailsController = TextEditingController();

  int _severity = 3;
  bool _saving = false;

  @override
  void dispose() {
    _departmentController.dispose();
    _typeController.dispose();
    _locationController.dispose();
    _needsController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    await ReportService.instance.createReport(
      departmentCode: _departmentController.text.trim(),
      type: _typeController.text.trim(),
      severity: _severity,
      location: _locationController.text.trim(),
      needs: _needsController.text.trim(),
      details: _detailsController.text.trim(),
    );

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport enregistré.')),
      );
      _formKey.currentState?.reset();
      _departmentController.clear();
      _typeController.clear();
      _locationController.clear();
      _needsController.clear();
      _detailsController.clear();
      setState(() => _severity = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(labelText: 'Code département'),
              validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type de catastrophe'),
              validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 10),
            Text('Niveau de gravité: $_severity / 5'),
            Slider(
              value: _severity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _severity.toString(),
              onChanged: (value) => setState(() => _severity = value.round()),
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Localisation'),
            ),
            TextFormField(
              controller: _needsController,
              decoration: const InputDecoration(labelText: 'Besoins prioritaires'),
            ),
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(labelText: 'Détails opérationnels'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.send),
              label: Text(_saving ? 'Envoi...' : 'Envoyer le rapport'),
            ),
          ],
        ),
      ),
    );
  }
}
