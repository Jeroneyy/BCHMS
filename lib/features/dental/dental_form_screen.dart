import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';

class DentalFormScreen extends StatefulWidget {
  final String? patientId;
  const DentalFormScreen({super.key, this.patientId});
  @override
  State<DentalFormScreen> createState() => _DentalFormScreenState();
}

class _DentalFormScreenState extends State<DentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];
  final _procedureCtrl = TextEditingController();
  final _teethCtrl = TextEditingController();
  final _findingsCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _datePerformed = DateTime.now();
  bool _loading = false;

  @override
  void initState() { super.initState(); _selectedPatientId = widget.patientId; _loadPatients(); }

  Future<void> _loadPatients() async {
    final snap = await FirebaseFirestore.instance.collection('patients').orderBy('lastName').get();
    setState(() { _patients = snap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'}; }).toList(); });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('dental_records').add({
        'patientId': _selectedPatientId, 'procedure': _procedureCtrl.text.trim(),
        'teethAffected': _teethCtrl.text.trim(), 'findings': _findingsCtrl.text.trim(),
        'treatment': _treatmentCtrl.text.trim(), 'notes': _notesCtrl.text.trim(),
        'datePerformed': Timestamp.fromDate(_datePerformed),
        'dentist': context.read<AuthService>().currentUser?.name ?? '',
        'createdBy': context.read<AuthService>().uid ?? '', 'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Dental record saved'); context.go('/dental'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _procedureCtrl.dispose(); _teethCtrl.dispose(); _findingsCtrl.dispose(); _treatmentCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/dental'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8), Text('New Dental Record', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700), padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Patient', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _selectedPatientId, hint: const Text('Select patient'),
                items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                onChanged: (v) => setState(() => _selectedPatientId = v), validator: (v) => v == null ? 'Required' : null),
              const SizedBox(height: 16),
              Text('Procedure', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _procedureCtrl, validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                decoration: const InputDecoration(hintText: 'e.g., Tooth Extraction, Filling, Cleaning')),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Teeth Affected', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  TextFormField(controller: _teethCtrl, decoration: const InputDecoration(hintText: 'e.g., #14, #36')),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Date Performed', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  InkWell(onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _datePerformed, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) setState(() => _datePerformed = d);
                  }, child: InputDecorator(decoration: const InputDecoration(), child: Text(AppDateUtils.shortDate(_datePerformed)))),
                ])),
              ]),
              const SizedBox(height: 16),
              Text('Findings', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _findingsCtrl, maxLines: 2),
              const SizedBox(height: 16),
              Text('Treatment', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _treatmentCtrl, maxLines: 2),
              const SizedBox(height: 16),
              Text('Notes', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _notesCtrl, maxLines: 2),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/dental'), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Record')),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }
}
