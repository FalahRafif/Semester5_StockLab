import 'package:flutter/material.dart';
import '../../../shared/core/color_manager.dart';
import 'edit_user.dart';
import 'add_user.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import 'dart:math';

class ListUserPage extends StatefulWidget {
  const ListUserPage({super.key});

  @override
  State<ListUserPage> createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage>
    with SingleTickerProviderStateMixin {
  // Dummy Data
  final List<Map<String, String>> allUsers = List.generate(
    360,
        (i) => {
      "name": "User ${i + 1}",
      "email": "user${i + 1}@example.com",
    },
  );

  bool showMenu = false;
  late AnimationController menuController;
  bool showFilter = false;

  final TextEditingController filterEmail = TextEditingController();
  final TextEditingController filterName = TextEditingController();

  List<Map<String, String>> filteredUsers = [];
  bool isFiltered = false;

  final int pageSize = 8;
  int pageIndex = 0;

  List<Map<String, String>> get paginatedUsers {
    final source = isFiltered ? filteredUsers : allUsers;

    final start = pageIndex * pageSize;
    final end = (start + pageSize) > source.length
        ? source.length
        : (start + pageSize);

    return source.sublist(start, end);
  }

  void applyFilter() {
    final name = filterName.text.toLowerCase();
    final email = filterEmail.text.toLowerCase();

    setState(() {
      filteredUsers = allUsers.where((u) {
        final matchName = name.isEmpty || u["name"]!.toLowerCase().contains(name);
        final matchEmail = email.isEmpty || u["email"]!.toLowerCase().contains(email);
        return matchName && matchEmail;
      }).toList();

      isFiltered = true;
      pageIndex = 0; // reset ke halaman pertama
    });
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
                  // HEADER
                  Text(
                    "User Management",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: ColorManager.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage all registered users in the system.",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorManager.textDark.withOpacity(0.55),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // LIST USER
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: paginatedUsers.length,
                      itemBuilder: (context, i) {
                        final u = paginatedUsers[i];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: ColorManager.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColorManager.borderSoft,
                            ),
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
                                  u["name"]![0],
                                  style: TextStyle(
                                    color: ColorManager.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u["name"]!,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      u["email"]!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ColorManager.textDark
                                            .withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined,
                                    color: ColorManager.primary, size: 22),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MobileWrapper(
                                        child: UserEditPage(
                                          name: u["name"]!,
                                          email: u["email"]!,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 22),
                                onPressed: () {},
                              )
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

            // --------------------------------------------------------------------
            // FLOAT BUTTON (TOP RIGHT)
            // --------------------------------------------------------------------
            Positioned(
              top: 18,
              right: 18,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showMenu = !showMenu;
                    if (showMenu) {
                      menuController.forward();
                    } else {
                      menuController.reverse();
                    }
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
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),

            // --------------------------------------------------------------------
            // FLOATING MENU OPTIONS (MODERN, CLEAN)
            // --------------------------------------------------------------------
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
                          label: "Filter User",
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
                          icon: Icons.person_add_alt_1,
                          label: "Add User",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      MobileWrapper(child: UserAddPage())),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ─────────────────────────────────────────────────────────────
            // LEFT FILTER PANEL — modern clean
            // ─────────────────────────────────────────────────────────────
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
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter User",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.textDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Input Username
                    Text("Username", style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    _filterInput(controller: filterName),

                    const SizedBox(height: 18),

                    // Input Email
                    Text("Email", style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    _filterInput(controller: filterEmail),

                    const SizedBox(height: 28),

                    // BUTTON CARI
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TEMPORARY: hanya tutup panel
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
                        child: const Text("Cari",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // BUTTON TUTUP
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
                        child: Text("Tutup",
                            style: TextStyle(color: ColorManager.textDark)),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            filterName.clear();
                            filterEmail.clear();
                            isFiltered = false;
                            filteredUsers.clear();
                            pageIndex = 0;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: ColorManager.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Reset Filter",
                            style: TextStyle(color: ColorManager.textDark)),
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

  // Small menu item widget
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: ColorManager.textDark,
            ),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Modern Pagination — Windowed Style
  // ----------------------------------------------------------------
  Widget _paginationWindow() {
    final source = isFiltered ? filteredUsers : allUsers;

    if (source.isEmpty) return const SizedBox(); // safeguard jika list kosong

    final totalPages = ((source.length - 1) / pageSize).floor() + 1;

    // FIX: Jika hanya ada 1 halaman, langsung return 1 saja
    if (totalPages == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorManager.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "1",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    // Safety: pastikan pageIndex tidak out of range
    if (pageIndex >= totalPages) {
      pageIndex = totalPages - 1;
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? ColorManager.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                active ? ColorManager.primary : ColorManager.borderSoft,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

}
