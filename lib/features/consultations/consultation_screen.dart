import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

import '../../core/widgets/empty_state.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _showForm = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  String? _selectedPatientName;
  final _complaintCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _prCtrl = TextEditingController();
  final _rrCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final snap = await FirebaseFirestore.instance.collection('patients').orderBy('lastName').get();
    setState(() {
      _patients = snap.docs.map((d) {
        final data = d.data();
        return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'};
      }).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) {
      if (_selectedPatientId == null) context.showSnack('Select a patient', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('consultations').add({
        'patientId': _selectedPatientId,
        'patientName': _selectedPatientName,
        'chiefComplaint': _complaintCtrl.text.trim(),
        'diagnosis': _diagnosisCtrl.text.trim(),
        'treatment': _treatmentCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'vitalSigns': {
          'bpSystolic': double.tryParse(_bpSysCtrl.text),
          'bpDiastolic': double.tryParse(_bpDiaCtrl.text),
          'temperature': double.tryParse(_tempCtrl.text),
          'pulseRate': double.tryParse(_prCtrl.text),
          'respiratoryRate': double.tryParse(_rrCtrl.text),
          'weight': double.tryParse(_weightCtrl.text),
          'height': double.tryParse(_heightCtrl.text),
        },
        'createdBy': context.read<AuthService>().uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        context.showSnack('Consultation recorded');
        _clearForm();
        setState(() => _showForm = false);
      }
    } catch (e) {
      if (mounted) context.showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  void _clearForm() {
    _complaintCtrl.clear(); _diagnosisCtrl.clear(); _treatmentCtrl.clear();
    _notesCtrl.clear(); _bpSysCtrl.clear(); _bpDiaCtrl.clear();
    _tempCtrl.clear(); _prCtrl.clear(); _rrCtrl.clear();
    _weightCtrl.clear(); _heightCtrl.clear();
    _selectedPatientId = null; _selectedPatientName = null;
  }

  @override
  void dispose() {
    _complaintCtrl.dispose(); _diagnosisCtrl.dispose(); _treatmentCtrl.dispose();
    _notesCtrl.dispose(); _bpSysCtrl.dispose(); _bpDiaCtrl.dispose();
    _tempCtrl.dispose(); _prCtrl.dispose(); _rrCtrl.dispose();
    _weightCtrl.dispose(); _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
            child: Row(children: [
              Expanded(child: Text('Consultations', style: AppTypography.displaySmall)),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showForm = !_showForm),
                icon: Icon(_showForm ? Icons.close_rounded : Icons.add_rounded, size: 18),
                label: Text(_showForm ? 'Cancel' : 'New Consultation'),
              ),
            ]),
          )),
          if (_showForm) SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: _buildForm(isWide),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20, vertical: 16),
            child: _buildList(),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildForm(bool isWide) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Record Consultation', style: AppTypography.titleLarge),
          const SizedBox(height: 20),
          Text('Patient', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedPatientId,
            hint: const Text('Select patient'),
            items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
            onChanged: (v) => setState(() {
              _selectedPatientId = v;
              _selectedPatientName = _patients.firstWhere((p) => p['id'] == v)['name'] as String;
            }),
          ),
          const SizedBox(height: 16),
          Text('Chief Complaint', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          TextFormField(controller: _complaintCtrl, validator: (v) => Validators.required(v, 'Complaint'), maxLines: 2),
          const SizedBox(height: 20),
          Text('Vital Signs', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _vitalField('BP Sys', _bpSysCtrl, 'mmHg', 100),
            _vitalField('BP Dia', _bpDiaCtrl, 'mmHg', 100),
            _vitalField('Temp', _tempCtrl, '°C', 90),
            _vitalField('PR', _prCtrl, 'bpm', 90),
            _vitalField('RR', _rrCtrl, '/min', 90),
            _vitalField('Weight', _weightCtrl, 'kg', 90),
            _vitalField('Height', _heightCtrl, 'cm', 90),
          ]),
          const SizedBox(height: 16),
          Text('Diagnosis', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          TextFormField(controller: _diagnosisCtrl, maxLines: 2),
          const SizedBox(height: 16),
          Text('Treatment / Prescription', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          TextFormField(controller: _treatmentCtrl, maxLines: 2),
          const SizedBox(height: 16),
          Text('Notes', style: AppTypography.labelMedium),
          const SizedBox(height: 6),
          TextFormField(controller: _notesCtrl, maxLines: 2),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => setState(() => _showForm = false), child: const Text('Cancel')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save Consultation'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _vitalField(String label, TextEditingController ctrl, String unit, double width) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(labelText: label, suffixText: unit),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('consultations')
          .orderBy('createdAt', descending: true).limit(20).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyState(icon: Icons.medical_services_outlined, title: 'No consultations yet');
        }
        return Column(children: docs.map((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final vitals = d['vitalSigns'] as Map<String, dynamic>? ?? {};
          final bp = vitals['bpSystolic'] != null ? '${(vitals['bpSystolic'] as num).toInt()}/${(vitals['bpDiastolic'] as num?)?.toInt() ?? 0}' : null;
          final created = (d['createdAt'] as Timestamp?)?.toDate();
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.medical_services_outlined, size: 20, color: AppColors.success),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d['patientName'] ?? 'Patient', style: AppTypography.titleSmall),
                Text(d['chiefComplaint'] ?? '', style: AppTypography.bodySmall),
                if (d['diagnosis'] != null && d['diagnosis'].toString().isNotEmpty)
                  Text('Dx: ${d['diagnosis']}', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (created != null) Text(AppDateUtils.shortDate(created), style: AppTypography.labelSmall),
                if (bp != null) Text('BP: $bp', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
              ]),
            ]),
          );
        }).toList());
      },
    );
  }
}
