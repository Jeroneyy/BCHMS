import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/extensions.dart';
import '../../models/patient_model.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('patients').doc(patientId).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Patient not found'));
          }
          final patient = PatientModel.fromMap(snap.data!.data() as Map<String, dynamic>, snap.data!.id);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, patient, isWide)),
              SliverToBoxAdapter(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                child: isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 3, child: _buildInfoCard(patient)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildActionsCard(context, patient)),
                      ])
                    : Column(children: [
                        _buildInfoCard(patient),
                        const SizedBox(height: 20),
                        _buildActionsCard(context, patient),
                      ]),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
                child: _buildRecordsSection(context),
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PatientModel p, bool isWide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/patients'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(p.fullName.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.fullName, style: AppTypography.headlineLarge),
                Text('${p.sex.label} · ${p.age} years old · ${p.civilStatus.label}',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('/patients/${p.id}/edit'),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(PatientModel p) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Information', style: AppTypography.titleLarge),
          const SizedBox(height: 20),
          _infoRow('Full Name', p.fullName),
          _infoRow('Date of Birth', AppDateUtils.fullDate(p.birthDate)),
          _infoRow('Sex', p.sex.label),
          _infoRow('Civil Status', p.civilStatus.label),
          _infoRow('Blood Type', p.bloodType.label),
          _infoRow('Address', p.address),
          _infoRow('Contact', p.contactNumber ?? '—'),
          _infoRow('PhilHealth ID', p.philhealthId ?? '—'),
          _infoRow('Occupation', p.occupation ?? '—'),
          const Divider(height: 24),
          Text('Emergency Contact', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          _infoRow('Name', p.emergencyContactName ?? '—'),
          _infoRow('Phone', p.emergencyContactPhone ?? '—'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTypography.labelMedium),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, PatientModel p) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          _serviceAction(context, Icons.calendar_today_outlined, 'Schedule Appointment',
              '/appointments/new?patientId=${p.id}'),
          _serviceAction(context, Icons.pregnant_woman_outlined, 'Prenatal Visit',
              '/maternal/new?patientId=${p.id}'),
          _serviceAction(context, Icons.vaccines_outlined, 'Record Immunization',
              '/immunization/new?patientId=${p.id}'),
          _serviceAction(context, Icons.family_restroom_outlined, 'Family Planning',
              '/family-planning/new?patientId=${p.id}'),
          _serviceAction(context, Icons.monitor_weight_outlined, 'Nutrition Assessment',
              '/nutrition/new?patientId=${p.id}'),
          _serviceAction(context, Icons.health_and_safety_outlined, 'Dental Record',
              '/dental/new?patientId=${p.id}'),
          _serviceAction(context, Icons.science_outlined, 'Lab Request',
              '/laboratory/new?patientId=${p.id}'),
          _serviceAction(context, Icons.local_pharmacy_outlined, 'Dispense Medicine',
              '/pharmacy/dispense'),
        ],
      ),
    );
  }

  Widget _serviceAction(BuildContext ctx, IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => ctx.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTypography.bodyMedium)),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsSection(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Consultations', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('consultations')
                .where('patientId', isEqualTo: patientId)
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No consultations recorded yet', style: AppTypography.bodySmall),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final complaint = data['chiefComplaint'] ?? '';
                  final diagnosis = data['diagnosis'] ?? '';
                  final created = (data['createdAt'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(complaint, style: AppTypography.titleSmall),
                              if (diagnosis.isNotEmpty)
                                Text('Dx: $diagnosis', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        if (created != null)
                          Text(AppDateUtils.shortDate(created), style: AppTypography.labelSmall),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
