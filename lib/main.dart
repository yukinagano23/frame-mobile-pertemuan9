// =============================================================
// FILE 1/3 : main.dart
// Isi: entry point, tema, model data, state management (Provider),
//      widget bersama, dan Halaman 1 - Daftar Stok.
// =============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'detail_mutasi_page.dart';
import 'tambah_barang_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: const StokKuApp(),
    ),
  );
}

// ---------------------------------------------------------------
// WARNA
// ---------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF1E5EFF);
  static const background = Color(0xFFF6F7F9);
  static const surfaceGrey = Color(0xFFF1F2F4);
  static const danger = Color(0xFFC62828);
  static const dangerBg = Color(0xFFFFDAD6);
  static const success = Color(0xFF188038);
  static const successBg = Color(0xFF9CF59E);
  static const masuk = Color(0xFF006E2C);
  static const keluar = Color(0xFF7A4A00);
  static const keluarBg = Color(0xFFFFDDB8);
  static const textMuted = Color(0xFF44474E);
}

// ---------------------------------------------------------------
// MODEL
// ---------------------------------------------------------------
enum MutationType { masuk, keluar }

class Mutation {
  final MutationType type;
  final int qty;
  final String note;
  final DateTime date;
  Mutation({
    required this.type,
    required this.qty,
    required this.note,
    required this.date,
  });
}

class StockItem {
  final String id;
  String name;
  String unit;
  String category;
  int stock;
  int minStock;
  IconData icon;
  final List<Mutation> history; // terbaru di indeks 0

  StockItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.stock,
    required this.minStock,
    required this.icon,
    List<Mutation>? history,
  }) : history = history ?? [];
}

// ---------------------------------------------------------------
// STATE MANAGEMENT (ChangeNotifier + Provider)
// ---------------------------------------------------------------
enum StockFilter { semua, menipis }

class InventoryProvider extends ChangeNotifier {
  final List<StockItem> _items = _seed();
  StockFilter _filter = StockFilter.semua;
  String _query = '';
  int _nextId = 6;

  StockFilter get filter => _filter;

  // Stok dianggap menipis jika jumlahnya di bawah batas minimum
  bool isLow(StockItem i) => i.stock < i.minStock;

  int get totalCount => _items.length;
  int get lowCount => _items.where(isLow).length;
  bool get hasQuery => _query.trim().isNotEmpty;

  List<StockItem> get visibleItems {
    Iterable<StockItem> r = _items;
    if (_filter == StockFilter.menipis) r = r.where(isLow);
    if (hasQuery) {
      final q = _query.trim().toLowerCase();
      r = r.where((i) => i.name.toLowerCase().contains(q));
    }
    return r.toList();
  }

