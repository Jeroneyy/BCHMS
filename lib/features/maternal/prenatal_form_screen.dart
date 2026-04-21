import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';

import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class PrenatalFormScreen extends StatefulWidget {
  final String? patientId;
  const PrenatalFormScreen({super.key, this.patientId});
  @override
  State<PrenatalFormScreen> createState() => _PrenatalFormScreenState();
}

class _PrenatalFormScreenState extends State<PrenatalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];
  DateTime _lmp = DateTime.now().subtract(const Duration(days: 60));
  final _gravidaCtrl = TextEditingController(text: '1');
  final _paraCtrl = TextEditingController(text: '0');
  final _visitCtrl = TextEditingController(text: '1');
  final _fundalCtrl = TextEditingController();
  final _fhtCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _urinalysisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  MaternalStatus _status = MaternalStatus.prenatal;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final snap = await FirebaseFirestore.instance.collection('patients')
        .where('sex', isEqualTo: 'female').orderBy('lastName').get();
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
    setState(() => _loading = true);
    final edd = AppDateUtils.calculateEDD(_lmp);
    final aog = AppDateUtils.calculateAOG(_lmp);
    try {
      await FirebaseFirestore.instance.collection('maternal_records').add({
        'patientId': _selectedPatientId,
        'lmp': Timestamp.fromDate(_lmp),
        'edd': Timestamp.fromDate(edd),
        'gravida': int.tryParse(_gravidaCtrl.text) ?? 1,
        'para': int.tryParse(_paraCtrl.text) ?? 0,
        'visitNumber': int.tryParse(_visitCtrl.text) ?? 1,
        'aog': aog,
        'fundalHeight': double.tryParse(_fundalCtrl.text),
        'fetalHeartTone': _fhtCtrl.text.trim(),
        'bloodPressure': _bpCtrl.text.trim(),
        'weight': double.tryParse(_weightCtrl.text),
        'urinalysis': _urinalysisCtrl.text.trim(),
        'status': _status.name,
        'notes': _notesCtrl.text.trim(),
        'createdBy': context.read<AuthService>().uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Prenatal visit recorded'); context.go('/maternal'); }
    } catch (e) {
      if (mounted) context.showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _gravidaCtrl.dispose(); _paraCtrl.dispose(); _visitCtrl.dispose();
    _fundalCtrl.dispose(); _fhtCtrl.dispose(); _bpCtrl.dispose();
    _weightCtrl.dispose(); _urinalysisCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    final edd = AppDateUtils.calculateEDD(_lmp);
    final aog = AppDateUtils.calculateAOG(_lmp);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/maternal'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8),
            Text('New Prenatal Visit', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Patient', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPatientId,
                  hint: const Text('Select patient (female)'),
                  items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                ),
                const SizedBox(height: 16),
                // LMP + computed EDD/AOG
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Last Menstrual Period', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _lmp, firstDate: DateTime(2024), lastDate: DateTime.now());
                        if (d != null) setState(() => _lmp = d);
                      },
                      child: InputDecorator(decoration: const InputDecoration(), child: Text(AppDateUtils.shortDate(_lmp))),
                    ),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      Text('EDD: ${AppDateUtils.shortDate(edd)}', style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
                      Text('AOG: $aog weeks · Trimester ${AppDateUtils.getTrimester(_lmp)}', style: AppTypography.bodySmall),
                    ]),
                  )),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _numField('Gravida', _gravidaCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField('Para', _paraCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField('Visit #', _visitCtrl)),
                ]),
                const Divider(height: 32),
                Text('Clinical Findings', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  SizedBox(width: 160, child: TextFormField(controller: _bpCtrl, decoration: const InputDecoration(labelText: 'Blood Pressure'))),
                  SizedBox(width: 140, child: TextFormField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)'))),
                  SizedBox(width: 160, child: TextFormField(controller: _fundalCtrl, decoration: const InputDecoration(labelText: 'Fundal Height (cm)'))),
                  SizedBox(width: 160, child: TextFormField(controller: _fhtCtrl, decoration: const InputDecoration(labelText: 'Fetal Heart Tone'))),
                  SizedBox(width: 200, child: TextFormField(controller: _urinalysisCtrl, decoration: const InputDecoration(labelText: 'Urinalysis'))),
                ]),
                const SizedBox(height: 16),
                Text('Status', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<MaternalStatus>(
                  initialValue: _status,
                  items: MaternalStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),
                Text('Notes', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _notesCtrl, maxLines: 3),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(onPressed: () => context.go('/maternal'), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Visit'),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelMedium),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: TextInputType.number),
    ]);
  }
}
