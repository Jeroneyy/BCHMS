import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/glass_card.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/extensions.dart';
import '../../models/appointment_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final isWide = context.screenWidth >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getGreeting()}, ${user?.name.split(' ').first ?? 'User'}',
                          style: AppTypography.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.fullDate(DateTime.now()),
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // User avatar + logout
                  PopupMenuButton(
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => context.go('/admin'),
                        child: const Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => auth.signOut(),
                        child: const Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Sign Out', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          user?.name.initials ?? 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── KPI Cards ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              child: _buildKPIGrid(isWide),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Main Content Grid ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildUpcomingAppointments()),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildQuickActions()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildUpcomingAppointments(),
                        const SizedBox(height: 20),
                        _buildQuickActions(),
                      ],
                    ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Recent Activity ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              child: _buildRecentPatients(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildKPIGrid(bool isWide) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('patients').snapshots(),
      builder: (context, patientSnap) {
        final patientCount = patientSnap.data?.docs.length ?? 0;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('appointments')
              .where('status', isEqualTo: 'scheduled').snapshots(),
          builder: (context, apptSnap) {
            final apptCount = apptSnap.data?.docs.length ?? 0;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('medicines')
                  .where('currentStock', isLessThanOrEqualTo: 10).snapshots(),
              builder: (context, medSnap) {
                final lowStock = medSnap.data?.docs.length ?? 0;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('consultations').snapshots(),
                  builder: (context, consulSnap) {
                    final consulCount = consulSnap.data?.docs.length ?? 0;
                    final cols = isWide ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: cols,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.7 : 1.5,
                      children: [
                        StatCard(
                          label: 'Total Patients',
                          value: '$patientCount',
                          icon: Icons.people_outline_rounded,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primarySurface,
                          onTap: () => context.go('/patients'),
                        ),
                        StatCard(
                          label: 'Pending Appointments',
                          value: '$apptCount',
                          icon: Icons.calendar_today_outlined,
                          iconColor: AppColors.info,
                          iconBgColor: AppColors.infoLight,
                          onTap: () => context.go('/appointments'),
                        ),
                        StatCard(
                          label: 'Consultations',
                          value: '$consulCount',
                          icon: Icons.medical_services_outlined,
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successLight,
                          onTap: () => context.go('/consultations'),
                        ),
                        StatCard(
                          label: 'Low Stock Medicines',
                          value: '$lowStock',
                          icon: Icons.local_pharmacy_outlined,
                          iconColor: lowStock > 0 ? AppColors.warning : AppColors.textTertiary,
                          iconBgColor: lowStock > 0 ? AppColors.warningLight : AppColors.surfaceAlt,
                          onTap: () => context.go('/pharmacy'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Upcoming Appointments', style: AppTypography.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/appointments'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('status', isEqualTo: 'scheduled')
                .orderBy('date')
                .limit(5)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('No upcoming appointments',
                        style: AppTypography.bodySmall),
                  ),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final appt = AppointmentModel.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appt.patientName ?? 'Patient',
                                  style: AppTypography.titleSmall),
                              Text('${appt.type.label} · ${appt.time}',
                                  style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        Text(AppDateUtils.dayMonth(appt.date),
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
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

  Widget _buildQuickActions() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          _quickAction(Icons.person_add_outlined, 'New Patient', '/patients/new'),
          _quickAction(Icons.calendar_today_outlined, 'Schedule Appointment', '/appointments/new'),
          _quickAction(Icons.medical_services_outlined, 'New Consultation', '/consultations'),
          _quickAction(Icons.vaccines_outlined, 'Record Immunization', '/immunization/new'),
          _quickAction(Icons.pregnant_woman_outlined, 'Prenatal Visit', '/maternal/new'),
          _quickAction(Icons.local_pharmacy_outlined, 'Dispense Medicine', '/pharmacy/dispense'),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
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

  Widget _buildRecentPatients() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recently Added Patients', style: AppTypography.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/patients'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('patients')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('No patients yet', style: AppTypography.bodySmall)),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
                  final sex = data['sex'] == 'female' ? 'Female' : 'Male';
                  final created = (data['createdAt'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/patients/${doc.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    name.trim().isNotEmpty ? name.trim().initials : '?',
                                    style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name.trim(), style: AppTypography.titleSmall),
                                    Text(sex, style: AppTypography.bodySmall),
                                  ],
                                ),
                              ),
                              if (created != null)
                                Text(AppDateUtils.timeAgo(created),
                                    style: AppTypography.labelSmall),
                            ],
                          ),
                        ),
                      ),
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
