import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _verifications = [45.0, 52.0, 61.0, 58.0, 72.0, 85.0];
  static const _registrations = [12.0, 18.0, 15.0, 22.0, 28.0, 31.0];

  static const _categories = <(String, double, Color)>[
    ('Songket', 34.0, HC.emerald),
    ('Batik', 28.0, HC.gold),
    ('Keris', 12.0, HC.maroon),
    ('Pottery', 15.0, HC.bronze),
    ('Tenun', 11.0, HC.forest),
  ];

  void _review(BuildContext context, Product p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: heading(20)),
          const SizedBox(height: 8),
          VerificationBadge(status: p.status),
          const SizedBox(height: 12),
          InfoRow(icon: Icons.person_outline_rounded, label: 'Artisan', value: p.artisan.name),
          InfoRow(icon: Icons.tag_rounded, label: 'Verification ID', value: p.verificationId, mono: true),
          InfoRow(icon: Icons.calendar_today_outlined, label: 'Registered', value: p.productionDate),
          const SizedBox(height: 8),
          Text(
            'Approve / reject actions need an authenticated admin API, which is not part of this prototype yet.',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Close', style: BtnStyle.outline, onPressed: () => Navigator.of(context).pop()),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final products = app.products;
    final axisHidden = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        GradientHeader(
          padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 6, 16, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => goBack(context)),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Dashboard', style: heading(26, color: Colors.white)),
                const SizedBox(height: 4),
                Text('System-wide monitoring and analytics', style: TextStyle(color: HC.cream, fontSize: 13.5)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TwoColumn(children: const [
              StatCard(label: 'Total Products', value: '${AdminStats.totalProducts}', icon: Icons.inventory_2_rounded, color: HC.emerald),
              StatCard(label: 'Registered Artisans', value: '${AdminStats.registeredArtisans}', icon: Icons.groups_rounded, color: HC.goldDark),
              StatCard(label: 'Pending Reviews', value: '${AdminStats.verificationRequests}', icon: Icons.pending_actions_rounded, color: Color(0xFFCA8A04)),
              StatCard(label: 'Fraud Alerts', value: '${AdminStats.fraudAlerts}', icon: Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            ]),
            const SizedBox(height: 22),
            Text('Monthly Trends', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              child: Column(children: [
                SizedBox(
                  height: 210,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: axisHidden,
                        rightTitles: axisHidden,
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= _months.length) return const SizedBox.shrink();
                              return Padding(padding: const EdgeInsets.only(top: 6), child: Text(_months[i], style: const TextStyle(fontSize: 11)));
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < _months.length; i++)
                          BarChartGroupData(x: i, barsSpace: 4, barRods: [
                            BarChartRodData(toY: _verifications[i], color: HC.emerald, width: 9, borderRadius: BorderRadius.circular(3)),
                            BarChartRodData(toY: _registrations[i], color: HC.gold, width: 9, borderRadius: BorderRadius.circular(3)),
                          ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _legend(HC.emerald, 'Verifications'),
                  const SizedBox(width: 18),
                  _legend(HC.gold, 'Registrations'),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            Text('Products by Category', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              child: Row(children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 26,
                      sections: [
                        for (final c in _categories)
                          PieChartSectionData(value: c.$2, color: c.$3, radius: 34, showTitle: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(children: [
                    for (final c in _categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          Container(width: 11, height: 11, decoration: BoxDecoration(color: c.$3, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(c.$1, style: const TextStyle(fontSize: 13))),
                          Text('${c.$2.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ]),
                      ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            TwoColumn(children: const [
              StatCard(label: 'Monthly Scans', value: '${AdminStats.monthlyScans}', icon: Icons.qr_code_2_rounded, color: HC.forest),
              StatCard(label: 'Active Listings', value: '${AdminStats.activeListings}', icon: Icons.storefront_rounded, color: HC.bronze),
            ]),
            const SizedBox(height: 6),
            Text('Charts and totals above are sample figures for the prototype.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
            const SizedBox(height: 22),
            Text('Product Registry', style: heading(19)),
            const SizedBox(height: 10),
            if (products.isEmpty)
              AppCard(child: Text('No products loaded.', style: TextStyle(color: Colors.grey.shade700)))
            else
              for (final p in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                          const SizedBox(height: 2),
                          Text('${p.id}  -  ${p.artisan.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                          const SizedBox(height: 6),
                          VerificationBadge(status: p.status),
                        ]),
                      ),
                      TextButton(onPressed: () => _review(context, p), child: const Text('Review')),
                    ]),
                  ),
                ),
            const SizedBox(height: 10),
          ]),
        ),
      ]),
    );
  }

  Widget _legend(Color c, String t) => Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(fontSize: 12.5)),
      ]);
}
