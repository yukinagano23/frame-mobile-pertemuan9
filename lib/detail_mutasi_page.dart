// =============================================================
// FILE 2/3 : detail_mutasi_page.dart
// Halaman 2 - Detail & Mutasi Stok
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class DetailMutasiPage extends StatelessWidget {
  final String itemId;
  const DetailMutasiPage({super.key, required this.itemId});

  void _openSheet(BuildContext context, MutationType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MutasiSheet(itemId: itemId, initialType: type),
    );
  }

  Future<void> _editMinStock(BuildContext context, StockItem item) async {
    final ctrl = TextEditingController(text: '${item.minStock}');
    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Batas Minimum Stok'),
        content: QtyStepper(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<InventoryProvider>()
                  .updateMinStock(item.id, int.tryParse(ctrl.text) ?? 0);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, StockItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('"${item.name}" beserta riwayat mutasinya akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<InventoryProvider>();
    Navigator.pop(context);
    provider.removeItem(item.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final item = inv.byId(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail & Mutasi Stok')),
        body: const Center(child: Text('Barang tidak ditemukan')),
      );
    }

    final low = inv.isLow(item);
    final accent = low ? AppColors.danger : AppColors.success;
    final progress = item.minStock == 0
        ? 1.0
        : (item.stock / item.minStock).clamp(0.0, 1.0).toDouble();
    final history = item.history.take(10).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail & Mutasi Stok'),
        actions: [
          IconButton(
            tooltip: 'Hapus barang',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, item),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Kartu detail
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: low ? AppColors.dangerBg : AppColors.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: accent, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w700)),
                              if (low) const LowStockBadge(withIcon: true),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Satuan: ${item.unit} • ${item.category}',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => _editMinStock(context, item),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Ubah batas minimum',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Stok Saat Ini',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('${item.stock}',
                                    style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        color: accent)),
                                const SizedBox(width: 6),
                                Text(item.unit,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Batas minimum stok:',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text('${item.minStock} ${item.unit}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: accent,
                    backgroundColor: AppColors.surfaceGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 ${item.unit}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted)),
                    Text(low ? 'Perlu segera restok' : 'Stok aman',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: accent)),
                    Text('${item.minStock}+ ${item.unit}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol cepat
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add,
                  label: 'Barang Masuk',
                  color: AppColors.masuk,
                  onTap: () => _openSheet(context, MutationType.masuk),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.remove,
                  label: 'Barang Keluar',
                  color: AppColors.keluar,
                  onTap: () => _openSheet(context, MutationType.keluar),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Riwayat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Mutasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('${history.length} catatan terakhir',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada riwayat mutasi',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...history.map((m) => _MutationTile(mutation: m, unit: item.unit)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _MutationTile extends StatelessWidget {
  final Mutation mutation;
  final String unit;
  const _MutationTile({required this.mutation, required this.unit});

  @override
  Widget build(BuildContext context) {
    final masuk = mutation.type == MutationType.masuk;
    final color = masuk ? AppColors.masuk : AppColors.keluar;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: masuk ? AppColors.successBg : AppColors.keluarBg,
              shape: BoxShape.circle,
            ),
            child: Icon(masuk ? Icons.arrow_downward : Icons.arrow_upward,
                color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mutation.note,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(formatMutationDate(mutation.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${masuk ? '+' : '-'}${mutation.qty} $unit',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// BOTTOM SHEET : Catat Barang Masuk / Keluar
// ---------------------------------------------------------------
class MutasiSheet extends StatefulWidget {
  final String itemId;
  final MutationType initialType;
  const MutasiSheet({super.key, required this.itemId, required this.initialType});

  @override
  State<MutasiSheet> createState() => _MutasiSheetState();
}

class _MutasiSheetState extends State<MutasiSheet> {
  late MutationType _type = widget.initialType;
  final _qtyCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // Validasi langsung saat jumlah / tipe berubah
  void _validate(StockItem item) {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    String? err;
    if (qty <= 0) {
      err = 'Jumlah harus lebih dari 0';
    } else if (_type == MutationType.keluar && qty > item.stock) {
      err = 'Jumlah melebihi stok tersedia (${item.stock} ${item.unit})';
    }
    setState(() => _error = err);
  }

  void _save(StockItem item) {
    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    final err = context
        .read<InventoryProvider>()
        .addMutation(item.id, _type, qty, _noteCtrl.text);

    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Stok berhasil diperbarui'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final item = inv.byId(widget.itemId)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFC4C6D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catat Barang Masuk / Keluar',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                          children: [
                            TextSpan(text: '${item.name} • Tersedia: '),
                            TextSpan(
                              text: '${item.stock}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                            TextSpan(text: ' ${item.unit}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Toggle Masuk / Keluar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _typeButton(item, 'Barang Masuk', Icons.arrow_downward,
                      MutationType.masuk, AppColors.masuk),
                  _typeButton(item, 'Barang Keluar', Icons.arrow_upward,
                      MutationType.keluar, AppColors.keluar),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text('Jumlah (${item.unit})',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            QtyStepper(
              controller: _qtyCtrl,
              min: 1,
              errorText: _error,
              onChanged: (_) => _validate(item),
            ),
            const SizedBox(height: 16),

            const Text('Catatan (opsional)',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Contoh: Dari supplier A',
                filled: true,
                fillColor: AppColors.surfaceGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _error == null ? () => _save(item) : null,
                icon: const Icon(Icons.check),
                label: const Text('Simpan',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(StockItem item, String label, IconData icon,
      MutationType type, Color activeColor) {
    final selected = _type == type;
    return Expanded(
      child: Material(
        color: selected ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            _type = type;
            _validate(item);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textMuted,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}