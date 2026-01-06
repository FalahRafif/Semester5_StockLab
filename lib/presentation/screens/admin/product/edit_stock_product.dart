import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/core/color_manager.dart';
import '../../../shared/wrappers/mobile_wrapper.dart';
import '../../../shared/widgets/app_layout.dart';

// transaction
import '../../../../application/transaction_manager.dart';

// product
import '../../../../application/product_manager.dart';
import '../../../../data/models/product_response.dart';

class EditStockProductPage extends StatefulWidget {
  final ProductData? product; // <-- tambahkan parameter opsional

  const EditStockProductPage({super.key, this.product});

  @override
  State<EditStockProductPage> createState() => _EditStockProductPageState();
}
class _EditStockProductPageState extends State<EditStockProductPage> {
  final TransactionManager _transactionManager = TransactionManager();
  final ProductManager _productManager = ProductManager();

  final TextEditingController quantityCtrl = TextEditingController();

  List<ProductData> allProducts = [];
  List<ProductData> filteredProducts = [];
  ProductData? selectedProduct;

  String? moveType; // ❗ nullable agar bisa divalidasi

  bool _isLoading = false;
  bool _loadingProduct = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    quantityCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // LOAD PRODUCT
  // ─────────────────────────────────────────────

  // ubah _loadProducts agar jika widget.product != null, set selectedProduct
  Future<void> _loadProducts() async {
    final result = await _productManager.getProducts();
    if (!mounted) return;

    if (result.success) {
      setState(() {
        allProducts = result.products;
        filteredProducts = result.products;
        _loadingProduct = false;

        // ✅ Jika product dikirim dari list, set otomatis
        if (widget.product != null) {
          selectedProduct = allProducts.firstWhere(
                (p) => p.id == widget.product!.id,
            orElse: () => widget.product!, // fallback
          );
        }
      });
    } else {
      _loadingProduct = false;
      _showSnack(result.message);
    }
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.bgBottom,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              Text(
                "Tambah Transaksi Stock",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.textDark,
                ),
              ),

              const SizedBox(height: 28),

              _productPicker(),
              const SizedBox(height: 16),

              _inputField(
                "Quantity",
                quantityCtrl,
                keyboardType: TextInputType.number,
                onlyNumber: true,
              ),

              const SizedBox(height: 24),
              _moveTypeSelector(),

              const SizedBox(height: 34),

              _buttonSave(),
              const SizedBox(height: 12),
              _buttonCancel(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PRODUCT PICKER
  // ─────────────────────────────────────────────

  Widget _productPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product",
          style: TextStyle(
            color: ColorManager.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: _loadingProduct ? null : _openProductModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: ColorManager.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorManager.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedProduct == null
                        ? "Pilih Product"
                        : "${selectedProduct!.name} • ${selectedProduct!.sku}",
                    style: TextStyle(
                      color: selectedProduct == null
                          ? Colors.grey
                          : ColorManager.textDark,
                    ),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openProductModal() {
    filteredProducts = allProducts;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cari product...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: ColorManager.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        filteredProducts = allProducts
                            .where((p) =>
                            p.name.toLowerCase().contains(val.toLowerCase()))
                            .toList();
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  Flexible(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (_, i) {
                        final p = filteredProducts[i];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("${p.brand} • ${p.sku}"),
                          trailing: Text("Rp ${p.price}"),
                          onTap: () {
                            setState(() => selectedProduct = p);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // MOVE TYPE
  // ─────────────────────────────────────────────

  Widget _moveTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jenis Transaksi",
          style: TextStyle(
            color: ColorManager.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _radio("Stok Masuk", "IN", Colors.green),
            const SizedBox(width: 12),
            _radio("Stok Keluar", "OUT", Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _radio(String label, String value, Color color) {
    final active = moveType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => moveType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : ColorManager.inputFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? color : ColorManager.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? color : ColorManager.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // INPUT & BUTTON
  // ─────────────────────────────────────────────

  Widget _inputField(
      String label,
      TextEditingController ctrl, {
        TextInputType keyboardType = TextInputType.text,
        bool onlyNumber = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ColorManager.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          inputFormatters:
          onlyNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorManager.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttonSave() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Simpan",
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buttonCancel() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Batal"),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUBMIT
  // ─────────────────────────────────────────────

  Future<void> _submit() async {
    if (selectedProduct == null) {
      _showSnack("Product wajib dipilih");
      return;
    }

    if (quantityCtrl.text.trim().isEmpty) {
      _showSnack("Quantity wajib diisi");
      return;
    }

    final qty = int.tryParse(quantityCtrl.text.trim());
    if (qty == null || qty <= 0) {
      _showSnack("Quantity harus berupa angka dan lebih dari 0");
      return;
    }

    if (moveType == null) {
      _showSnack("Jenis transaksi wajib dipilih");
      return;
    }

    setState(() => _isLoading = true);

    final result = await _transactionManager.createTransaction(
      productId: selectedProduct!.id,
      quantity: qty,
      moveType: moveType!,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.success) {
      _showSnack("Transaksi berhasil", success: true);
      Future.delayed(const Duration(milliseconds: 700), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const MobileWrapper(child: AppLayout(initialIndex: 1)),
          ),
        );
      });
    } else {
      _showSnack(result.message);
    }
  }
}
