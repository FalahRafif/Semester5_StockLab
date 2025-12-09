import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import 'edit_product.dart';
import 'add_product.dart';
import 'dart:math';

class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage>
    with SingleTickerProviderStateMixin {

  // Dummy Data Produk
  final List<Map<String, String>> allProducts = List.generate(
    250,
        (i) => {
      "name": "Produk ${i + 1}",
      "category": (i % 2 == 0) ? "Elektronik" : "Fashion",
    },
  );

  bool showMenu = false;
  late AnimationController menuController;
  bool showFilter = false;

  final TextEditingController filterName = TextEditingController();
  final TextEditingController filterCategory = TextEditingController();

  List<Map<String, String>> filteredProducts = [];
  bool isFiltered = false;

  final int pageSize = 8;
  int pageIndex = 0;

  List<Map<String, String>> get paginatedProducts {
    final source = isFiltered ? filteredProducts : allProducts;

    final start = pageIndex * pageSize;
    final end = (start + pageSize) > source.length
        ? source.length
        : (start + pageSize);

    return source.sublist(start, end);
  }

  void applyFilter() {
    final name = filterName.text.toLowerCase();
    final category = filterCategory.text.toLowerCase();

    setState(() {
      filteredProducts = allProducts.where((p) {
        final matchName = name.isEmpty || p["name"]!.toLowerCase().contains(name);
        final matchCategory = category.isEmpty || p["category"]!.toLowerCase().contains(category);
        return matchName && matchCategory;
      }).toList();

      isFiltered = true;
      pageIndex = 0;
    });
  }

  Future<bool> _confirmDelete(BuildContext context, String productName) async {
    return await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
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
                    Text("Hapus Produk",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.textDark,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      "Apakah kamu yakin ingin menghapus produk \"$productName\"?",
                      style: TextStyle(
                          fontSize: 14.5,
                          color: ColorManager.textDark.withOpacity(0.75)),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: const Text("Hapus",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    )
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Product Management",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: ColorManager.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage all products in the system.",
                    style: TextStyle(
                        fontSize: 14,
                        color: ColorManager.textDark.withOpacity(0.55)),
                  ),
                  const SizedBox(height: 22),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: paginatedProducts.length,
                      itemBuilder: (context, i) {
                        final p = paginatedProducts[i];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: ColorManager.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ColorManager.borderSoft),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.shadowLightBlue,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                ColorManager.primary.withOpacity(0.12),
                                child: Text(
                                  p["name"]![0],
                                  style: TextStyle(
                                      color: ColorManager.primary,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p["name"]!,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p["category"]!,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: ColorManager.textDark
                                              .withOpacity(0.55)),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    color: ColorManager.primary),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MobileWrapper(
                                              child: ProductEditPage(
                                                productName: p["name"]!,
                                                category: p["category"]!,
                                              )),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm =
                                  await _confirmDelete(
                                      context, p["name"]!);

                                  if (confirm) {
                                    setState(() {
                                      allProducts.remove(p);
                                      if (isFiltered)
                                        filteredProducts.remove(p);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  _paginationWindow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // FLOATING ADD + MENU
            Positioned(
              top: 18,
              right: 18,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMenu = !showMenu;
                    showMenu
                        ? menuController.forward()
                        : menuController.reverse();
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
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: showMenu ? 0.125 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 82,
              right: 18,
              child: SizeTransition(
                sizeFactor: CurvedAnimation(
                    parent: menuController, curve: Curves.easeOut),
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: menuController,
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 14),
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
                          label: "Filter Produk",
                          onTap: () {
                            setState(() {
                              showMenu = false;
                              menuController.reverse();
                              showFilter = true;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _menuItem(
                          icon: Icons.add_box_rounded,
                          label: "Add Produk",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MobileWrapper(
                                  child: ProductAddPage(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FILTER PANEL
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
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
                        offset: const Offset(4, 0))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Filter Produk",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ColorManager.textDark)),

                    const SizedBox(height: 20),

                    Text("Nama Produk",
                        style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    _filterInput(controller: filterName),

                    const SizedBox(height: 18),

                    Text("Kategori",
                        style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    _filterInput(controller: filterCategory),

                    const SizedBox(height: 28),

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
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Cari",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => showFilter = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: ColorManager.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Tutup",
                            style: TextStyle(color: ColorManager.textDark)),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filterName.clear();
                            filterCategory.clear();
                            isFiltered = false;
                            filteredProducts.clear();
                            pageIndex = 0;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: ColorManager.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Reset Filter",
                            style: TextStyle(color: ColorManager.textDark)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      {required IconData icon,
        required String label,
        required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorManager.textDark),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: ColorManager.textDark))
        ],
      ),
    );
  }

  Widget _paginationWindow() {
    final source = isFiltered ? filteredProducts : allProducts;
    if (source.isEmpty) return const SizedBox();

    final totalPages = ((source.length - 1) / pageSize).floor() + 1;

    if (totalPages == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: ColorManager.primary,
            borderRadius: BorderRadius.circular(10)),
        child: const Text("1",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }

    if (pageIndex >= totalPages) pageIndex = totalPages - 1;
    if (pageIndex < 0) pageIndex = 0;

    List<int> visible = [];
    visible.add(0);

    final start = max(1, pageIndex - 1);
    final end = min(totalPages - 2, pageIndex + 1);

    for (int i = start; i <= end; i++) {
      visible.add(i);
    }

    visible.add(totalPages - 1);
    visible = visible.toSet().toList()..sort();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: visible.map((i) {
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
                      : ColorManager.borderSoft),
            ),
            child: Text("${i + 1}",
                style: TextStyle(
                    color:
                    active ? Colors.white : ColorManager.textDark,
                    fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }

  Widget _filterInput({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.border),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
