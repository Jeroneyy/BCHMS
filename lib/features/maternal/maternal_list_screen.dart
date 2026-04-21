import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class MaternalListScreen extends StatelessWidget {
  const MaternalListScreen({super.key});

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
              Expanded(child: Text('Maternal Care', style: AppTypography.displaySmall)),
              ElevatedButton.icon(
                onPressed: () => context.go('/maternal/new'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Prenatal Visit'),
              ),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('maternal_records')
                  .orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const EmptyState(icon: Icons.pregnant_woman_outlined, title: 'No maternal records', subtitle: 'Record your first prenatal visit');
                }
                return Column(children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final lmp = (d['lmp'] as Timestamp?)?.toDate();
                  final edd = (d['edd'] as Timestamp?)?.toDate();
                  final status = MaternalStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => MaternalStatus.prenatal);
                  final aog = lmp != null ? DateTime.now().difference(lmp).inDays ~/ 7 : 0;
                  final trimester = aog <= 12 ? 1 : aog <= 27 ? 2 : 3;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.pregnant_woman_rounded, size: 22, color: Color(0xFFE91E63)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('patients').doc(d['patientId']).get(),
                            builder: (ctx, pSnap) {
                              final pData = pSnap.data?.data() as Map<String, dynamic>?;
                              return Text(pData != null ? '${pData['firstName']} ${pData['lastName']}' : 'Patient',
                                  style: AppTypography.titleSmall);
                            },
                          ),
                          Text('G${d['gravida'] ?? 1}P${d['para'] ?? 0} · Visit #${d['visitNumber'] ?? 1}', style: AppTypography.bodySmall),
                        ])),
                        StatusBadge.custom(
                          status.label,
                          status == MaternalStatus.prenatal ? AppColors.info : AppColors.success,
                          status == MaternalStatus.prenatal ? AppColors.infoLight : AppColors.successLight,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      // Progress bar for pregnancy
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          _infoChip('AOG', '$aog wks'),
                          const SizedBox(width: 16),
                          _infoChip('Trimester', '$trimester'),
                          const SizedBox(width: 16),
                          if (edd != null) _infoChip('EDD', AppDateUtils.shortDate(edd)),
                          const Spacer(),
                          if (d['bloodPressure'] != null) _infoChip('BP', d['bloodPressure']),
                        ]),
                      ),
                    ]),
                  );
                }).toList());
              },
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelSmall),
      Text(value, style: AppTypography.titleSmall.copyWith(fontSize: 13)),
    ]);
  }
}
