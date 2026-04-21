import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';

class DentalListScreen extends StatelessWidget {
  const DentalListScreen({super.key});
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
              Expanded(child: Text('Dental Records', style: AppTypography.displaySmall)),
              ElevatedButton.icon(onPressed: () => context.go('/dental/new'), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New Record')),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('dental_records').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.health_and_safety_outlined, title: 'No dental records');
                return Column(children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final datePerformed = (d['datePerformed'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.health_and_safety_rounded, size: 20, color: Color(0xFF00897B))),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('patients').doc(d['patientId']).get(),
                          builder: (ctx, pSnap) {
                            final pData = pSnap.data?.data() as Map<String, dynamic>?;
                            return Text(pData != null ? '${pData['firstName']} ${pData['lastName']}' : 'Patient', style: AppTypography.titleSmall);
                          },
                        ),
                        Text(d['procedure'] ?? '', style: AppTypography.bodySmall),
                        if (d['teethAffected'] != null) Text('Teeth: ${d['teethAffected']}', style: AppTypography.labelSmall),
                      ])),
                      if (datePerformed != null) Text(AppDateUtils.shortDate(datePerformed), style: AppTypography.labelSmall),
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
