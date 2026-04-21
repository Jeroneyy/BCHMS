import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';
import '../../core/constants/app_constants.dart';

class NutritionFormScreen extends StatefulWidget {
  final String? patientId;
  const NutritionFormScreen({super.key, this.patientId});
  @override
  State<NutritionFormScreen> createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageMonthsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  NutritionStatus _wfa = NutritionStatus.normal;
  NutritionStatus _hfa = NutritionStatus.normal;
  NutritionStatus _wfh = NutritionStatus.normal;
  String _feedingType = 'Breastfed';
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
      _patients = snap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'}; }).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('nutrition_records').add({
        'patientId': _selectedPatientId,
        'weight': double.tryParse(_weightCtrl.text) ?? 0,
        'height': double.tryParse(_heightCtrl.text) ?? 0,
        'ageMonths': int.tryParse(_ageMonthsCtrl.text) ?? 0,
        'weightForAge': _wfa.name, 'heightForAge': _hfa.name, 'weightForHeight': _wfh.name,
        'feedingType': _feedingType, 'notes': _notesCtrl.text.trim(),
        'dateRecorded': FieldValue.serverTimestamp(),
        'createdBy': context.read<AuthService>().uid ?? '',
      });
      if (mounted) { context.showSnack('Assessment saved'); context.go('/nutrition'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _weightCtrl.dispose(); _heightCtrl.dispose(); _ageMonthsCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/nutrition'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8), Text('Nutrition Assessment', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700), padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Patient', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _selectedPatientId, hint: const Text('Select child'),
                items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                onChanged: (v) => setState(() => _selectedPatientId = v), validator: (v) => v == null ? 'Required' : null),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _field('Weight (kg)', _weightCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Height (cm)', _heightCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _field('Age (months)', _ageMonthsCtrl)),
              ]),
              const SizedBox(height: 16),
              Text('Feeding Type', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _feedingType,
                items: ['Breastfed', 'Formula', 'Mixed', 'Complementary'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => _feedingType = v!)),
              const Divider(height: 32),
              Text('Nutritional Status Assessment', style: AppTypography.titleMedium), const SizedBox(height: 12),
              _statusDropdown('Weight for Age', _wfa, (v) => setState(() => _wfa = v!)),
              const SizedBox(height: 12),
              _statusDropdown('Height for Age', _hfa, (v) => setState(() => _hfa = v!)),
              const SizedBox(height: 12),
              _statusDropdown('Weight for Height', _wfh, (v) => setState(() => _wfh = v!)),
              const SizedBox(height: 16),
              Text('Notes', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _notesCtrl, maxLines: 2),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/nutrition'), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Assessment')),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelMedium), const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
    ]);
  }

  Widget _statusDropdown(String label, NutritionStatus current, ValueChanged<NutritionStatus?> onChanged) {
    return Row(children: [
      SizedBox(width: 140, child: Text(label, style: AppTypography.labelMedium)),
      Expanded(child: DropdownButtonFormField<NutritionStatus>(initialValue: current,
        items: NutritionStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
        onChanged: onChanged)),
    ]);
  }
}
