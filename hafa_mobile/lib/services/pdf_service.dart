import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/product.dart';

/// Jana PDF (sijil Heritage Passport & laporan blockchain). Fon PDF asas hanya sokong ASCII.
class PdfService {
  PdfService._();

  static final _emerald = PdfColor.fromHex('#0F4C3A');
  static final _gold = PdfColor.fromHex('#D4AF37');
  static final _grey = PdfColor.fromHex('#6B7280');

  static String _a(String s) => s.replaceAll(RegExp(r'[^\x00-\x7F]'), '?');

  static pw.Widget _field(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_a(label).toUpperCase(), style: pw.TextStyle(fontSize: 8, color: _grey, letterSpacing: 1)),
            pw.SizedBox(height: 2),
            pw.Text(_a(value.isEmpty ? '-' : value), style: pw.TextStyle(fontSize: 11)),
          ],
        ),
      );

  static pw.Widget _qr(String data, {double size = 90}) => pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(),
        data: data,
        width: size,
        height: size,
        color: _emerald,
      );

  static Future<void> shareCertificate(Product p) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _gold, width: 3)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(children: [
                  pw.Text('HERITAGE PASSPORT',
                      style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _emerald, letterSpacing: 3)),
                  pw.SizedBox(height: 4),
                  pw.Text('Malaysian Heritage Authentication Certificate', style: pw.TextStyle(fontSize: 11, color: _grey)),
                  pw.SizedBox(height: 10),
                  pw.Text(_a(p.heritagePassportNumber),
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _gold)),
                ]),
              ),
              pw.Divider(color: _gold, height: 28),
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Expanded(
                  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    _field('Product name', p.name),
                    _field('Craft category', p.category),
                    _field('Verification ID', p.verificationId),
                    _field('Status', p.status),
                    _field('Artisan', p.artisan.name),
                    _field('Production location', p.artisan.location),
                    _field('Production date', p.productionDate),
                    _field('Materials', p.materials.join(', ')),
                    _field('Production method', p.productionMethod),
                  ]),
                ),
                pw.SizedBox(width: 16),
                pw.Column(children: [
                  _qr(p.verifyUri, size: 110),
                  pw.SizedBox(height: 4),
                  pw.Text('Scan to verify', style: pw.TextStyle(fontSize: 8, color: _grey)),
                ]),
              ]),
              pw.Divider(color: _gold, height: 24),
              _field('Cultural significance', p.culturalSignificance),
              _field('Blockchain hash', p.blockchainHash),
              _field('IPFS CID', p.ipfsCid),
              pw.Spacer(),
              pw.Center(
                child: pw.Column(children: [
                  pw.Text('Issued by Heritage Authority Malaysia',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _emerald)),
                  pw.Text('Preserving Malaysian Cultural Heritage Through Blockchain Technology',
                      style: pw.TextStyle(fontSize: 8, color: _grey)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(
      name: 'HAFA-Passport-${p.heritagePassportNumber}.pdf',
      onLayout: (_) async => doc.save(),
    );
  }

  static Future<void> shareVerificationReport(Product p) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Blockchain Verification Report',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _emerald)),
            pw.Text('HAFA - Heritage Artisan Fair-Trade Authenticator', style: pw.TextStyle(fontSize: 10, color: _grey)),
            pw.Divider(color: _gold, height: 24),
            _field('Product', p.name),
            _field('Verification ID', p.verificationId),
            _field('Status', p.status),
            _field('Transaction hash', p.blockchainHash),
            _field('IPFS CID', p.ipfsCid),
            _field('Block number', '15,847,392'),
            _field('Production date', p.productionDate),
            pw.SizedBox(height: 8),
            pw.Text('OWNERSHIP RECORDS', style: pw.TextStyle(fontSize: 9, color: _grey, letterSpacing: 1)),
            pw.SizedBox(height: 4),
            for (final r in p.ownershipHistory)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Text('${_a(r.date)}  -  ${_a(r.owner)} (${_a(r.type)})${r.verificationBadge ? '  [verified]' : ''}',
                    style: pw.TextStyle(fontSize: 10)),
              ),
            pw.Spacer(),
            pw.Center(child: _qr(p.verifyUri)),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text('Generated by the HAFA mobile app', style: pw.TextStyle(fontSize: 8, color: _grey)),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      name: 'HAFA-Verification-${p.verificationId}.pdf',
      onLayout: (_) async => doc.save(),
    );
  }
}
