import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class _Picked {
  _Picked(this.bytes, this.mime);
  final Uint8List bytes;
  final String mime;
}

/// Pendaftaran produk 6 langkah. Gambar dimuat naik ke server, produk disimpan di MongoDB.
class ProductRegistrationScreen extends StatefulWidget {
  const ProductRegistrationScreen({super.key});

  @override
  State<ProductRegistrationScreen> createState() => _ProductRegistrationScreenState();
}

class _ProductRegistrationScreenState extends State<ProductRegistrationScreen> {
  static const _titles = ['Product Info', 'Category', 'Artisan', 'Photos', 'Details', 'Review'];

  int _step = 0;
  bool _submitting = false;

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _artisanName = TextEditingController();
  final _location = TextEditingController();
  final _experience = TextEditingController();
  final _bio = TextEditingController();
  final _materials = TextEditingController();
  final _method = TextEditingController();
  final _price = TextEditingController();
  final _significance = TextEditingController();
  CraftCategory? _category;
  DateTime _date = DateTime.now();
  final List<_Picked> _images = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    for (final c in [_name, _description, _artisanName, _location, _experience, _bio, _materials, _method, _price, _significance]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(int step) {
    switch (step) {
      case 0:
        if (_name.text.trim().isEmpty) return 'Please enter the product name';
        if (_description.text.trim().isEmpty) return 'Please add a short description';
        return null;
      case 1:
        return _category == null ? 'Please choose a craft category' : null;
      case 2:
        if (_artisanName.text.trim().isEmpty) return 'Please enter the artisan name';
        if (_location.text.trim().isEmpty) return 'Please enter the production location';
        return null;
      case 4:
        if (_price.text.trim().isEmpty) return 'Please enter the price';
        return null;
      default:
        return null;
    }
  }

  void _next() {
    final err = _validate(_step);
    if (err != null) {
      showMsg(context, err);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step++);
  }

  Future<void> _pick(ImageSource source) async {
    if (_images.length >= 4) {
      showMsg(context, 'You can add up to 4 photos.');
      return;
    }
    try {
      final x = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (x == null) return;
      final name = x.name.toLowerCase();
      String? mime;
      if (name.endsWith('.jpg') || name.endsWith('.jpeg')) mime = 'image/jpeg';
      if (name.endsWith('.png')) mime = 'image/png';
      if (name.endsWith('.webp')) mime = 'image/webp';
      if (mime == null) {
        if (mounted) showMsg(context, 'Please choose a JPG, PNG or WebP image.');
        return;
      }
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() => _images.add(_Picked(bytes, mime!)));
    } catch (e) {
      if (mounted) showMsg(context, 'Could not open the image: $e');
    }
  }

