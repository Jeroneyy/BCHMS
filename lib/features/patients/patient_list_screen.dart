import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/extensions.dart';

import '../../models/patient_model.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _search = '';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Patients', style: AppTypography.displaySmall)),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/patients/new'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Patient'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SearchField(
                    hint: 'Search patients by name...',
                    width: isWide ? 400 : double.infinity,
                    onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(64),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ));
                  }
                  var docs = snap.data?.docs ?? [];
                  if (_search.isNotEmpty) {
                    docs = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = '${data['firstName']} ${data['lastName']}'.toLowerCase();
                      return name.contains(_search);
                    }).toList();
                  }
                  if (docs.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline_rounded,
                      title: _search.isNotEmpty ? 'No patients found' : 'No patients yet',
                      subtitle: _search.isNotEmpty ? 'Try a different search term' : 'Add your first patient to get started',
                      action: _search.isEmpty ? ElevatedButton(
                        onPressed: () => context.go('/patients/new'),
                        child: const Text('Add Patient'),
                      ) : null,
                    );
                  }
                  return _buildTable(docs, isWide);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildTable(List<QueryDocumentSnapshot> docs, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
          headingTextStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
          dataTextStyle: AppTypography.bodyMedium,
          columnSpacing: 24,
          horizontalMargin: 20,
          columns: [
            const DataColumn(label: Text('Name')),
            if (isWide) const DataColumn(label: Text('Sex')),
            if (isWide) const DataColumn(label: Text('Age')),
            if (isWide) const DataColumn(label: Text('Address')),
            const DataColumn(label: Text('Contact')),
            const DataColumn(label: Text('')),
          ],
          rows: docs.map((doc) {
            final p = PatientModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            return DataRow(
              cells: [
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(p.fullName.initials,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
                    ),
                    const SizedBox(width: 10),
                    Text(p.fullName, style: AppTypography.titleSmall),
                  ],
                )),
                if (isWide) DataCell(Text(p.sex.label)),
                if (isWide) DataCell(Text('${p.age} yrs')),
                if (isWide) DataCell(Text(p.address, overflow: TextOverflow.ellipsis)),
                DataCell(Text(p.contactNumber ?? '—')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    onPressed: () => context.go('/patients/${p.id}'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
