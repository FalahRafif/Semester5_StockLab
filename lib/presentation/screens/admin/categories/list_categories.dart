import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';
import 'dart:math';

// CATEGORY
import '../../../../application/category_manager.dart';
import '../../../../data/models/category_response.dart';
import 'add_category.dart';
import 'edit_category.dart';

class ListCategoryPage extends StatefulWidget {
  const ListCategoryPage({super.key});

  @override
  State<ListCategoryPage> createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage>
    with SingleTickerProviderStateMixin {
  final CategoryManager categoryManager = CategoryManager();

  List<Map<String, String?>> allCategories = [];
  List<Map<String, String?>> filteredCategories = [];

  bool isLoading = true;
  bool isFiltered = false;

  final int pageSize = 8;
  int pageIndex = 0;

  bool showMenu = false;
  bool showFilter = false;
  late AnimationController menuController;

  final TextEditingController filterName = TextEditingController();

  List<Map<String, String?>> get paginatedCategories {
    final source = isFiltered ? filteredCategories : allCategories;
    final start = pageIndex * pageSize;
    final end = min(start + pageSize, source.length);
    return source.sublist(start, end);
  }

  void applyFilter() {
    final name = filterName.text.toLowerCase();

    setState(() {
      filteredCategories = allCategories.where((c) {
        return name.isEmpty ||
            c['name']!.toLowerCase().contains(name);
      }).toList();

      isFiltered = true;
      pageIndex = 0;
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
      isFiltered = false;
      filteredCategories.clear();
      pageIndex = 0;
    });

    try {
      final result = await categoryManager.getCategories();
      if (!mounted) return;

      if (result.success) {
        setState(() {
          allCategories = result.categories.map((c) => {
            "id": c.id.toString(),
            "name": c.name,
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result.message)));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Gagal memuat kategori")));
    }
  }


  Future<bool> _confirmDelete(BuildContext context, String name) async {
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
                    Text(
                      "Hapus Kategori",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Apakah kamu yakin ingin menghapus kategori \"$name\"?",
                      style: TextStyle(
                        color: ColorManager.textDark.withOpacity(0.75),
                        fontSize: 14.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
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
    ) ?? false;
  }

  @override
  void initState() {
    super.initState();
    menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Management",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage all product categories.",
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
                      padding:
                      const EdgeInsets.only(bottom: 80),
                      itemCount: paginatedCategories.length,
                      itemBuilder: (context, i) {
                        final c = paginatedCategories[i];

                        return Container(
                          margin:
                          const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color:
                            ColorManager.cardBackground,
                            borderRadius:
                            BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                ColorManager.borderSoft),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager
                                    .shadowLightBlue,
                                blurRadius: 12,
                                offset:
                                const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                ColorManager.primary
                                    .withOpacity(0.12),
                                child: Text(
                                  c['name']![0]
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color:
                                    ColorManager.primary,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  c['name']!,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    ColorManager.textDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: ColorManager.primary),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MobileWrapper(
                                        child: CategoryEditPage(
                                          id: c['id']!,
                                          name: c['name']!,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  final confirm =
                                  await _confirmDelete(
                                      context,
                                      c['name']!);
                                  if (!confirm) return;

                                  final id =
                                      int.tryParse(
                                          c['id']!) ??
                                          0;
                                  if (id == 0) return;

                                  final messenger = ScaffoldMessenger.of(context);

                                  setState(() => isLoading = true);

                                  final result = await categoryManager.deleteCategory(id: id.toString());
                                  print(id);
                                  if (!mounted) return;

                                  setState(() => isLoading = false);

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(result.message),
                                      backgroundColor: result.success ? Colors.green : Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );

                                  if (result.success) {
                                    // tunggu snackbar tampil
                                    await Future.delayed(const Duration(seconds: 2));

                                    await _loadCategories();
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  _paginationWindow(),
                ],
              ),
            ),

            // FLOAT BUTTON (TOP RIGHT)
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
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: showMenu ? 0.125 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),

            // FLOATING MENU OPTIONS
            Positioned(
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
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
                          label: "Filter Category",
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
                          icon: Icons.add_box_outlined,
                          label: "Add Category",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MobileWrapper(
                                  child: CategoryAddPage(),
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


            // FILTER PANEL (LEFT)
            AnimatedPositioned(
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
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Category",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("Category Name"),
                    const SizedBox(height: 6),
                    _filterInput(controller: filterName),

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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cari",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => showFilter = false),
                        child: const Text("Tutup"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filterName.clear();
                            isFiltered = false;
                            filteredCategories.clear();
                            pageIndex = 0;
                          });
                        },
                        child: const Text("Reset Filter"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationWindow() {
    final source =
    isFiltered ? filteredCategories : allCategories;
    if (source.isEmpty) return const SizedBox();

    final totalPages =
        ((source.length - 1) / pageSize).floor() + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = pageIndex == i;
        return GestureDetector(
          onTap: () => setState(() => pageIndex = i),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? ColorManager.primary
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${i + 1}',
              style: TextStyle(
                color:
                active ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: ColorManager.textDark),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: ColorManager.textDark,
            ),
          ),
        ],
      ),
    );
  }


}

