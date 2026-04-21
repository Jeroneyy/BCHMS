import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';

class DispensingScreen extends StatefulWidget {
  const DispensingScreen({super.key});
  @override
  State<DispensingScreen> createState() => _DispensingScreenState();
}

class _DispensingScreenState extends State<DispensingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  String? _selectedMedicineId;
  String? _selectedMedicineName;
  int _medicineStock = 0;
  final _qtyCtrl = TextEditingController(text: '1');
  final _purposeCtrl = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _medicines = [];
  bool _loading = false;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final pSnap = await FirebaseFirestore.instance.collection('patients').orderBy('lastName').get();
    final mSnap = await FirebaseFirestore.instance.collection('medicines').orderBy('name').get();
    setState(() {
      _patients = pSnap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': '${data['firstName']} ${data['lastName']}'}; }).toList();
      _medicines = mSnap.docs.map((d) { final data = d.data(); return {'id': d.id, 'name': data['name'] ?? '', 'stock': data['currentStock'] ?? 0}; }).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null || _selectedMedicineId == null) return;
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty > _medicineStock) { context.showSnack('Insufficient stock!', isError: true); return; }
    setState(() => _loading = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(FirebaseFirestore.instance.collection('dispensing_records').doc(), {
        'patientId': _selectedPatientId, 'medicineId': _selectedMedicineId,
        'medicineName': _selectedMedicineName, 'quantity': qty,
        'purpose': _purposeCtrl.text.trim(),
        'dispensedBy': context.read<AuthService>().currentUser?.name ?? '',
        'dispensedAt': FieldValue.serverTimestamp(),
      });
      batch.update(FirebaseFirestore.instance.collection('medicines').doc(_selectedMedicineId!), {
        'currentStock': FieldValue.increment(-qty),
      });
      await batch.commit();
      if (mounted) { context.showSnack('Medicine dispensed'); context.go('/pharmacy'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _qtyCtrl.dispose(); _purposeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 32 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => context.go('/pharmacy'), icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 8), Text('Dispense Medicine', style: AppTypography.displaySmall),
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
              Text('Medicine', style: AppTypography.labelMedium), const SizedBox(height: 6),
              DropdownButtonFormField<String>(initialValue: _selectedMedicineId, hint: const Text('Select medicine'),
                items: _medicines.map((m) => DropdownMenuItem(value: m['id'] as String,
                  child: Text('${m['name']} (Stock: ${m['stock']})'))).toList(),
                onChanged: (v) => setState(() {
                  _selectedMedicineId = v;
                  final med = _medicines.firstWhere((m) => m['id'] == v);
                  _selectedMedicineName = med['name'] as String;
                  _medicineStock = med['stock'] as int;
                }), validator: (v) => v == null ? 'Required' : null),
              const SizedBox(height: 16),
              if (_selectedMedicineId != null)
                Container(
                  padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: _medicineStock <= 10 ? AppColors.warningLight : AppColors.successLight,
                    borderRadius: BorderRadius.circular(10)),
                  child: Text('Available stock: $_medicineStock',
                    style: AppTypography.titleSmall.copyWith(color: _medicineStock <= 10 ? AppColors.warning : AppColors.success)),
                ),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Quantity', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  TextFormField(controller: _qtyCtrl, keyboardType: TextInputType.number,
                    validator: (v) { if (v == null || v.isEmpty) return 'Required'; if ((int.tryParse(v) ?? 0) <= 0) return 'Must be > 0'; return null; }),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Purpose', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  TextFormField(controller: _purposeCtrl, decoration: const InputDecoration(hintText: 'e.g., For headache')),
                ])),
              ]),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/pharmacy'), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Dispense')),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }
}
