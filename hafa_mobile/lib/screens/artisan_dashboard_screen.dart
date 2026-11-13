import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final products = app.products;
    final verified = products.where((p) => p.isVerified).length;
    final pending = products.where((p) => p.isPending).length;
    final scans = products.fold<int>(0, (s, p) => s + p.touristScans);
    final verifs = products.fold<int>(0, (s, p) => s + p.verificationRequests);

    return Scaffold(
      body: RefreshIndicator(
        color: HC.emerald,
        onRefresh: app.loadProducts,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            GradientHeader(
              padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 6, 16, 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => goBack(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Artisan Dashboard', style: heading(26, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Manage your heritage crafts and track performance', style: TextStyle(color: HC.cream, fontSize: 13.5)),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 220,
                      child: AppButton(
                        label: 'Register New Product',
                        icon: Icons.add_rounded,
                        style: BtnStyle.gold,
                        onPressed: () => context.push('/register-product'),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TwoColumn(children: [
                StatCard(label: 'Total Products', value: '${products.length}', icon: Icons.inventory_2_rounded, color: HC.emerald),
                StatCard(label: 'Verified', value: '$verified', icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A), sub: '$pending pending'),
                StatCard(label: 'Tourist Scans', value: '$scans', icon: Icons.qr_code_2_rounded, color: HC.goldDark),
                StatCard(label: 'Verification Requests', value: '$verifs', icon: Icons.shield_rounded, color: HC.bronze),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: HC.creamDark, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  for (final (i, label) in const ['Overview', 'My Products', 'Analytics'].indexed)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tab == i ? HC.emerald : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(label,
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _tab == i ? Colors.white : HC.emerald)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: app.productsLoading && products.isEmpty
                  ? const Padding(padding: EdgeInsets.all(40), child: LoadingView())
                  : [_overview(products), _productsTab(products), _analytics(products)][_tab],
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview(List<Product> products) {
    final events = <(ProvenanceEvent, Product)>[
      for (final p in products)
        for (final e in p.provenanceTimeline) (e, p),
    ]..sort((a, b) => b.$1.date.compareTo(a.$1.date));
    final recent = events.take(6).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Recent Activity', style: heading(19)),
      const SizedBox(height: 10),
      if (recent.isEmpty)
        AppCard(child: Text('No activity yet. Register your first product!', style: TextStyle(color: Colors.grey.shade700)))
      else
        for (final (e, p) in recent)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: const EdgeInsets.all(12),
              onTap: () => context.push('/product/${Uri.encodeComponent(p.id)}'),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: HC.emerald.o(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.history_rounded, size: 20, color: HC.emerald),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.event, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                  ]),
                ),
                Text(e.date, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              ]),
            ),
          ),
    ]);
  }

  Widget _productsTab(List<Product> products) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('My Products', style: heading(19)),
      const SizedBox(height: 10),
      for (final p in products)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(10),
            onTap: () => context.push('/product/${Uri.encodeComponent(p.id)}'),
            child: Row(children: [
              SizedBox(
                width: 64,
                height: 64,
                child: ClipRRect(borderRadius: BorderRadius.circular(10), child: AppNetworkImage(p.images.isNotEmpty ? p.images.first : null)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                  const SizedBox(height: 2),
                  Text('${p.category}  -  ${p.price}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  Row(children: [
                    VerificationBadge(status: p.status),
                    const SizedBox(width: 8),
                    Icon(Icons.qr_code_2_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 3),
                    Text('${p.touristScans}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ]),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: HC.emerald),
            ]),
          ),
        ),
      if (products.isEmpty) AppCard(child: Text('No products yet.', style: TextStyle(color: Colors.grey.shade700))),
    ]);
  }

  Widget _analytics(List<Product> products) {
    if (products.isEmpty) {
      return AppCard(child: Text('No data to analyse yet.', style: TextStyle(color: Colors.grey.shade700)));
    }
    final maxY = (products.map((p) => p.touristScans).fold<int>(0, (a, b) => a > b ? a : b) * 1.25).clamp(10, 100000).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tourist Scans per Product', style: heading(19)),
      const SizedBox(height: 10),
      AppCard(
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= products.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(products[i].id, style: const TextStyle(fontSize: 10, color: HC.teak)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < products.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: products[i].touristScans.toDouble(),
                      color: HC.gold,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text('Verification Status', style: heading(19)),
      const SizedBox(height: 10),
      AppCard(
        child: Column(children: [
          _bar('Verified', products.where((p) => p.isVerified).length, products.length, const Color(0xFF16A34A)),
          const SizedBox(height: 10),
          _bar('Pending', products.where((p) => p.isPending).length, products.length, const Color(0xFFCA8A04)),
        ]),
      ),
    ]);
  }

  Widget _bar(String label, int value, int total, Color color) {
    final f = total == 0 ? 0.0 : value / total;
    return Column(children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: HC.teak))),
        Text('$value / $total', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: f, minHeight: 9, backgroundColor: color.o(0.15), valueColor: AlwaysStoppedAnimation<Color>(color)),
      ),
    ]);
  }
}
