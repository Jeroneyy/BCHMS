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

class FPFormScreen extends StatefulWidget {
  final String? patientId;
  const FPFormScreen({super.key, this.patientId});
  @override
  State<FPFormScreen> createState() => _FPFormScreenState();
}

class _FPFormScreenState extends State<FPFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  List<Map<String, dynamic>> _patients = [];
  FPMethod _method = FPMethod.pills;
  final FPStatus _status = FPStatus.active;
  DateTime _dateStarted = DateTime.now();
  DateTime? _nextVisit;
  final _sideEffectsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final snap = await FirebaseFirestore.instance.collection('patients').where('sex', isEqualTo: 'female').orderBy('lastName').get();
    setState(() {
      _patients = snap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'}; }).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('family_planning').add({
        'patientId': _selectedPatientId, 'method': _method.name, 'status': _status.name,
        'dateStarted': Timestamp.fromDate(_dateStarted),
        'nextVisit': _nextVisit != null ? Timestamp.fromDate(_nextVisit!) : null,
        'sideEffects': _sideEffectsCtrl.text.trim(), 'notes': _notesCtrl.text.trim(),
        'provider': context.read<AuthService>().currentUser?.name ?? '',
        'createdBy': context.read<AuthService>().uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Record saved'); context.go('/family-planning'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _sideEffectsCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/family-planning'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8), Text('New Family Planning Record', style: AppTypography.displaySmall),
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
              Text('Method', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<FPMethod>(initialValue: _method,
                items: FPMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.label))).toList(),
                onChanged: (v) => setState(() => _method = v!)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Date Started', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  InkWell(onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _dateStarted, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (d != null) setState(() => _dateStarted = d);
                  }, child: InputDecorator(decoration: const InputDecoration(), child: Text(AppDateUtils.shortDate(_dateStarted)))),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Next Visit', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  InkWell(onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _nextVisit ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setState(() => _nextVisit = d);
                  }, child: InputDecorator(decoration: const InputDecoration(), child: Text(_nextVisit != null ? AppDateUtils.shortDate(_nextVisit!) : 'Optional'))),
                ])),
              ]),
              const SizedBox(height: 16),
              Text('Side Effects', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _sideEffectsCtrl, maxLines: 2),
              const SizedBox(height: 16),
              Text('Notes', style: AppTypography.labelMedium), const SizedBox(height: 6),
              TextFormField(controller: _notesCtrl, maxLines: 2),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/family-planning'), child: const Text('Cancel')),
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
