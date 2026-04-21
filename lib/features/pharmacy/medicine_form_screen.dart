import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class MedicineFormScreen extends StatefulWidget {
  const MedicineFormScreen({super.key});
  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _reorderCtrl = TextEditingController(text: '10');
  final _batchCtrl = TextEditingController();
  MedicineCategory _category = MedicineCategory.other;
  MedicineUnit _unit = MedicineUnit.tablet;
  DateTime? _expiry;
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('medicines').add({
        'name': _nameCtrl.text.trim(), 'genericName': _genericCtrl.text.trim(),
        'category': _category.name, 'unit': _unit.name,
        'currentStock': int.tryParse(_stockCtrl.text) ?? 0,
        'reorderLevel': int.tryParse(_reorderCtrl.text) ?? 10,
        'expiryDate': _expiry != null ? Timestamp.fromDate(_expiry!) : null,
        'batchNumber': _batchCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { context.showSnack('Medicine added'); context.go('/pharmacy'); }
    } catch (e) { if (mounted) context.showSnack('Error: $e', isError: true); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _genericCtrl.dispose(); _stockCtrl.dispose(); _reorderCtrl.dispose(); _batchCtrl.dispose(); super.dispose(); }

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
            const SizedBox(width: 8), Text('Add Medicine', style: AppTypography.displaySmall),
          ]),
          const SizedBox(height: 24),
          Container(
            constraints: const BoxConstraints(maxWidth: 700), padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: _field('Brand Name', _nameCtrl, required: true)),
                const SizedBox(width: 16),
                Expanded(child: _field('Generic Name', _genericCtrl)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Category', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  DropdownButtonFormField<MedicineCategory>(initialValue: _category,
                    items: MedicineCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                    onChanged: (v) => setState(() => _category = v!)),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Unit', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  DropdownButtonFormField<MedicineUnit>(initialValue: _unit,
                    items: MedicineUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.label))).toList(),
                    onChanged: (v) => setState(() => _unit = v!)),
                ])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _field('Current Stock', _stockCtrl, isNum: true)),
                const SizedBox(width: 16),
                Expanded(child: _field('Reorder Level', _reorderCtrl, isNum: true)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _field('Batch Number', _batchCtrl)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Expiry Date', style: AppTypography.labelMedium), const SizedBox(height: 6),
                  InkWell(onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _expiry ?? DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(), lastDate: DateTime(2035));
                    if (d != null) setState(() => _expiry = d);
                  }, child: InputDecorator(decoration: const InputDecoration(),
                    child: Text(_expiry != null ? AppDateUtils.shortDate(_expiry!) : 'Select date'))),
                ])),
              ]),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(onPressed: () => context.go('/pharmacy'), child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _save,
                  child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add Medicine')),
              ]),
            ])),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool required = false, bool isNum = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelMedium), const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: isNum ? TextInputType.number : null,
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null),
    ]);
  }
}
