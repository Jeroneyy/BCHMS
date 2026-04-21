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

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
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
                Expanded(child: Text('Pharmacy', style: AppTypography.displaySmall)),
                OutlinedButton.icon(onPressed: () => context.go('/pharmacy/dispense'), icon: const Icon(Icons.local_shipping_outlined, size: 16), label: const Text('Dispense')),
                const SizedBox(width: 10),
                ElevatedButton.icon(onPressed: () => context.go('/pharmacy/new'), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add Medicine')),
              ]),
              const SizedBox(height: 20),
              SearchField(hint: 'Search medicines...', width: isWide ? 400 : double.infinity,
                onChanged: (v) => setState(() => _search = v.toLowerCase())),
              const SizedBox(height: 20),
            ]),
          )),
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('medicines').orderBy('name').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator(strokeWidth: 2)));
                var docs = snap.data?.docs ?? [];
                if (_search.isNotEmpty) docs = docs.where((d) => ((d.data() as Map)['name'] ?? '').toString().toLowerCase().contains(_search)).toList();
                if (docs.isEmpty) {
                  return EmptyState(icon: Icons.local_pharmacy_outlined, title: 'No medicines',
                    action: ElevatedButton(onPressed: () => context.go('/pharmacy/new'), child: const Text('Add Medicine')));
                }
                return Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
                      headingTextStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                      dataTextStyle: AppTypography.bodyMedium,
                      columnSpacing: 20, horizontalMargin: 20,
                      columns: [
                        const DataColumn(label: Text('Medicine')),
                        if (isWide) const DataColumn(label: Text('Category')),
                        const DataColumn(label: Text('Stock'), numeric: true),
                        if (isWide) const DataColumn(label: Text('Unit')),
                        if (isWide) const DataColumn(label: Text('Expiry')),
                        const DataColumn(label: Text('Status')),
                      ],
                      rows: docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final stock = d['currentStock'] ?? 0;
                        final reorder = d['reorderLevel'] ?? 10;
                        final isLow = stock <= reorder;
                        final expiry = (d['expiryDate'] as Timestamp?)?.toDate();
                        final isExpired = expiry != null && expiry.isBefore(DateTime.now());
                        final category = MedicineCategory.values.firstWhere((c) => c.name == d['category'], orElse: () => MedicineCategory.other);
                        final unit = MedicineUnit.values.firstWhere((u) => u.name == d['unit'], orElse: () => MedicineUnit.tablet);
                        return DataRow(cells: [
                          DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(d['name'] ?? '', style: AppTypography.titleSmall),
                            if (d['genericName'] != null) Text(d['genericName'], style: AppTypography.labelSmall),
                          ])),
                          if (isWide) DataCell(Text(category.label)),
                          DataCell(Text('$stock', style: TextStyle(fontWeight: FontWeight.w600, color: isLow ? AppColors.error : AppColors.textPrimary))),
                          if (isWide) DataCell(Text(unit.label)),
                          if (isWide) DataCell(Text(expiry != null ? AppDateUtils.shortDate(expiry) : '—',
                            style: TextStyle(color: isExpired ? AppColors.error : null))),
                          DataCell(isExpired
                            ? StatusBadge.custom('Expired', AppColors.error, AppColors.errorLight)
                            : isLow
                              ? StatusBadge.custom('Low Stock', AppColors.warning, AppColors.warningLight)
                              : StatusBadge.custom('In Stock', AppColors.success, AppColors.successLight)),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
