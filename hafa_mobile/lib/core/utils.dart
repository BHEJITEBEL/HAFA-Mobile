import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Kembali ke halaman sebelumnya; jika tiada, pergi ke [fallback].
void goBack(BuildContext context, {String fallback = '/home'}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

void showMsg(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(message)));
}

Future<void> copyText(BuildContext context, String text, String label) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) showMsg(context, '$label copied');
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Selamat Pagi';
  if (h < 18) return 'Selamat Tengahari';
  return 'Selamat Petang';
}

String formatDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String shortHash(String h, [int n = 32]) => h.length <= n ? h : '${h.substring(0, n)}...';

/// Ambil kunci pengesahan daripada kandungan QR / NFC.
///  - `hafa://verify/HAFA-2024-TRG-001`  -> `HAFA-2024-TRG-001`
///  - `https://tapak/verify/HP001`       -> `HP001`
///  - `HAFA-2024-TRG-001` (teks biasa)   -> `HAFA-2024-TRG-001`
///  - URL tanpa ID (cth. https://google.com) -> null (bukan kod HAFA)
String? extractVerificationKey(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final uri = Uri.tryParse(s);
  if (uri != null && uri.hasScheme) {
    final segs = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (segs.isEmpty) return null;
    try {
      return Uri.decodeComponent(segs.last);
    } catch (_) {
      return segs.last;
    }
  }
  return s;
}
