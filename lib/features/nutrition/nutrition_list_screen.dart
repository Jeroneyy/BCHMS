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

class NutritionListScreen extends StatelessWidget {
  const NutritionListScreen({super.key});
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
              Expanded(child: Text('Nutrition Monitoring', style: AppTypography.displaySmall)),
              ElevatedButton.icon(onPressed: () => context.go('/nutrition/new'), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New Assessment')),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('nutrition_records').orderBy('dateRecorded', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.monitor_weight_outlined, title: 'No nutrition records');
                return Column(children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final wfa = NutritionStatus.values.firstWhere((s) => s.name == d['weightForAge'], orElse: () => NutritionStatus.normal);
                  final dateRec = (d['dateRecorded'] as Timestamp?)?.toDate();
                  final isAlert = wfa == NutritionStatus.underweight || wfa == NutritionStatus.severelyUnderweight || wfa == NutritionStatus.wasted;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isAlert ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border.withValues(alpha: 0.5), width: isAlert ? 1 : 0.5)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(
                        color: isAlert ? AppColors.warningLight : AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.monitor_weight_rounded, size: 20, color: isAlert ? AppColors.warning : AppColors.success)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('patients').doc(d['patientId']).get(),
                          builder: (ctx, pSnap) {
                            final pData = pSnap.data?.data() as Map<String, dynamic>?;
                            return Text(pData != null ? '${pData['firstName']} ${pData['lastName']}' : 'Patient', style: AppTypography.titleSmall);
                          },
                        ),
                        Text('${d['ageMonths'] ?? 0} months · ${d['weight'] ?? 0} kg · ${d['height'] ?? 0} cm', style: AppTypography.bodySmall),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        StatusBadge.custom(wfa.label, isAlert ? AppColors.warning : AppColors.success, isAlert ? AppColors.warningLight : AppColors.successLight),
                        if (dateRec != null) ...[const SizedBox(height: 4), Text(AppDateUtils.shortDate(dateRec), style: AppTypography.labelSmall)],
                      ]),
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
}
