import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/pdf_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/nfc_write_dialog.dart';
import '../widgets/patterns.dart';

class HeritagePassportScreen extends StatelessWidget {
  const HeritagePassportScreen({super.key, required this.productKey});
  final String productKey;

  @override
  Widget build(BuildContext context) {
    return ProductLoader(
      productKey: productKey,
      notFoundTitle: 'Heritage Passport Not Found',
      builder: (context, product) => _PassportView(product: product),
    );
  }
}

class _PassportView extends StatefulWidget {
  const _PassportView({required this.product});
  final Product product;

  @override
  State<_PassportView> createState() => _PassportViewState();
}

class _PassportViewState extends State<_PassportView> {
  bool _pdfBusy = false;

  Future<void> _download() async {
    setState(() => _pdfBusy = true);
    try {
      await PdfService.shareCertificate(widget.product);
    } catch (e) {
      if (mounted) showMsg(context, 'Could not create the PDF: $e');
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final role = context.watch<AppState>().role;
    final canWriteNfc = role == UserRole.artisan || role == UserRole.administrator;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: HC.teak, height: 1.4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heritage Passport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => goBack(context, fallback: '/product/${Uri.encodeComponent(p.id)}'),
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: HC.gold, width: 2.5),
            boxShadow: [BoxShadow(color: Colors.black.o(0.1), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // ---- Kepala sijil ----
              Container(
                decoration: const BoxDecoration(gradient: HC.gradient),
                child: Stack(children: [
                  SongketPattern(opacity: 0.15),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                    child: SizedBox(width: double.infinity, child: Column(children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(color: HC.gold, shape: BoxShape.circle),
                        child: const Icon(Icons.shield_outlined, size: 32, color: HC.emeraldDark),
                      ),
                      const SizedBox(height: 12),
                      Text('HERITAGE PASSPORT', textAlign: TextAlign.center, style: heading(24, color: HC.gold, letterSpacing: 2.5)),
                      const SizedBox(height: 4),
                      Text('Malaysian Heritage Authentication Certificate',
                          textAlign: TextAlign.center, style: TextStyle(color: HC.cream, fontSize: 12.5)),
                      const SizedBox(height: 12),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.workspace_premium_rounded, color: HC.gold, size: 16),
                        const SizedBox(width: 6),
                        Text('OFFICIAL CERTIFICATE', style: TextStyle(color: HC.gold, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.workspace_premium_rounded, color: HC.gold, size: 16),
                      ]),
                    ])),
                  ),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ---- Nombor passport ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: HC.cream, borderRadius: BorderRadius.circular(14), border: Border.all(color: HC.gold.o(0.5))),
                    child: Column(children: [
                      Text('HERITAGE PASSPORT NUMBER', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      SelectableText(p.heritagePassportNumber,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w800, color: HC.goldDark)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // ---- Imej + maklumat asas ----
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(fit: StackFit.expand, children: [
                          AppNetworkImage(p.images.isNotEmpty ? p.images.first : null),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: p.isVerified ? const Color(0xFF16A34A) : const Color(0xFFCA8A04),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(p.isVerified ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 14, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(p.isVerified ? 'Authentic' : 'Pending',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Product Name'),
                  Text(p.name, style: heading(21, height: 1.2)),
                  const SizedBox(height: 10),
                  _label('Craft Category'),
                  Text(p.category, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: HC.teak)),
                  const SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label('Verification ID'),
                        SelectableText(p.verificationId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: HC.teak)),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('Status'),
                      VerificationBadge(status: p.status),
                    ]),
                  ]),

                  const HeritageDivider(),

                  InfoRow(icon: Icons.person_outline_rounded, label: 'Artisan Name', value: p.artisan.name),
                  InfoRow(icon: Icons.place_outlined, label: 'Production Location', value: p.artisan.location),
                  InfoRow(icon: Icons.calendar_today_outlined, label: 'Production Date', value: p.productionDate),
                  InfoRow(icon: Icons.inventory_2_outlined, label: 'Materials Used', value: p.materials.join(', ')),
                  InfoRow(icon: Icons.description_outlined, label: 'Production Method', value: p.productionMethod),

                  const HeritageDivider(),

                  Text('Cultural Significance', style: heading(18, color: HC.emerald)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: HC.cream, borderRadius: BorderRadius.circular(14)),
                    child: Text(p.culturalSignificance, style: const TextStyle(fontSize: 14, height: 1.55, color: HC.teak)),
                  ),

                  const SizedBox(height: 22),
                  Text('Ownership History', style: heading(18, color: HC.emerald)),
                  const SizedBox(height: 8),
                  for (final r in p.ownershipHistory)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: HC.creamDark)),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.owner, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: HC.emeraldDark)),
                            Text(r.type, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ]),
                        ),
                        Text(r.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                        if (r.verificationBadge) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF16A34A)),
                        ],
                      ]),
                    ),

                  const HeritageDivider(),

                  Text('Blockchain Verification', style: heading(18, color: HC.emerald)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: HC.creamDark)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label('Blockchain Hash'),
                      SelectableText(p.blockchainHash, style: mono),
                      const SizedBox(height: 12),
                      _label('IPFS CID'),
                      SelectableText(p.ipfsCid, style: mono),
                    ]),
                  ),

                  const SizedBox(height: 22),
                  Center(child: Text('QR Verification Code', style: heading(18, color: HC.emerald))),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HC.gold.o(0.6), width: 2),
                      ),
                      child: Column(children: [
                        QrImageView(
                          data: p.verifyUri,
                          version: QrVersions.auto,
                          size: 170,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: HC.emerald),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: HC.emerald),
                        ),
                        const SizedBox(height: 8),
                        Text('Scan to verify authenticity', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ]),
                    ),
                  ),
                ]),
              ),

              // ---- Kaki sijil ----
              Container(
                decoration: const BoxDecoration(gradient: HC.gradient),
                child: Stack(children: [
                  SongketPattern(opacity: 0.1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Center(
                      child: Column(children: [
                        Text('This digital certificate is issued by', style: TextStyle(color: HC.cream.o(0.8), fontSize: 11.5)),
                        const SizedBox(height: 2),
                        Text('Heritage Authority Malaysia', style: heading(17, color: HC.gold)),
                        const SizedBox(height: 4),
                        Text('Preserving Malaysian Cultural Heritage Through Blockchain Technology',
                            textAlign: TextAlign.center, style: TextStyle(color: HC.cream.o(0.7), fontSize: 10.5)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 18),
        AppButton(
          label: 'Download Certificate (PDF)',
          icon: Icons.download_rounded,
          style: BtnStyle.gold,
          loading: _pdfBusy,
          onPressed: _download,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Blockchain Record',
          icon: Icons.link_rounded,
          onPressed: () => context.push('/blockchain/${Uri.encodeComponent(p.id)}'),
        ),
        if (canWriteNfc) ...[
          const SizedBox(height: 10),
          AppButton(
            label: 'Write to NFC Tag',
            icon: Icons.nfc_rounded,
            style: BtnStyle.outline,
            onPressed: () => showNfcWriteDialog(context, uri: p.verifyUri, productName: p.name),
          ),
        ],
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(t.toUpperCase(), style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, letterSpacing: 1.2)),
      );
}
