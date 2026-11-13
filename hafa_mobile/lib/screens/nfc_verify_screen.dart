import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../core/utils.dart';
import '../services/nfc_service.dart';
import '../widgets/common.dart';
import '../widgets/patterns.dart';

enum _NfcState { checking, unsupported, ready, notHafa, error }

/// Baca tag NFC sebenar (NDEF). Tag HAFA menyimpan: hafa://verify/<verificationId>
class NfcVerifyScreen extends StatefulWidget {
  const NfcVerifyScreen({super.key});

  @override
  State<NfcVerifyScreen> createState() => _NfcVerifyScreenState();
}

class _NfcVerifyScreenState extends State<NfcVerifyScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  _NfcState _state = _NfcState.checking;
  String _message = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _ripple.dispose();
    NfcService.stop();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _state = _NfcState.checking;
      _message = '';
    });
    final ok = await NfcService.isAvailable();
    if (!mounted) return;
    if (!ok) {
      setState(() => _state = _NfcState.unsupported);
      return;
    }
    setState(() => _state = _NfcState.ready);
    await NfcService.startRead(
      onTag: _onTag,
      onError: (e) {
        if (mounted) {
          setState(() {
            _state = _NfcState.error;
            _message = e;
          });
        }
      },
    );
  }

  Future<void> _onTag(String? text) async {
    if (_busy || !mounted) return;
    _busy = true;
    await NfcService.stop();
    if (!mounted) return;
    final key = text == null ? null : extractVerificationKey(text);
    if (key == null) {
      setState(() {
        _state = _NfcState.notHafa;
        _message = 'This tag does not contain a HAFA verification link.';
      });
      _busy = false;
      return;
    }
    HapticFeedback.mediumImpact();
    await context.push('/qr-verify/${Uri.encodeComponent(key)}?m=nfc');
    _busy = false;
    if (mounted) _start(); // sedia untuk tag seterusnya apabila pengguna kembali
  }

  Widget _ring(double t) => Opacity(
        opacity: ((1 - t) * 0.55).clamp(0.0, 1.0),
        child: Container(
          width: 96 + 140 * t,
          height: 96 + 140 * t,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: HC.gold, width: 2)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ready = _state == _NfcState.ready;
    return Scaffold(
      body: GradientBackground(
        songket: 0.1,
        child: SafeArea(
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => goBack(context, fallback: '/verify'),
                icon: Icon(Icons.arrow_back_rounded, color: HC.cream, size: 20),
                label: Text('Back', style: TextStyle(color: HC.cream)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: AnimatedBuilder(
                      animation: _ripple,
                      builder: (_, __) => Stack(alignment: Alignment.center, children: [
                        if (ready) ...[_ring(_ripple.value), _ring((_ripple.value + 0.5) % 1.0)],
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: HC.gold,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: HC.gold.o(0.4), blurRadius: 28, spreadRadius: 2)],
                          ),
                          child: _state == _NfcState.checking
                              ? const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 3.5, color: HC.emeraldDark))
                              : Icon(_icon(), size: 52, color: HC.emeraldDark),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(_title(), textAlign: TextAlign.center, style: heading(27, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(_body(), textAlign: TextAlign.center, style: TextStyle(color: HC.cream, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 28),
                  if (_state != _NfcState.ready && _state != _NfcState.checking)
                    AppButton(
                      label: _state == _NfcState.unsupported ? 'Check again' : 'Scan again',
                      icon: Icons.refresh_rounded,
                      style: BtnStyle.gold,
                      onPressed: _start,
                    ),
                  if (_state == _NfcState.unsupported) ...[
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Use QR Code Instead',
                      icon: Icons.qr_code_scanner_rounded,
                      style: BtnStyle.ghostLight,
                      onPressed: () => goBack(context, fallback: '/verify'),
                    ),
                  ],
                  if (ready)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.o(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: HC.gold.o(0.3))),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded, color: HC.gold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Keep the back of your phone steady against the tag for a moment.',
                              style: TextStyle(color: HC.cream, fontSize: 13, height: 1.4)),
                        ),
                      ]),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  IconData _icon() {
    switch (_state) {
      case _NfcState.unsupported:
        return Icons.nfc_rounded;
      case _NfcState.notHafa:
        return Icons.help_outline_rounded;
      case _NfcState.error:
        return Icons.error_outline_rounded;
      default:
        return Icons.nfc_rounded;
    }
  }

  String _title() {
    switch (_state) {
      case _NfcState.checking:
        return 'Preparing NFC...';
      case _NfcState.unsupported:
        return 'NFC Not Available';
      case _NfcState.ready:
        return 'Ready to Scan';
      case _NfcState.notHafa:
        return 'Unknown Tag';
      case _NfcState.error:
        return 'Scan Failed';
    }
  }

  String _body() {
    switch (_state) {
      case _NfcState.checking:
        return '';
      case _NfcState.unsupported:
        return 'This device has no NFC, or NFC is switched off. Turn it on in Settings > Connected devices, or use a QR code instead.';
      case _NfcState.ready:
        return 'Hold the top-back of your phone against the HAFA tag on the product.';
      case _NfcState.notHafa:
      case _NfcState.error:
        return _message;
    }
  }
}
