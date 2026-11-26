// =============================================================
// FILE 3/3 : tambah_barang_page.dart
// Halaman 3 - Tambah Barang Baru
// =============================================================
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class TambahBarangPage extends StatefulWidget {
  const TambahBarangPage({super.key});

  @override
  State<TambahBarangPage> createState() => _TambahBarangPageState();
}

class _TambahBarangPageState extends State<TambahBarangPage> {
  static const _units = ['pcs', 'kg', 'liter', 'dus', 'pak'];

  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _minCtrl = TextEditingController(text: '5');
  String _unit = 'pcs';
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _nameError = 'Nama barang wajib diisi');
      return;
    }
    context.read<InventoryProvider>().addItem(
          name: _nameCtrl.text,
          unit: _unit,
          initialStock: int.tryParse(_stockCtrl.text) ?? 0,
          minStock: int.tryParse(_minCtrl.text) ?? 0,
        );

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil ditambahkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Baru')), // tanpa ikon profil
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Banner info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.inventory_2_outlined, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lengkapi data barang agar stok warung lebih mudah dipantau.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Nama Barang', required: true),
                TextField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  decoration: InputDecoration(
                    hintText: 'Contoh: Minyak Goreng Bimoli 1L',
                    errorText: _nameError,
                    suffixIcon: _nameError != null
                        ? const Icon(Icons.error_outline,
                            color: AppColors.danger)
                        : null,
                    filled: true,
                    fillColor:
                        _nameError != null ? const Color(0xFFFFF4F3) : AppColors.surfaceGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _nameError != null
                            ? AppColors.danger
                            : const Color(0xFFC4C6D0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _nameError != null
                            ? AppColors.danger
                            : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Satuan'),
                DropdownButtonFormField<String>(
                  initialValue: _unit,
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v ?? _unit),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                const _Label('Stok Awal'),
                QtyStepper(controller: _stockCtrl),
                const SizedBox(height: 16),

                const _Label('Batas Minimum Stok'),
                QtyStepper(controller: _minCtrl),
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 2),
                  child: Text(
                    'Anda akan diberi peringatan jika stok di bawah angka ini',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                Text.rich(
                  const TextSpan(
                    text: 'Foto Barang ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(
                          text: '(opsional)',
                          style: TextStyle(fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _PhotoPicker(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Pemilih foto belum dihubungkan (tambahkan paket image_picker).'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontWeight: FontWeight.w600),
          children: [
            if (required)
              const TextSpan(
                  text: ' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final VoidCallback onTap;
  const _PhotoPicker({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFDDE1FF),
                child: Icon(Icons.photo_camera_outlined,
                    color: AppColors.primary),
              ),
              SizedBox(height: 8),
              Text('Ketuk untuk unggah foto',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('JPG atau PNG, maks. 5 MB',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC4C6D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)));

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}