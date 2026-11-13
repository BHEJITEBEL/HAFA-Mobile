import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/product.dart';
import '../services/pdf_service.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

class BlockchainScreen extends StatelessWidget {
  const BlockchainScreen({super.key, required this.productKey});
  final String productKey;

  @override
  Widget build(BuildContext context) {
    return ProductLoader(
      productKey: productKey,
      builder: (context, product) => _BlockchainView(product: product),
    );
  }
}

class _BlockchainView extends StatefulWidget {
  const _BlockchainView({required this.product});
  final Product product;

  @override
  State<_BlockchainView> createState() => _BlockchainViewState();
}

class _BlockchainViewState extends State<_BlockchainView> {
  bool _pdfBusy = false;

  Future<void> _report() async {
    setState(() => _pdfBusy = true);
    try {
      await PdfService.shareVerificationReport(widget.product);
    } catch (e) {
      if (mounted) showMsg(context, 'Could not create the report: $e');
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  List<String> _logs(Product p) {
    final logs = <String>[
      '[${p.productionDate} 14:23:45] Product registered on blockchain',
      '[${p.productionDate} 14:24:12] IPFS upload completed: ${shortHash(p.ipfsCid, 20)}',
      '[${p.productionDate} 14:24:58] Smart contract executed successfully',
    ];
    for (final r in p.ownershipHistory) {
      if (r.type == 'Authority Approval') logs.add('[${r.date} 10:15:30] Heritage Authority verification completed');
      if (r.type == 'Listed') logs.add('[${r.date} 09:00:00] Product listed for public verification');
    }
    logs.add('[LIVE] Blockchain monitoring active');
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 12, color: HC.teak, height: 1.4);
    final verified = p.isVerified;

    return Scaffold(
      body: ListView(padding: EdgeInsets.zero, children: [
        GradientHeader(
          padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 6, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => goBack(context, fallback: '/product/${Uri.encodeComponent(p.id)}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: HC.gold, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.link_rounded, size: 30, color: HC.emeraldDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Blockchain Record', style: heading(24, color: Colors.white)),
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: HC.cream, fontSize: 13.5)),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ---- Status ----
            AppCard(
              color: verified ? const Color(0xFFF0FDF4) : const Color(0xFFFEFCE8),
              child: Row(children: [
                Icon(verified ? Icons.verified_rounded : Icons.schedule_rounded,
                    size: 34, color: verified ? const Color(0xFF16A34A) : const Color(0xFFCA8A04)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(verified ? 'Verified on Blockchain' : 'Awaiting Authority Approval',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: HC.emeraldDark)),
                    const SizedBox(height: 2),
                    Text(verified ? 'Record is immutable and publicly auditable' : 'Record exists but is not yet approved',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            // ---- Butiran rantaian ----
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Transaction Details', style: heading(18, color: HC.emerald)),
                const SizedBox(height: 12),
                _field('Transaction Hash', p.blockchainHash, mono, copy: true),
                const SizedBox(height: 12),
                _field('IPFS CID', p.ipfsCid, mono, copy: true),
                const SizedBox(height: 12),
                _field('Verification ID', p.verificationId, mono, copy: true),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _plain('Block Number', '15,847,392')),
                  Expanded(child: _plain('Network', 'Heritage Chain')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _plain('Created', p.productionDate)),
                  Expanded(child: _plain('Confirmations', verified ? '1,247' : '-')),
                ]),
              ]),
            ),
            const SizedBox(height: 14),

            // ---- Log ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: HC.navy, borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.terminal_rounded, color: HC.gold, size: 18),
                  const SizedBox(width: 8),
                  Text('Blockchain Log', style: heading(16, color: HC.gold)),
                ]),
                const SizedBox(height: 10),
                for (final l in _logs(p))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(l,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                          color: l.startsWith('[LIVE]') ? const Color(0xFF4ADE80) : Colors.white.o(0.85),
                        )),
                  ),
              ]),
            ),
            const SizedBox(height: 14),

            // ---- Pemilikan ----
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ownership Records', style: heading(18, color: HC.emerald)),
                const SizedBox(height: 10),
                for (final r in p.ownershipHistory)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: HC.cream, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.owner, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.emeraldDark)),
                          Text('${r.type} - ${r.date}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ]),
                      ),
                      if (r.verificationBadge) const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                    ]),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Download Verification Report',
              icon: Icons.download_rounded,
              style: BtnStyle.gold,
              loading: _pdfBusy,
              onPressed: _report,
            ),
            const SizedBox(height: 12),
          ]),
        ),
      ]),
    );
  }

  Widget _plain(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, letterSpacing: 1.1)),
        const SizedBox(height: 2),
        Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w700, color: HC.teak, fontSize: 14)),
      ]);

  Widget _field(String label, String value, TextStyle mono, {bool copy = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, letterSpacing: 1.1)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: HC.creamDark)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: SelectableText(value.isEmpty ? '-' : value, style: mono)),
              if (copy && value.isNotEmpty)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy_rounded, size: 18, color: HC.emerald),
                  onPressed: () => copyText(context, value, label),
                ),
            ]),
          ),
        ],
      );
}
