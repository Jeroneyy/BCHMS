import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    final auth = context.watch<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
            child: Text('Administration', style: AppTypography.displaySmall),
          )),
          // Current user card
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(auth.currentUser?.name.initials ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.currentUser?.name ?? 'User', style: AppTypography.headlineSmall),
                  Text('${auth.currentUser?.email ?? ''} · ${auth.currentUser?.role.label ?? ''}',
                    style: AppTypography.bodySmall),
                ])),
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showConfirmDialog(context, title: 'Sign Out', message: 'Are you sure you want to sign out?');
                    if (confirm) auth.signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                ),
              ]),
            ),
          )),
          // User management
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('System Users', style: AppTypography.titleLarge),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(strokeWidth: 2)));
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No registered users', style: AppTypography.bodySmall),
                      );
                    }
                    return Column(children: docs.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final role = UserRole.values.firstWhere((r) => r.name == d['role'], orElse: () => UserRole.viewer);
                      final isActive = d['isActive'] ?? true;
                      final created = (d['createdAt'] as Timestamp?)?.toDate();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text((d['name'] ?? 'U').toString().initials,
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d['name'] ?? '', style: AppTypography.titleSmall),
                            Text(d['email'] ?? '', style: AppTypography.bodySmall),
                          ])),
                          StatusBadge.custom(role.label, AppColors.primary, AppColors.primarySurface),
                          const SizedBox(width: 8),
                          isActive ? StatusBadge.active() : StatusBadge.inactive(),
                          const SizedBox(width: 8),
                          if (created != null) Text(AppDateUtils.shortDate(created), style: AppTypography.labelSmall),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            itemBuilder: (_) => [
                              PopupMenuItem(value: isActive ? 'deactivate' : 'activate',
                                child: Text(isActive ? 'Deactivate' : 'Activate')),
                            ],
                            onSelected: (v) async {
                              await FirebaseFirestore.instance.collection('users').doc(doc.id).update({
                                'isActive': v == 'activate',
                              });
                            },
                            child: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textTertiary),
                          ),
                        ]),
                      );
                    }).toList());
                  },
                ),
              ]),
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          // System info
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('System Information', style: AppTypography.titleLarge),
                const SizedBox(height: 16),
                _infoRow('Application', 'BCHMS v1.0.0'),
                _infoRow('Barangay', 'Cabad'),
                _infoRow('Platform', 'Flutter + Firebase'),
                _infoRow('Firebase Project', 'bchms-216c5'),
              ]),
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 140, child: Text(label, style: AppTypography.labelMedium)),
        Text(value, style: AppTypography.bodyMedium),
      ]),
    );
  }
}
