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
import '../../models/patient_model.dart';

class PatientFormScreen extends StatefulWidget {
  final String? patientId;
  const PatientFormScreen({super.key, this.patientId});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _philhealthCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _emergNameCtrl = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();

  DateTime _birthDate = DateTime(2000, 1, 1);
  Sex _sex = Sex.male;
  BloodType _bloodType = BloodType.unknown;
  CivilStatus _civilStatus = CivilStatus.single;
  bool _loading = false;
  bool get _isEditing => widget.patientId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadPatient();
  }

  Future<void> _loadPatient() async {
    final doc = await FirebaseFirestore.instance.collection('patients').doc(widget.patientId).get();
    if (doc.exists && mounted) {
      final p = PatientModel.fromMap(doc.data()!, doc.id);
      setState(() {
        _firstNameCtrl.text = p.firstName;
        _lastNameCtrl.text = p.lastName;
        _middleNameCtrl.text = p.middleName ?? '';
        _addressCtrl.text = p.address;
        _contactCtrl.text = p.contactNumber ?? '';
        _philhealthCtrl.text = p.philhealthId ?? '';
        _occupationCtrl.text = p.occupation ?? '';
        _emergNameCtrl.text = p.emergencyContactName ?? '';
        _emergPhoneCtrl.text = p.emergencyContactPhone ?? '';
        _birthDate = p.birthDate;
        _sex = p.sex;
        _bloodType = p.bloodType;
        _civilStatus = p.civilStatus;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final uid = context.read<AuthService>().uid ?? '';
    final patient = PatientModel(
      id: widget.patientId ?? '',
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      middleName: _middleNameCtrl.text.trim().isNotEmpty ? _middleNameCtrl.text.trim() : null,
      birthDate: _birthDate,
      sex: _sex,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim().isNotEmpty ? _contactCtrl.text.trim() : null,
      philhealthId: _philhealthCtrl.text.trim().isNotEmpty ? _philhealthCtrl.text.trim() : null,
      bloodType: _bloodType,
      civilStatus: _civilStatus,
      occupation: _occupationCtrl.text.trim().isNotEmpty ? _occupationCtrl.text.trim() : null,
      emergencyContactName: _emergNameCtrl.text.trim().isNotEmpty ? _emergNameCtrl.text.trim() : null,
      emergencyContactPhone: _emergPhoneCtrl.text.trim().isNotEmpty ? _emergPhoneCtrl.text.trim() : null,
      createdBy: uid,
    );
    try {
      if (_isEditing) {
        await FirebaseFirestore.instance.collection('patients').doc(widget.patientId).update(patient.toMap());
      } else {
        await FirebaseFirestore.instance.collection('patients').add(patient.toMap());
      }
      if (mounted) {
        context.showSnack(_isEditing ? 'Patient updated' : 'Patient added');
        context.go('/patients');
      }
    } catch (e) {
      if (mounted) context.showSnack('Error: $e', isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose(); _middleNameCtrl.dispose();
    _addressCtrl.dispose(); _contactCtrl.dispose(); _philhealthCtrl.dispose();
    _occupationCtrl.dispose(); _emergNameCtrl.dispose(); _emergPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
              child: Row(
                children: [
                  IconButton(onPressed: () => context.go('/patients'), icon: const Icon(Icons.arrow_back_rounded)),
                  const SizedBox(width: 8),
                  Text(_isEditing ? 'Edit Patient' : 'New Patient', style: AppTypography.displaySmall),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isWide ? 32 : 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: AppTypography.titleLarge),
                      const SizedBox(height: 20),
                      _buildRow([
                        _field('First Name', _firstNameCtrl, validator: (v) => Validators.required(v, 'First name')),
                        _field('Middle Name', _middleNameCtrl),
                        _field('Last Name', _lastNameCtrl, validator: (v) => Validators.required(v, 'Last name')),
                      ], isWide),
                      const SizedBox(height: 16),
                      _buildRow([
                        _dateField('Date of Birth'),
                        _dropdown<Sex>('Sex', Sex.values, _sex, (v) => setState(() => _sex = v!)),
                        _dropdown<CivilStatus>('Civil Status', CivilStatus.values, _civilStatus, (v) => setState(() => _civilStatus = v!)),
                      ], isWide),
                      const SizedBox(height: 16),
                      _buildRow([
                        _dropdown<BloodType>('Blood Type', BloodType.values, _bloodType, (v) => setState(() => _bloodType = v!)),
                        _field('Occupation', _occupationCtrl),
                      ], isWide),
                      const Divider(height: 40),
                      Text('Contact Information', style: AppTypography.titleLarge),
                      const SizedBox(height: 20),
                      _buildRow([
                        _field('Address', _addressCtrl, validator: (v) => Validators.required(v, 'Address')),
                      ], isWide),
                      const SizedBox(height: 16),
                      _buildRow([
                        _field('Contact Number', _contactCtrl),
                        _field('PhilHealth ID', _philhealthCtrl),
                      ], isWide),
                      const Divider(height: 40),
                      Text('Emergency Contact', style: AppTypography.titleLarge),
                      const SizedBox(height: 20),
                      _buildRow([
                        _field('Contact Person', _emergNameCtrl),
                        _field('Contact Phone', _emergPhoneCtrl),
                      ], isWide),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/patients'), child: const Text('Cancel')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _loading ? null : _save,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(_isEditing ? 'Update' : 'Save Patient'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children, bool isWide) {
    if (!isWide) return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
    return Row(children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList());
  }

  Widget _field(String label, TextEditingController ctrl, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        TextFormField(controller: ctrl, validator: validator, style: AppTypography.bodyMedium),
      ],
    );
  }

  Widget _dateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthDate,
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _birthDate = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Text('${_birthDate.month}/${_birthDate.day}/${_birthDate.year}', style: AppTypography.bodyMedium),
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T extends Enum>(String label, List<T> values, T current, ValueChanged<T?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: current,
          items: values.map((v) => DropdownMenuItem(value: v, child: Text((v as dynamic).label))).toList(),
          onChanged: onChanged,
          style: AppTypography.bodyMedium,
        ),
      ],
    );
  }
}
