import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/extensions.dart';
import '../../core/constants/app_constants.dart';

class AppointmentFormScreen extends StatefulWidget {
  final String? patientId;
  const AppointmentFormScreen({super.key, this.patientId});
  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '9:00 AM');
  String? _selectedPatientId;
  String? _selectedPatientName;
  AppointmentType _type = AppointmentType.general;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  bool _loading = false;

  // Patient search
  List<Map<String, dynamic>> _patients = [];

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
      if (_selectedPatientId != null) {
        final match = _patients.where((p) => p['id'] == _selectedPatientId);
        if (match.isNotEmpty) _selectedPatientName = match.first['name'];
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      context.showSnack('Please select a patient', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'patientId': _selectedPatientId,
        'patientName': _selectedPatientName,
        'date': Timestamp.fromDate(_date),
        'time': _timeCtrl.text.trim(),
        'type': _type.name,
        'status': 'scheduled',
        'notes': _notesCtrl.text.trim(),
        'createdBy': context.read<AuthService>().uid ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        context.showSnack('Appointment scheduled');
        context.go('/appointments');
      }
    } catch (e) {
      if (mounted) context.showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _notesCtrl.dispose(); _timeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/appointments'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8),
            Text('New Appointment', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Patient', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPatientId,
                  hint: const Text('Select patient'),
                  items: _patients.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedPatientId = v;
                      _selectedPatientName = _patients.firstWhere((p) => p['id'] == v)['name'] as String;
                    });
                  },
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Text('Appointment Type', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                DropdownButtonFormField<AppointmentType>(
                  initialValue: _type,
                  items: AppointmentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Date', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (d != null) setState(() => _date = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(),
                        child: Text('${_date.month}/${_date.day}/${_date.year}', style: AppTypography.bodyMedium),
                      ),
                    ),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Time', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    TextFormField(controller: _timeCtrl, validator: (v) => Validators.required(v, 'Time')),
                  ])),
                ]),
                const SizedBox(height: 16),
                Text('Notes (optional)', style: AppTypography.labelMedium),
                const SizedBox(height: 6),
                TextFormField(controller: _notesCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Additional notes...')),
                const SizedBox(height: 32),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(onPressed: () => context.go('/appointments'), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Schedule'),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
