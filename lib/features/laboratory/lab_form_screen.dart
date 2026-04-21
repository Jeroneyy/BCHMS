import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';
import '../../core/constants/app_constants.dart';

class LabFormScreen extends StatefulWidget {
  final String? patientId;
  const LabFormScreen({super.key, this.patientId});
  @override
  State<LabFormScreen> createState() => _LabFormScreenState();
}

class _LabFormScreenState extends State<LabFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  String? _selectedPatientName;
  List<Map<String, dynamic>> _patients = [];
  LabTestType _testType = LabTestType.cbc;
  final _remarksCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() { super.initState(); _selectedPatientId = widget.patientId; _loadPatients(); }

  Future<void> _loadPatients() async {
    final snap = await FirebaseFirestore.instance.collection('patients').orderBy('lastName').get();
    setState(() {
      _patients = snap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'}; }).toList();
      if (_selectedPatientId != null) {
        final match = _patients.where((p) => p['id'] == _selectedPatientId);
        if (match.isNotEmpty) _selectedPatientName = match.first['name'] as String;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('lab_requests').add({
        'patientId': _selectedPatientId, 'patientName': _selectedPatientName,
        'testType': _testType.name, 'status': 'pending', 'remarks': _remarksCtrl.text.trim(),
        'requestedBy': context.read<AuthService>().currentUser?.name ?? '',
        'requestDate': FieldValue.serverTimestamp(), 'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Lab request created'); context.go('/laboratory'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _remarksCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/laboratory'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8), Text('New Lab Request', style: AppTypography.displaySmall),
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
                onChanged: (v) => setState(() { _selectedPatientId = v; _selectedPatientName = _patients.firstWhere((p) => p['id'] == v)['name'] as String; }),
                validator: (v) => v == null ? 'Required' : null),
              const SizedBox(height: 16),
              Text('Test Type', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<LabTestType>(initialValue: _testType,
                items: LabTestType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                onChanged: (v) => setState(() => _testType = v!)),
              const SizedBox(height: 16),
              Text('Remarks', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _remarksCtrl, maxLines: 3),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/laboratory'), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Request')),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }
}
