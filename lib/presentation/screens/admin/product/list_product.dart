import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';

import '../../../../application/product_manager.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'edit_stock_product.dart';
import '../../../../data/models/product_response.dart';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}
enum _ProductMenuAction {
  edit,
  stock,
  delete,
}

class _ListProductPageState extends State<ListProductPage>
    with SingleTickerProviderStateMixin {
  final ProductManager productManager = ProductManager();

  List<Map<String, String?>> allProducts = [];
  List<Map<String, String?>> filteredProducts = [];

  bool isLoading = true;
  bool isFiltered = false;

  // MENU & FILTER
  bool isMenuOpen = false;
  bool showFilter = false;
  late AnimationController menuController;

  final TextEditingController filterName = TextEditingController();
  final TextEditingController filterBrand = TextEditingController();

  // PAGINATION
  final int pageSize = 8;
  int pageIndex = 0;

  List<Map<String, String?>> get paginatedProducts {
    final source = isFiltered ? filteredProducts : allProducts;
    final start = pageIndex * pageSize;
    final end = min(start + pageSize, source.length);
    return source.sublist(start, end);
  }

  String formatPrice(int value) {
    return "Rp ${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
    )}";
  }

  // ------------------------------------------------------------
  // LOAD
  // ------------------------------------------------------------
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      isFiltered = false;
      filteredProducts.clear();
      pageIndex = 0;
    });

    final result = await productManager.getProducts();
    if (!mounted) return;

    if (result.success) {
      setState(() {
        allProducts = result.products.map((p) {
          final totalValue = p.price * p.quantity;

          return {
            "id": p.id.toString(),
            "name": p.name,
            "brand": p.brand,
            "categoryId": p.category,
            "avatar": p.image,
            "price": p.price.toString(),        // price per unit
            "quantity": p.quantity.toString(),  // ✅ NEW
            "total": totalValue.toString(),     // ✅ NEW
          };
        }).toList();

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _toast(result.message, error: true);
    }
  }

  // ------------------------------------------------------------
  // FILTER
  // ------------------------------------------------------------
  void applyFilter() {
    final name = filterName.text.toLowerCase();
    final brand = filterBrand.text.toLowerCase();

    setState(() {
      filteredProducts = allProducts.where((p) {
        final matchName =
            name.isEmpty || p["name"]!.toLowerCase().contains(name);
        final matchBrand =
            brand.isEmpty || p["brand"]!.toLowerCase().contains(brand);
        return matchName && matchBrand;
      }).toList();

      isFiltered = true;
      pageIndex = 0;
    });
  }

  void resetFilter() {
    setState(() {
      filterName.clear();
      filterBrand.clear();
      isFiltered = false;
      filteredProducts.clear();
      pageIndex = 0;
    });
  }


  // ------------------------------------------------------------
  // IMAGE
  // ------------------------------------------------------------
  Uint8List? decodeAvatar(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    try {
      final pure =
      base64.contains(',') ? base64.split(',').last : base64;
      return base64Decode(pure);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String productName) async {
    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: 0.9 + (anim1.value * 0.1),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      "Hapus Produk",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Apakah kamu yakin ingin menghapus produk \"$productName\"?",
                      style: TextStyle(
                        color: ColorManager.textDark.withOpacity(0.75),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: ColorManager.textDark,
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 6),

                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shadowColor: Colors.redAccent.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: const Text(
                            "Hapus",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _loadProducts();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: Stack(
          children: [
            _mainContent(),
            _topAddButton(),
            _floatingMenu(),
            _filterPanel(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================
  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Management",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ColorManager.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Manage all products in the system.",
            style: TextStyle(
              fontSize: 14,
              color: ColorManager.textDark.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: 22),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: paginatedProducts.length,
              itemBuilder: (_, i) =>
                  _productCard(paginatedProducts[i]),
            ),
          ),

          _pagination(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================
  Widget _productCard(Map<String, String?> p) {
    final avatar = decodeAvatar(p["avatar"]);
    final price = int.tryParse(p["price"] ?? "0") ?? 0;
    final quantity = int.tryParse(p["quantity"] ?? "0") ?? 0;
    final total = int.tryParse(p["total"] ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= AVATAR =================
          // ================= IMAGE (20%) =================
          SizedBox(
            width: 72, // ±20% dari card (ideal untuk mobile)
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Container(
                color: ColorManager.primary.withOpacity(0.08),
                child: avatar != null
                    ? Image.memory(
                  avatar,
                  fit: BoxFit.cover,
                )
                    : Center(
                  child: Text(
                    p["name"]![0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),


          const SizedBox(width: 14),

          // ================= CONTENT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p["name"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  p["brand"]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _infoChip("Qty", quantity.toString(),
                        color: quantity > 0
                            ? Colors.orange
                            : Colors.redAccent),
                    _infoChip("Unit", formatPrice(price),
                        color: ColorManager.primary),
                  ],
                ),
              ],
            ),
          ),

          // ================= ACTIONS =================
          GestureDetector(
            onTapDown: (details) {
              _showProductMenu(
                context,
                details.globalPosition,
                p,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.more_vert_rounded,
                color: Colors.grey.shade700,
              ),
            ),
          ),


        ],
      ),
    );
  }


  // ============================================================
  // TOP RIGHT +
  // ============================================================
  Widget _topAddButton() {
    return Positioned(
      top: 18,
      right: 18,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isMenuOpen = !isMenuOpen;
            isMenuOpen ? menuController.forward() : menuController.reverse();
          });
        },
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: ColorManager.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorManager.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedRotation(
            turns: isMenuOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING MENU
  // ============================================================
  Widget _floatingMenu() {
    return Positioned(
      top: 82,
      right: 18,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: menuController,
          curve: Curves.easeOut,
        ),
        axisAlignment: -1,
        child: FadeTransition(
          opacity: menuController,
          child: Container(
            width: 180,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _menuItem(
                  icon: Icons.filter_alt_outlined,
                  label: "Filter Product",
                  onTap: () {
                    setState(() {
                      isMenuOpen = false;
                      showFilter = true;
                      menuController.reverse();
                    });
                  },
                ),
                const SizedBox(height: 12),
                _menuItem(
                  icon: Icons.add_box_outlined,
                  label: "Add Product",
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MobileWrapper(child: ProductAddPage()),
                      ),
                    );
                    if (result == true) _loadProducts();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
// FILTER PANEL (LEFT) — MATCH LIST USER
// ============================================================
  Widget _filterPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      left: showFilter ? 0 : -260,
      top: 0,
      bottom: 0,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(4, 0),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Product",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.textDark,
              ),
            ),

            const SizedBox(height: 20),

            // PRODUCT NAME
            Text("Product Name",
                style: TextStyle(color: ColorManager.textDark)),
            const SizedBox(height: 6),
            _filterInput(filterName),

            const SizedBox(height: 18),

            // BRAND
            Text("Brand", style: TextStyle(color: ColorManager.textDark)),
            const SizedBox(height: 6),
            _filterInput(filterBrand),

            const SizedBox(height: 28),

            // ===============================
            // BUTTON CARI
            // ===============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  applyFilter();
                  setState(() => showFilter = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cari",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===============================
            // BUTTON TUTUP / BATAL
            // ===============================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => showFilter = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: ColorManager.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Tutup",
                  style: TextStyle(color: ColorManager.textDark),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ===============================
            // BUTTON RESET FILTER
            // ===============================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: resetFilter,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: ColorManager.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Reset Filter",
                  style: TextStyle(color: ColorManager.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ============================================================
  // HELPERS
  // ============================================================
  Widget _menuItem(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorManager.textDark),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textDark)),
        ],
      ),
    );
  }

  Widget _filterInput(TextEditingController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.border),
      ),
      child: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _pagination() {
    final source = isFiltered ? filteredProducts : allProducts;
    if (source.length <= pageSize) return const SizedBox();

    final totalPages = ((source.length - 1) / pageSize).floor() + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = pageIndex == i;
        return GestureDetector(
          onTap: () => setState(() => pageIndex = i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? ColorManager.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? ColorManager.primary
                    : ColorManager.borderSoft,
              ),
            ),
            child: Text(
              "${i + 1}",
              style: TextStyle(
                color: active ? Colors.white : ColorManager.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _infoChip(String label, String value, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _menuItemRow({
    required IconData icon,
    required String label,
    Color color = Colors.black87,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showProductMenu(
      BuildContext context,
      Offset position,
      Map<String, String?> p,
      ) async {
    final selected = await showMenu<_ProductMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
        elevation: 0,
      items: [
        PopupMenuItem(
          value: _ProductMenuAction.edit,
          padding: EdgeInsets.zero,
          child: _modernMenuItem(
            icon: Icons.edit_outlined,
            label: "Edit Product",
          ),
        ),
        PopupMenuItem(
          value: _ProductMenuAction.stock,
          padding: EdgeInsets.zero,
          child: _modernMenuItem(
            icon: Icons.inventory_2_outlined,
            label: "Edit Stok Product",
          ),
        ),
        PopupMenuItem(
          value: _ProductMenuAction.delete,
          padding: EdgeInsets.zero,
          child: _modernMenuItem(
            icon: Icons.delete_outline,
            label: "Hapus Product",
            color: Colors.redAccent,
            danger: true,
          ),
        ),
      ],
    );

    if (selected == null) return;

    final id = int.parse(p["id"]!);

    switch (selected) {
      case _ProductMenuAction.edit:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MobileWrapper(
              child: ProductEditPage(
                id: id,
                name: p["name"]!,
                brand: p["brand"]!,
                categoryId: int.parse(p["categoryId"]!),
                avatarBase64: p["avatar"],
                price: int.parse(p["price"]!),
              ),
            ),
          ),
        );
        if (result == true) _loadProducts();
        break;

      case _ProductMenuAction.stock:
        final productData = ProductData(
          id: id,
          name: p["name"]!,
          brand: p["brand"]!,
          sku: '', // jika ada sku, isi sesuai data
          category: p["categoryId"]!,
          price: int.parse(p["price"]!),
          quantity: int.parse(p["quantity"]!),
          image: p["avatar"],
        );

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MobileWrapper(
              child: EditStockProductPage(product: productData),
            ),
          ),
        );
        if (result == true) _loadProducts();
        break;


      case _ProductMenuAction.delete:
        final confirm =
        await _confirmDelete(context, p["name"]!);
        if (!confirm) return;

        setState(() => isLoading = true);
        final result =
        await productManager.deleteProduct(id);
        setState(() => isLoading = false);

        _toast(result.message, error: !result.success);
        if (result.success) _loadProducts();
        break;
    }
  }

  Widget _modernMenuItem({
    required IconData icon,
    required String label,
    Color color = const Color(0xFF2C2C2C),
    bool danger = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: danger
            ? Colors.redAccent.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


}
