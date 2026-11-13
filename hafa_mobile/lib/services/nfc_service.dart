import 'dart:convert';

import 'package:nfc_manager/nfc_manager.dart';

/// Pembaca/penulis tag NFC (NDEF). Tag HAFA menyimpan satu rekod URI: hafa://verify/<kunci>
class NfcService {
  NfcService._();

  static const _uriPrefixes = [
    '', 'http://www.', 'https://www.', 'http://', 'https://', 'tel:', 'mailto:',
    'ftp://anonymous:anonymous@', 'ftp://ftp.', 'ftps://', 'sftp://', 'smb://', 'nfs://',
    'ftp://', 'dav://', 'news:', 'telnet://', 'imap:', 'rtsp://', 'urn:', 'pop:', 'sip:',
    'sips:', 'tftp:', 'btspp://', 'btl2cap://', 'btgoep://', 'tcpobex://', 'irdaobex://',
    'file://', 'urn:epc:id:', 'urn:epc:tag:', 'urn:epc:pat:', 'urn:epc:raw:', 'urn:epc:',
    'urn:nfc:',
  ];

  static Future<bool> isAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Teks daripada rekod NDEF pertama yang boleh dibaca (URI / Text / lain-lain).
  static String? _decodeRecord(NdefRecord r) {
    final payload = r.payload;
    if (payload.isEmpty) return null;
    if (r.typeNameFormat == NdefTypeNameFormat.nfcWellknown && r.type.length == 1) {
      if (r.type[0] == 0x55) {
        final code = payload[0];
        final prefix = code < _uriPrefixes.length ? _uriPrefixes[code] : '';
        return prefix + utf8.decode(payload.sublist(1), allowMalformed: true);
      }
      if (r.type[0] == 0x54) {
        final langLen = payload[0] & 0x3F;
        if (payload.length <= 1 + langLen) return null;
        return utf8.decode(payload.sublist(1 + langLen), allowMalformed: true);
      }
    }
    return utf8.decode(payload, allowMalformed: true);
  }

  /// Mula sesi baca. [onTag] menerima teks tag (null jika tag tiada data NDEF).
  static Future<void> startRead({
    required void Function(String? text) onTag,
    required void Function(String error) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          String? text;
          try {
            final ndef = Ndef.from(tag);
            final message = ndef?.cachedMessage;
            if (message != null) {
              for (final record in message.records) {
                text = _decodeRecord(record);
                if (text != null && text.trim().isNotEmpty) break;
              }
            }
          } catch (e) {
            onError('Could not read the tag: $e');
            return;
          }
          onTag(text);
        },
      );
    } catch (e) {
      onError('NFC session failed: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
  }

  /// Tulis rekod URI pada tag yang didekatkan.
  static Future<void> startWrite({
    required String uri,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final ndef = Ndef.from(tag);
            if (ndef == null) {
              onError('This tag does not support NDEF.');
              return;
            }
            if (!ndef.isWritable) {
              onError('This tag is read-only or locked.');
              return;
            }
            final message = NdefMessage([NdefRecord.createUri(Uri.parse(uri))]);
            await ndef.write(message);
            onSuccess();
          } catch (e) {
            onError('Write failed: $e');
          }
        },
      );
    } catch (e) {
      onError('NFC session failed: $e');
    }
  }
}
