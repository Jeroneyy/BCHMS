import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../models/appointment_model.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});
  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Appointments', style: AppTypography.displaySmall)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/appointments/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New Appointment'),
                ),
              ]),
              const SizedBox(height: 20),
              SearchField(
                hint: 'Search by patient name...',
                width: isWide ? 400 : double.infinity,
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
              ),
              const SizedBox(height: 20),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('appointments')
                  .orderBy('date', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(64), child: CircularProgressIndicator(strokeWidth: 2)));
                }
                var docs = snap.data?.docs ?? [];
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['patientName'] ?? '').toString().toLowerCase().contains(_search);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No appointments',
                    subtitle: 'Schedule your first appointment',
                    action: ElevatedButton(onPressed: () => context.go('/appointments/new'), child: const Text('New Appointment')),
                  );
                }
                return _buildList(docs);
              },
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot> docs) {
    return Column(
      children: docs.map((doc) {
        final appt = AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(appt.date.day.toString(), style: AppTypography.titleSmall.copyWith(color: AppColors.primary)),
                        Text(AppDateUtils.dayMonth(appt.date).split(' ')[0], style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 9)),
                      ]),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(appt.patientName ?? 'Patient', style: AppTypography.titleSmall),
                      const SizedBox(height: 2),
                      Text('${appt.type.label} · ${appt.time}', style: AppTypography.bodySmall),
                    ])),
                    _statusBadge(appt.status),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'complete', child: Text('Mark Completed')),
                        const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                      ],
                      onSelected: (v) => _handleAction(v, doc.id, appt),
                      child: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusBadge(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.scheduled: return StatusBadge.scheduled();
      case AppointmentStatus.completed: return StatusBadge.completed();
      case AppointmentStatus.cancelled: return StatusBadge.cancelled();
      case AppointmentStatus.inProgress: return StatusBadge.custom('In Progress', AppColors.info, AppColors.infoLight);
      case AppointmentStatus.noShow: return StatusBadge.custom('No Show', AppColors.warning, AppColors.warningLight);
    }
  }

  void _handleAction(String action, String docId, AppointmentModel appt) async {
    final ref = FirebaseFirestore.instance.collection('appointments').doc(docId);
    if (action == 'complete') await ref.update({'status': 'completed'});
    if (action == 'cancel') await ref.update({'status': 'cancelled'});
    if (action == 'delete') await ref.delete();
  }
}
