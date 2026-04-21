import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/utils/extensions.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _patients = 0, _appointments = 0, _consultations = 0;
  int _maternal = 0, _immunization = 0, _fp = 0, _nutrition = 0, _dental = 0;
  int _labPending = 0, _labCompleted = 0;
  int _maleCount = 0, _femaleCount = 0;

  @override
  void initState() { super.initState(); _loadCounts(); }

  Future<void> _loadCounts() async {
    final db = FirebaseFirestore.instance;
    final results = await Future.wait([
      db.collection('patients').count().get(),
      db.collection('appointments').count().get(),
      db.collection('consultations').count().get(),
      db.collection('maternal_records').count().get(),
      db.collection('immunization_records').count().get(),
      db.collection('family_planning').count().get(),
      db.collection('nutrition_records').count().get(),
      db.collection('dental_records').count().get(),
      db.collection('lab_requests').where('status', isEqualTo: 'pending').count().get(),
      db.collection('lab_requests').where('status', isEqualTo: 'completed').count().get(),
      db.collection('patients').where('sex', isEqualTo: 'male').count().get(),
      db.collection('patients').where('sex', isEqualTo: 'female').count().get(),
    ]);
    if (mounted) setState(() {
      _patients = results[0].count ?? 0; _appointments = results[1].count ?? 0;
      _consultations = results[2].count ?? 0; _maternal = results[3].count ?? 0;
      _immunization = results[4].count ?? 0; _fp = results[5].count ?? 0;
      _nutrition = results[6].count ?? 0; _dental = results[7].count ?? 0;
      _labPending = results[8].count ?? 0; _labCompleted = results[9].count ?? 0;
      _maleCount = results[10].count ?? 0; _femaleCount = results[11].count ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.screenWidth >= 768;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
            child: Text('Reports & Analytics', style: AppTypography.displaySmall),
          )),
          // KPI summary
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.all(isWide ? 32 : 20),
            child: GridView.count(
              crossAxisCount: isWide ? 4 : 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: isWide ? 1.8 : 1.5,
              children: [
                StatCard(label: 'Patients', value: '$_patients', icon: Icons.people_outline_rounded),
                StatCard(label: 'Consultations', value: '$_consultations', icon: Icons.medical_services_outlined, iconColor: AppColors.success, iconBgColor: AppColors.successLight),
                StatCard(label: 'Appointments', value: '$_appointments', icon: Icons.calendar_today_outlined, iconColor: AppColors.info, iconBgColor: AppColors.infoLight),
                StatCard(label: 'Immunizations', value: '$_immunization', icon: Icons.vaccines_outlined, iconColor: AppColors.accent, iconBgColor: AppColors.accentLight),
              ],
            ),
          )),
          // Charts row
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: isWide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildServiceChart()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildGenderPie()),
                  ])
                : Column(children: [
                    _buildServiceChart(),
                    const SizedBox(height: 20),
                    _buildGenderPie(),
                  ]),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          // Program stats
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 20),
            child: _buildProgramStats(isWide),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildServiceChart() {
    final data = [
      _BarData('Consul', _consultations.toDouble(), AppColors.primary),
      _BarData('Maternal', _maternal.toDouble(), const Color(0xFFE91E63)),
      _BarData('Immun', _immunization.toDouble(), AppColors.info),
      _BarData('FP', _fp.toDouble(), const Color(0xFF9C27B0)),
      _BarData('Nutri', _nutrition.toDouble(), AppColors.success),
      _BarData('Dental', _dental.toDouble(), const Color(0xFF00897B)),
    ];
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Services Breakdown', style: AppTypography.titleLarge),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.3).clamp(5, double.infinity),
            barGroups: data.asMap().entries.map((e) => BarChartGroupData(
              x: e.key,
              barRods: [BarChartRodData(toY: e.value.value, color: e.value.color, width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(show: true, toY: (data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.3).clamp(5, double.infinity),
                  color: AppColors.surfaceAlt))],
            )).toList(),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(data[v.toInt()].label, style: AppTypography.labelSmall),
                ))),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          )),
        ),
      ]),
    );
  }

  Widget _buildGenderPie() {
    final total = _maleCount + _femaleCount;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Patient Demographics', style: AppTypography.titleLarge),
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: total == 0
              ? Center(child: Text('No data', style: AppTypography.bodySmall))
              : PieChart(PieChartData(
                  centerSpaceRadius: 50,
                  sectionsSpace: 3,
                  sections: [
                    PieChartSectionData(
                      value: _maleCount.toDouble(), title: '$_maleCount',
                      color: AppColors.primary, radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    PieChartSectionData(
                      value: _femaleCount.toDouble(), title: '$_femaleCount',
                      color: const Color(0xFFE91E63), radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                )),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legend(AppColors.primary, 'Male'),
          const SizedBox(width: 24),
          _legend(const Color(0xFFE91E63), 'Female'),
        ]),
      ]),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: AppTypography.labelMedium),
    ]);
  }

  Widget _buildProgramStats(bool isWide) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Program Summary', style: AppTypography.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isWide ? 4 : 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
          children: [
            _programTile('Maternal Records', _maternal, const Color(0xFFE91E63)),
            _programTile('Immunizations', _immunization, AppColors.info),
            _programTile('Family Planning', _fp, const Color(0xFF9C27B0)),
            _programTile('Nutrition Records', _nutrition, AppColors.success),
            _programTile('Dental Records', _dental, const Color(0xFF00897B)),
            _programTile('Lab Pending', _labPending, AppColors.warning),
            _programTile('Lab Completed', _labCompleted, AppColors.success),
            _programTile('Total Patients', _patients, AppColors.primary),
          ],
        ),
      ]),
    );
  }

  Widget _programTile(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(children: [
        Text('$count', style: AppTypography.titleLarge.copyWith(color: color)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTypography.labelMedium, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  final Color color;
  _BarData(this.label, this.value, this.color);
}
