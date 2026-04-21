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

class FPListScreen extends StatelessWidget {
  const FPListScreen({super.key});
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
              Expanded(child: Text('Family Planning', style: AppTypography.displaySmall)),
              ElevatedButton.icon(onPressed: () => context.go('/family-planning/new'), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New Record')),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('family_planning').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.family_restroom_outlined, title: 'No family planning records');
                return Column(children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final method = FPMethod.values.firstWhere((m) => m.name == d['method'], orElse: () => FPMethod.pills);
                  final status = FPStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => FPStatus.active);
                  final nextVisit = (d['nextVisit'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.family_restroom_rounded, size: 20, color: Color(0xFF9C27B0))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('patients').doc(d['patientId']).get(),
                          builder: (ctx, pSnap) {
                            final pData = pSnap.data?.data() as Map<String, dynamic>?;
                            return Text(pData != null ? '${pData['firstName']} ${pData['lastName']}' : 'Patient', style: AppTypography.titleSmall);
                          },
                        ),
                        Text('Method: ${method.label}', style: AppTypography.bodySmall),
                        if (nextVisit != null) Text('Next visit: ${AppDateUtils.shortDate(nextVisit)}', style: AppTypography.labelSmall),
                      ])),
                      StatusBadge.custom(
                        status.label,
                        status == FPStatus.active ? AppColors.success : AppColors.textTertiary,
                        status == FPStatus.active ? AppColors.successLight : AppColors.surfaceAlt,
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
}