  String _normalisedPrice() {
    final raw = _price.text.trim();
    return RegExp(r'^\d[\d,\.]*$').hasMatch(raw) ? 'RM $raw' : raw;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final app = context.read<AppState>();
    try {
      final paths = <String>[];
      for (final img in _images) {
        paths.add(await app.api.uploadImage(img.bytes, img.mime));
      }
      final created = await app.registerProduct({
        'name': _name.text.trim(),
        'category': _category!.value,
        'description': _description.text.trim(),
        'culturalSignificance': _significance.text.trim(),
        'artisan': {
          'name': _artisanName.text.trim(),
          'location': _location.text.trim(),
          'experience': _experience.text.trim(),
          'bio': _bio.text.trim(),
        },
        'materials': _materials.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'productionDate': formatDate(_date),
        'productionMethod': _method.text.trim(),
        'price': _normalisedPrice(),
        'images': paths,
      });
      if (!mounted) return;
      showMsg(context, 'Product registered! Awaiting authority verification.');
      context.go('/heritage-passport/${Uri.encodeComponent(created.id)}');
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message);
    } catch (e) {
      if (mounted) showMsg(context, 'Registration failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) => InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: HC.emerald),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.creamDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.creamDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: HC.emerald, width: 2)),
      );

  Widget _gap() => const SizedBox(height: 14);

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return Column(children: [
          TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: _dec('Product name *', icon: Icons.inventory_2_outlined)),
          _gap(),
          TextField(controller: _description, maxLines: 5, minLines: 3, textCapitalization: TextCapitalization.sentences, decoration: _dec('Description *', hint: 'Describe the craft, its look and feel')),
        ]);
      case 1:
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final c in craftCategories)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _category = c),
              child: Container(
                width: (MediaQuery.of(context).size.width - 32 - 10) / 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _category == c ? HC.emerald : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _category == c ? HC.emerald : HC.creamDark, width: 2),
                ),
                child: Column(children: [
                  Text(c.icon, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 6),
                  Text(c.name, style: TextStyle(fontWeight: FontWeight.w700, color: _category == c ? Colors.white : HC.emeraldDark)),
                ]),
              ),
            ),
        ]);
      case 2:
        return Column(children: [
          TextField(controller: _artisanName, textCapitalization: TextCapitalization.words, decoration: _dec('Artisan name *', icon: Icons.person_outline_rounded)),
          _gap(),
          TextField(controller: _location, textCapitalization: TextCapitalization.words, decoration: _dec('Production location *', hint: 'e.g. Kuala Terengganu, Terengganu', icon: Icons.place_outlined)),
          _gap(),
          TextField(controller: _experience, decoration: _dec('Experience', hint: 'e.g. 25 years', icon: Icons.schedule_rounded)),
          _gap(),
          TextField(controller: _bio, maxLines: 4, minLines: 2, textCapitalization: TextCapitalization.sentences, decoration: _dec('About the artisan')),
        ]);
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add up to 4 clear photos of the finished product.', style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (var i = 0; i < _images.length; i++)
              Stack(clipBehavior: Clip.none, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(_images[i].bytes, width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(i)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ]),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AppButton(label: 'Camera', icon: Icons.photo_camera_rounded, style: BtnStyle.outline, onPressed: () => _pick(ImageSource.camera))),
            const SizedBox(width: 10),
            Expanded(child: AppButton(label: 'Gallery', icon: Icons.photo_library_rounded, style: BtnStyle.outline, onPressed: () => _pick(ImageSource.gallery))),
          ]),
        ]);
      case 4:
        return Column(children: [
          TextField(controller: _materials, decoration: _dec('Materials', hint: 'Silk, gold thread, ...', icon: Icons.category_outlined)),
          _gap(),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(1900), lastDate: DateTime.now());
              if (d != null) setState(() => _date = d);
            },
            child: InputDecorator(
              decoration: _dec('Production date', icon: Icons.calendar_today_outlined),
              child: Text(formatDate(_date), style: const TextStyle(fontSize: 16)),
            ),
          ),
          _gap(),
          TextField(controller: _method, maxLines: 3, minLines: 2, decoration: _dec('Production method', hint: 'Hand-woven using traditional ...')),
          _gap(),
          TextField(controller: _price, keyboardType: TextInputType.text, decoration: _dec('Price *', hint: 'RM 1,200', icon: Icons.sell_outlined)),
          _gap(),
          TextField(controller: _significance, maxLines: 4, minLines: 2, textCapitalization: TextCapitalization.sentences, decoration: _dec('Cultural significance')),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(
            child: Column(children: [
              InfoRow(icon: Icons.inventory_2_outlined, label: 'Product', value: _name.text.trim()),
              InfoRow(icon: Icons.auto_awesome, label: 'Category', value: _category?.name ?? ''),
              InfoRow(icon: Icons.person_outline_rounded, label: 'Artisan', value: _artisanName.text.trim()),
              InfoRow(icon: Icons.place_outlined, label: 'Location', value: _location.text.trim()),
              InfoRow(icon: Icons.calendar_today_outlined, label: 'Production date', value: formatDate(_date)),
              InfoRow(icon: Icons.sell_outlined, label: 'Price', value: _normalisedPrice()),
              InfoRow(icon: Icons.photo_library_outlined, label: 'Photos', value: '${_images.length} selected'),
            ]),
          ),
          const SizedBox(height: 12),
          AppCard(
            color: const Color(0xFFFEFCE8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFCA8A04)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'After submission your product receives a Heritage Passport with status "Pending Verification" until the Heritage Authority approves it.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.45),
                ),
              ),
            ]),
          ),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _step == _titles.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Product'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => goBack(context, fallback: '/artisan-dashboard')),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(_titles[_step], style: heading(21))),
              Text('Step ${_step + 1} of ${_titles.length}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
            ]),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_step + 1) / _titles.length,
                minHeight: 7,
                backgroundColor: HC.creamDark,
                valueColor: const AlwaysStoppedAnimation<Color>(HC.gold),
              ),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: _stepBody(),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.o(0.06), blurRadius: 10, offset: const Offset(0, -2))]),
          child: SafeArea(
            top: false,
            child: Row(children: [
              if (_step > 0) ...[
                Expanded(child: AppButton(label: 'Back', style: BtnStyle.outline, onPressed: _submitting ? null : () => setState(() => _step--))),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: AppButton(
                  label: last ? 'Submit for Verification' : 'Continue',
                  icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  style: last ? BtnStyle.gold : BtnStyle.emerald,
                  loading: _submitting,
                  onPressed: last ? _submit : _next,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
