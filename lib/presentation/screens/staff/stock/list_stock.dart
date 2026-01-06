import 'package:flutter/material.dart';
import 'dart:math';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

// transaction
import '../../../../application/transaction_manager.dart';
import '../../../../data/models/transaction_response.dart';

// add transaction page (NANTI / placeholder)
import 'add_stock.dart';

class ListStockPage extends StatefulWidget {
  const ListStockPage({super.key});

  @override
  State<ListStockPage> createState() => _ListStockPageState();
}

class _ListStockPageState extends State<ListStockPage>
    with SingleTickerProviderStateMixin {
  final TransactionManager transactionManager = TransactionManager();

  List<TransactionData> allTransactions = [];

  bool isLoading = true;

  // floating menu
  bool showMenu = false;
  bool showFilter = false;
  late AnimationController menuController;

  // filter (API based)
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();

  // pagination
  final int pageSize = 8;
  int pageIndex = 0;

  List<TransactionData> get paginatedData {
    final start = pageIndex * pageSize;
    final end = min(start + pageSize, allTransactions.length);
    return allTransactions.sublist(start, end);
  }

  // ------------------------------------------------------------
  // LOAD DATA
  // ------------------------------------------------------------
  Future<void> _loadTransactions({
    String? startDate,
    String? endDate,
  }) async {
    setState(() {
      isLoading = true;
      pageIndex = 0;
    });

    final result = await transactionManager.getTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        allTransactions = result.transactions;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  Future<void> _pickDate(
      TextEditingController controller,
      ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          picked.toIso8601String().substring(0, 10); // YYYY-MM-DD
    }
  }


  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _loadTransactions();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stock Transactions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "All stock movement records (IN & OUT)",
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
                      itemCount: paginatedData.length,
                      itemBuilder: (context, i) {
                        final t = paginatedData[i];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: ColorManager.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border:
                            Border.all(color: ColorManager.borderSoft),
                            boxShadow: [
                              BoxShadow(
                                color:
                                ColorManager.shadowLightBlue,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // IN / OUT badge
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: t.moveType == 'IN'
                                      ? Colors.green.withOpacity(0.12)
                                      : Colors.red.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  t.moveType == 'IN'
                                      ? Icons.arrow_downward_rounded
                                      : Icons.arrow_upward_rounded,
                                  color: t.moveType == 'IN' ? Colors.green : Colors.red,
                                  size: 22,
                                ),
                              ),


                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.productName,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        ColorManager.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Qty: ${t.quantity} • PIC: ${t.picName}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ColorManager.textDark
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.moveType == 'IN' ? "Stock In" : "Stock Out",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: t.moveType == 'IN'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                "${t.createdAt.toLocal().toString().substring(0, 10)}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: ColorManager.textDark
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),
                  _paginationWindow(),
                ],
              ),
            ),

            // ------------------------------------------------------------
            // FLOAT +
            // ------------------------------------------------------------
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
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),

            // ------------------------------------------------------------
            // FLOAT MENU
            // ------------------------------------------------------------
            Positioned(
              top: 82,
              right: 18,
              child: SizeTransition(
                sizeFactor:
                CurvedAnimation(parent: menuController, curve: Curves.easeOut),
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: menuController,
                  child: Container(
                    width: 190,
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
                      children: [
                        _menuItem(
                          icon: Icons.filter_alt_outlined,
                          label: "Filter Date",
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
                          label: "Add Transaction",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MobileWrapper(
                                  child: const AddStockPage(),
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

            // ------------------------------------------------------------
            // FILTER PANEL (DATE)
            // ------------------------------------------------------------
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
                      "Filter Stock",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.textDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // START DATE
                    Text("Start Date", style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickDate(startDateCtrl),
                      child: AbsorbPointer(
                        child: _filterInput(startDateCtrl),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // END DATE
                    Text("End Date", style: TextStyle(color: ColorManager.textDark)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _pickDate(endDateCtrl),
                      child: AbsorbPointer(
                        child: _filterInput(endDateCtrl),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CARI
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _loadTransactions(
                            startDate:
                            startDateCtrl.text.isEmpty ? null : startDateCtrl.text,
                            endDate:
                            endDateCtrl.text.isEmpty ? null : endDateCtrl.text,
                          );
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
                          style:
                          TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TUTUP
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

                    const SizedBox(height: 12),

                    // RESET
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          startDateCtrl.clear();
                          endDateCtrl.clear();
                          _loadTransactions();
                          setState(() => showFilter = false);
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

  // ------------------------------------------------------------
  // COMPONENTS
  // ------------------------------------------------------------
  Widget _menuItem(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style:
              const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _filterInput(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColorManager.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.border),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _paginationWindow() {
    if (allTransactions.isEmpty) return const SizedBox();

    final totalPages =
        ((allTransactions.length - 1) / pageSize).floor() + 1;

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
}
