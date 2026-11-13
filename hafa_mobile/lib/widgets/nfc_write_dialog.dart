import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/nfc_service.dart';

enum _WriteState { checking, unsupported, waiting, success, error }

/// Dialog "Dekatkan tag NFC" untuk menulis hafa://verify/<kunci> pada tag kosong.
class NfcWriteDialog extends StatefulWidget {
  const NfcWriteDialog({super.key, required this.uri, required this.productName});
  final String uri;
  final String productName;

  @override
  State<NfcWriteDialog> createState() => _NfcWriteDialogState();
}

class _NfcWriteDialogState extends State<NfcWriteDialog> {
  _WriteState _state = _WriteState.checking;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    NfcService.stop();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _state = _WriteState.checking);
    final ok = await NfcService.isAvailable();
    if (!mounted) return;
    if (!ok) {
      setState(() => _state = _WriteState.unsupported);
      return;
    }
    setState(() => _state = _WriteState.waiting);
    await NfcService.startWrite(
      uri: widget.uri,
      onSuccess: () {
        NfcService.stop();
        if (mounted) setState(() => _state = _WriteState.success);
      },
      onError: (e) {
        NfcService.stop();
        if (mounted) {
          setState(() {
            _error = e;
            _state = _WriteState.error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String title;
    String body;
    switch (_state) {
      case _WriteState.checking:
        icon = Icons.nfc_rounded;
        color = HC.emerald;
        title = 'Preparing NFC...';
        body = '';
        break;
      case _WriteState.unsupported:
        icon = Icons.nfc_rounded;
        color = Colors.grey;
        title = 'NFC unavailable';
        body = 'This device has no NFC, or NFC is turned off. Enable it in Settings and try again.';
        break;
      case _WriteState.waiting:
        icon = Icons.nfc_rounded;
        color = HC.gold;
        title = 'Hold the tag near your phone';
        body = 'Writing the verification link for "${widget.productName}" to the tag.';
        break;
      case _WriteState.success:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF16A34A);
        title = 'Tag written!';
        body = 'Anyone can now tap this tag to verify the product.';
        break;
      case _WriteState.error:
        icon = Icons.error_rounded;
        color = const Color(0xFFDC2626);
        title = 'Could not write the tag';
        body = _error;
        break;
    }
    final done = _state == _WriteState.success;
    final canRetry = _state == _WriteState.error || _state == _WriteState.unsupported;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: color.o(0.15), shape: BoxShape.circle),
          child: _state == _WriteState.checking
              ? const Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator(strokeWidth: 3, color: HC.emerald))
              : Icon(icon, size: 38, color: color),
        ),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: heading(18)),
        if (body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5, height: 1.4)),
        ],
      ]),
      actions: [
        if (canRetry) TextButton(onPressed: _start, child: const Text('Try again')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(done),
          child: Text(done ? 'Done' : 'Cancel'),
        ),
      ],
    );
  }
}

/// Pembantu: papar dialog tulis NFC.
Future<void> showNfcWriteDialog(BuildContext context, {required String uri, required String productName}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => NfcWriteDialog(uri: uri, productName: productName),
  );
}
