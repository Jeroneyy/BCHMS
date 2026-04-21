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

class LabListScreen extends StatelessWidget {
  const LabListScreen({super.key});
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
              Expanded(child: Text('Laboratory', style: AppTypography.displaySmall)),
              ElevatedButton.icon(onPressed: () => context.go('/laboratory/new'), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New Request')),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('lab_requests').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) return const EmptyState(icon: Icons.science_outlined, title: 'No lab requests');
                return Column(children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final testType = LabTestType.values.firstWhere((t) => t.name == d['testType'], orElse: () => LabTestType.other);
                  final status = LabStatus.values.firstWhere((s) => s.name == d['status'], orElse: () => LabStatus.pending);
                  final reqDate = (d['requestDate'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(
                        color: AppColors.infoLight, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.science_rounded, size: 20, color: AppColors.info)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d['patientName'] ?? 'Patient', style: AppTypography.titleSmall),
                        Text(testType.label, style: AppTypography.bodySmall),
                        if (d['results'] != null && d['results'].toString().isNotEmpty)
                          Text('Result: ${d['results']}', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        _statusBadge(status),
                        if (reqDate != null) ...[const SizedBox(height: 4), Text(AppDateUtils.shortDate(reqDate), style: AppTypography.labelSmall)],
                      ]),
                      const SizedBox(width: 8),
                      if (status != LabStatus.completed)
                        PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (_) => [
                            if (status == LabStatus.pending) const PopupMenuItem(value: 'processing', child: Text('Mark Processing')),
                            const PopupMenuItem(value: 'complete', child: Text('Enter Result')),
                            const PopupMenuItem(value: 'cancel', child: Text('Cancel', style: TextStyle(color: AppColors.error))),
                          ],
                          onSelected: (v) => _handleAction(context, v, doc.id),
                          child: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textTertiary),
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

  Widget _statusBadge(LabStatus s) {
    switch (s) {
      case LabStatus.pending: return StatusBadge.pending();
      case LabStatus.processing: return StatusBadge.custom('Processing', AppColors.info, AppColors.infoLight);
      case LabStatus.completed: return StatusBadge.completed();
      case LabStatus.cancelled: return StatusBadge.cancelled();
    }
  }

  void _handleAction(BuildContext context, String action, String docId) async {
    final ref = FirebaseFirestore.instance.collection('lab_requests').doc(docId);
    if (action == 'processing') await ref.update({'status': 'processing'});
    if (action == 'cancel') await ref.update({'status': 'cancelled'});
    if (action == 'complete') {
      final resultCtrl = TextEditingController();
      if (!context.mounted) return;
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter Lab Result'),
          content: TextField(controller: resultCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Type result here...')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, resultCtrl.text), child: const Text('Save')),
          ],
        ),
      );
      if (result != null && result.isNotEmpty) {
        await ref.update({'status': 'completed', 'results': result, 'resultDate': FieldValue.serverTimestamp()});
      }
    }
  }
}