  StockItem? byId(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  void setFilter(StockFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void addItem({
    required String name,
    required String unit,
    required int initialStock,
    required int minStock,
  }) {
    final item = StockItem(
      id: '${_nextId++}',
      name: name.trim(),
      unit: unit,
      category: 'Umum',
      stock: initialStock,
      minStock: minStock,
      icon: Icons.inventory_2_outlined,
    );
    if (initialStock > 0) {
      item.history.add(Mutation(
        type: MutationType.masuk,
        qty: initialStock,
        note: 'Stok awal',
        date: DateTime.now(),
      ));
    }
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void updateMinStock(String id, int value) {
    final item = byId(id);
    if (item == null) return;
    item.minStock = value;
    notifyListeners();
  }

  /// Mengembalikan pesan error (String) bila gagal, atau null bila sukses.
  String? addMutation(String id, MutationType type, int qty, String note) {
    final item = byId(id);
    if (item == null) return 'Barang tidak ditemukan';
    if (qty <= 0) return 'Jumlah harus lebih dari 0';
    if (type == MutationType.keluar && qty > item.stock) {
      return 'Jumlah melebihi stok tersedia (${item.stock} ${item.unit})';
    }
    item.stock += type == MutationType.masuk ? qty : -qty;
    item.history.insert(
      0,
      Mutation(
        type: type,
        qty: qty,
        note: note.trim().isEmpty
            ? (type == MutationType.masuk ? 'Barang masuk' : 'Barang keluar')
            : note.trim(),
        date: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  static List<StockItem> _seed() {
    final now = DateTime.now();
    DateTime at(int daysAgo, int h, int m) =>
        DateTime(now.year, now.month, now.day - daysAgo, h, m);

    return [
      StockItem(
        id: '1',
        name: 'Beras 5 kg',
        unit: 'kg',
        category: 'Sembako',
        stock: 3,
        minStock: 10,
        icon: Icons.rice_bowl_outlined,
        history: [
          Mutation(type: MutationType.keluar, qty: 4, note: 'Penjualan harian', date: at(0, 14, 30)),
          Mutation(type: MutationType.keluar, qty: 3, note: 'Penjualan harian', date: at(1, 16, 10)),
          Mutation(type: MutationType.masuk, qty: 10, note: 'Dari supplier A', date: at(3, 9, 0)),
        ],
      ),
      StockItem(
        id: '2',
        name: 'Minyak Goreng 1 L',
        unit: 'liter',
        category: 'Sembako',
        stock: 25,
        minStock: 10,
        icon: Icons.water_drop_outlined,
        history: [
          Mutation(type: MutationType.masuk, qty: 30, note: 'Dari supplier B', date: at(2, 10, 15)),
        ],
      ),
      StockItem(
        id: '3',
        name: 'Gula Pasir',
        unit: 'kg',
        category: 'Sembako',
        stock: 4,
        minStock: 8,
        icon: Icons.kitchen_outlined,
        history: [
          Mutation(type: MutationType.keluar, qty: 6, note: 'Penjualan harian', date: at(1, 13, 5)),
        ],
      ),
      StockItem(
        id: '4',
        name: 'Telur',
        unit: 'kg',
        category: 'Sembako',
        stock: 40,
        minStock: 15,
        icon: Icons.egg_alt_outlined,
        history: [
          Mutation(type: MutationType.masuk, qty: 40, note: 'Stok awal', date: at(4, 8, 0)),
        ],
      ),
      StockItem(
        id: '5',
        name: 'Kopi Sachet',
        unit: 'pcs',
        category: 'Minuman',
        stock: 6,
        minStock: 20,
        icon: Icons.coffee_outlined,
        history: [
          Mutation(type: MutationType.keluar, qty: 14, note: 'Penjualan mingguan', date: at(2, 17, 40)),
        ],
      ),
    ];
  }
}

// ---------------------------------------------------------------
// APP
// ---------------------------------------------------------------
class StokKuApp extends StatelessWidget {
  const StokKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StokKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF191C20),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const DaftarStokPage(),
    );
  }
}

// ---------------------------------------------------------------
// WIDGET BERSAMA
// ---------------------------------------------------------------
class LowStockBadge extends StatelessWidget {
  final bool withIcon;
  const LowStockBadge({super.key, this.withIcon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.danger),
            const SizedBox(width: 4),
          ],
          const Text(
            'Stok Menipis',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Input angka dengan tombol stepper (- / +)
class QtyStepper extends StatelessWidget {
  final TextEditingController controller;
  final int min;
  final String? errorText;
  final ValueChanged<int>? onChanged;

  const QtyStepper({
    super.key,
    required this.controller,
    this.min = 0,
    this.errorText,
    this.onChanged,
  });

  int get _current => int.tryParse(controller.text) ?? min;

  void _set(int v) {
    final nv = v < min ? min : v;
    controller.text = '$nv';
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    onChanged?.call(nv);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: hasError ? 1.5 : 1),
        );
    final borderColor = hasError ? AppColors.danger : const Color(0xFFC4C6D0);

    Widget btn(IconData icon, VoidCallback onTap, Color bg) => Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: const Color(0xFF191C20)),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            btn(Icons.remove, () => _set(_current - 1), AppColors.surfaceGrey),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  onChanged: (t) => onChanged?.call(int.tryParse(t) ?? 0),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceGrey,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: border(borderColor),
                    focusedBorder:
                        border(hasError ? AppColors.danger : AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            btn(Icons.add, () => _set(_current + 1), const Color(0xFFDDE1FF)),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

String formatMutationDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  final time =
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  if (diff == 0) return 'Hari ini, $time';
  if (diff == 1) return 'Kemarin, $time';
  const bln = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${d.day} ${bln[d.month - 1]} ${d.year}, $time';
}

// ---------------------------------------------------------------
// HALAMAN 1 : DAFTAR STOK
// ---------------------------------------------------------------
class DaftarStokPage extends StatelessWidget {
  const DaftarStokPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final items = inv.visibleItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Stok')), // tanpa ikon profil
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TambahBarangPage()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Pencarian
          TextField(
            onChanged: inv.setQuery,
            decoration: InputDecoration(
              hintText: 'Cari barang (cth: Beras, Kopi)...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ringkasan
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Barang',
                  value: inv.totalCount,
                  valueColor: const Color(0xFF191C20),
                  icon: Icons.inventory_2_outlined,
                  iconColor: AppColors.primary,
                  iconBg: const Color(0xFFDDE1FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Stok Menipis',
                  value: inv.lowCount,
                  valueColor: AppColors.danger,
                  icon: Icons.warning_rounded,
                  iconColor: AppColors.danger,
                  iconBg: AppColors.dangerBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter
          Row(
            children: [
              _FilterChipButton(
                label: 'Semua',
                selected: inv.filter == StockFilter.semua,
                onTap: () => inv.setFilter(StockFilter.semua),
              ),
              const SizedBox(width: 8),
              _FilterChipButton(
                label: 'Stok Menipis (${inv.lowCount})',
                showDot: true,
                selected: inv.filter == StockFilter.menipis,
                onTap: () => inv.setFilter(StockFilter.menipis),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daftar / Empty state
          if (items.isEmpty)
            _EmptyState(inv: inv)
          else
            ...items.map((i) => _StockCard(item: i, low: inv.isLow(i))),

        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text('$value',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: valueColor)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF191C20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final StockItem item;
  final bool low;
  const _StockCard({required this.item, required this.low});

  @override
  Widget build(BuildContext context) {
    final accent = low ? AppColors.danger : AppColors.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => DetailMutasiPage(itemId: item.id)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      width: 5, color: low ? AppColors.danger : Colors.transparent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: low ? AppColors.dangerBg : AppColors.successBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: accent),
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                    if (low) const LowStockBadge(),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Satuan: ${item.unit} • Min. stok: ${item.minStock}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${item.stock}',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: accent)),
                              Text(item.unit,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final InventoryProvider inv;
  const _EmptyState({required this.inv});

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;
    late final Color bg;
    late final String title;
    late final String subtitle;

    if (inv.hasQuery) {
      icon = Icons.search_off_rounded;
      color = AppColors.textMuted;
      bg = AppColors.surfaceGrey;
      title = 'Barang tidak ditemukan';
      subtitle = 'Coba gunakan kata kunci lain.';
    } else if (inv.totalCount == 0) {
      icon = Icons.inventory_2_outlined;
      color = AppColors.primary;
      bg = const Color(0xFFDDE1FF);
      title = 'Belum ada barang';
      subtitle = 'Tekan tombol "Tambah Barang" untuk mulai mencatat stok.';
    } else {
      icon = Icons.check_circle_outline_rounded;
      color = AppColors.success;
      bg = AppColors.successBg;
      title = 'Semua stok aman 🎉';
      subtitle = 'Tidak ada barang di bawah batas minimum.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}