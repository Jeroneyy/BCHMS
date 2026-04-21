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

class ImmunizationFormScreen extends StatefulWidget {
  final String? patientId;
  const ImmunizationFormScreen({super.key, this.patientId});
  @override
  State<ImmunizationFormScreen> createState() => _ImmunizationFormScreenState();
}

class _ImmunizationFormScreenState extends State<ImmunizationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];
  VaccineType _vaccineType = VaccineType.bcg;
  final _doseCtrl = TextEditingController(text: '1');
  final _batchCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  DateTime _dateAdmin = DateTime.now();
  DateTime? _nextDue;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
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
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('immunization_records').add({
        'patientId': _selectedPatientId,
        'vaccineType': _vaccineType.name,
        'doseNumber': int.tryParse(_doseCtrl.text) ?? 1,
        'dateAdministered': Timestamp.fromDate(_dateAdmin),
        'nextDueDate': _nextDue != null ? Timestamp.fromDate(_nextDue!) : null,
        'batchNumber': _batchCtrl.text.trim(),
        'administeredBy': context.read<AuthService>().currentUser?.name ?? '',
        'remarks': _remarkCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Immunization recorded'); context.go('/immunization'); }
    } catch (e) {
      if (mounted) context.showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _doseCtrl.dispose(); _batchCtrl.dispose(); _remarkCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/immunization'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8),
            Text('Record Immunization', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Patient', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPatientId,
                  hint: const Text('Select patient'),
                  items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                  onChanged: (v) => setState(() => _selectedPatientId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Text('Vaccine', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<VaccineType>(
                  initialValue: _vaccineType,
                  items: VaccineType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(),
                  onChanged: (v) => setState(() => _vaccineType = v!),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Dose Number', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(controller: _doseCtrl, keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Batch Number', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(controller: _batchCtrl),
                  ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Date Administered', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _dateAdmin, firstDate: DateTime(2020), lastDate: DateTime.now());
                        if (d != null) setState(() => _dateAdmin = d);
                      },
                      child: InputDecorator(decoration: const InputDecoration(), child: Text(AppDateUtils.shortDate(_dateAdmin))),
                    ),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Next Due Date', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _nextDue ?? DateTime.now().add(const Duration(days: 28)),
                            firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)));
                        if (d != null) setState(() => _nextDue = d);
                      },
                      child: InputDecorator(decoration: const InputDecoration(),
                          child: Text(_nextDue != null ? AppDateUtils.shortDate(_nextDue!) : 'Optional')),
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),
                Text('Remarks', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _remarkCtrl, maxLines: 2),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(onPressed: () => context.go('/immunization'), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _loading ? null : _save,
                    child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Record')),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
