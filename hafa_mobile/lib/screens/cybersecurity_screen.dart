import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

/// Papan pemuka keselamatan (data contoh statik, seperti versi web).
class CybersecurityScreen extends StatelessWidget {
  const CybersecurityScreen({super.key});

  static const _metrics = <(String, double)>[
    ('Blockchain Integrity', 99.9),
    ('API Availability', 99.5),
    ('Encryption Coverage', 100.0),
    ('Tag Authenticity Checks', 97.8),
  ];

  static const _alerts = <(String, String, String, Color)>[
    ('Duplicate QR code detected', 'Same code scanned in 3 distant locations within 1 hour', 'High', Color(0xFFDC2626)),
    ('Unregistered NFC tag read', 'Tag UID not found in the HAFA registry', 'Medium', Color(0xFFCA8A04)),
  ];

  static const _status = <(String, bool)>[
    ('Blockchain network', true),
    ('IPFS storage nodes', true),
    ('API gateway', true),
    ('Authentication service', true),
    ('Fraud detection engine', true),
  ];

  static const _threats = [3.0, 5.0, 2.0, 6.0, 4.0, 2.0, 2.0];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String t(int minsAgo) {
      final d = now.subtract(Duration(minutes: minsAgo));
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }

    final logs = [
      '[${t(1)}] Verification request OK - HP001',
      '[${t(3)}] Blockchain sync completed',
      '[${t(7)}] Fraud scan finished: 2 alerts',
      '[${t(12)}] IPFS pin verified',
    ];

    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        GradientHeader(
          padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 6, 16, 22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => goBack(context)),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cybersecurity', style: heading(26, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Threat monitoring and system health', style: TextStyle(color: HC.cream, fontSize: 13.5)),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppCard(
              child: Row(children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(alignment: Alignment.center, children: [
                    const SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        value: 0.94,
                        strokeWidth: 10,
                        backgroundColor: HC.creamDark,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                      ),
                    ),
                    Text('94', style: heading(30)),
                  ]),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Security Score', style: heading(19)),
                    const SizedBox(height: 4),
                    Text('System is healthy. 2 open alerts need review.', style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Text('Security Metrics', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              child: Column(children: [
                for (final m in _metrics)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: Text(m.$1, style: const TextStyle(fontWeight: FontWeight.w600, color: HC.teak))),
                        Text('${m.$2}%', style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emerald)),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: m.$2 / 100,
                          minHeight: 8,
                          backgroundColor: HC.emerald.o(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(HC.emerald),
                        ),
                      ),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 18),
            Text('Threats This Week', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              child: SizedBox(
                height: 170,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 8,
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, interval: 2)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: 1,
                          getTitlesWidget: (v, meta) {
                            const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            final i = v.toInt();
                            if (i < 0 || i >= d.length) return const SizedBox.shrink();
                            return Padding(padding: const EdgeInsets.only(top: 6), child: Text(d[i], style: const TextStyle(fontSize: 10.5)));
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [for (var i = 0; i < _threats.length; i++) FlSpot(i.toDouble(), _threats[i])],
                        isCurved: true,
                        color: HC.maroon,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Fraud Alerts', style: heading(19)),
            const SizedBox(height: 10),
            for (final a in _alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.warning_amber_rounded, color: a.$4),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                        const SizedBox(height: 2),
                        Text(a.$2, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4)),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: a.$4.o(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(a.$3, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: a.$4)),
                    ),
                  ]),
                ),
              ),
            const SizedBox(height: 8),
            Text('System Status', style: heading(19)),
            const SizedBox(height: 10),
            AppCard(
              child: Column(children: [
                for (final s in _status)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Icon(s.$2 ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 20, color: s.$2 ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.$1, style: const TextStyle(color: HC.teak))),
                      Text(s.$2 ? 'Operational' : 'Down', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: HC.navy, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Live Activity Log', style: heading(16, color: HC.gold)),
                const SizedBox(height: 10),
                for (final l in logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(l, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.white.o(0.85), height: 1.4)),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            Text('Figures on this page are sample data for the prototype.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }
}
