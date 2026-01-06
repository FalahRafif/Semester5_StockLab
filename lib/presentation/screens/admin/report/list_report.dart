import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' hide Border;

import '../../../../application/transaction_manager.dart';
import '../../../../data/models/transaction_response.dart';
import '../../../shared/core/color_manager.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}
enum TdAlign {
  left,
  center,
  right,
}

class _ReportPageState extends State<ReportPage> {
  final TransactionManager _manager = TransactionManager();
  final ScrollController _horizontalCtrl = ScrollController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;
  String _error = '';
  List<TransactionData> _data = [];

  final _fmt = DateFormat('yyyy-MM-dd');

  TextAlign _mapTextAlign(TdAlign align) {
    switch (align) {
      case TdAlign.center:
        return TextAlign.center;
      case TdAlign.right:
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }


  // ─────────────────────────────────────────────
  // FETCH DATA
  // ─────────────────────────────────────────────
  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    final res = await _manager.getTransactions(
      startDate: _startDate != null ? _fmt.format(_startDate!) : null,
      endDate: _endDate != null ? _fmt.format(_endDate!) : null,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      if (res.success) {
        _data = res.transactions;
      } else {
        _error = res.message;
      }
    });
  }

  // ─────────────────────────────────────────────
  // EXPORT TO EXCEL
  // ─────────────────────────────────────────────
  Future<void> _exportExcel() async {
    if (_data.isEmpty) return;

    // 🔐 Request permission Android
    if (!kIsWeb && Platform.isAndroid) {
      bool granted = false;

      if (await Permission.manageExternalStorage.isGranted) {
        granted = true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        granted = status.isGranted;
      }

      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin storage ditolak')),
        );
        return;
      }
    }

    // Buat Excel
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    sheet.appendRow([
    TextCellValue('Tanggal'),
    TextCellValue('Produk'),
    TextCellValue('SKU'),
    TextCellValue('Brand'),
    TextCellValue('Harga'),
    TextCellValue('Qty'),
    TextCellValue('Tipe'),
    TextCellValue('PIC'),
    ]);

    for (final t in _data) {
      sheet.appendRow([
        TextCellValue(_fmt.format(t.createdAt)),
        TextCellValue(t.productName),
        TextCellValue(t.productSku),
        TextCellValue(t.productBrand),
        IntCellValue(t.productPrice),
        IntCellValue(t.quantity),
        TextCellValue(t.moveType),
        TextCellValue(t.picName),
      ]);
    }

    // 📂 Path platform-specific
    late Directory dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download'); // folder Download
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final fileName =
        'transaction_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${dir.path}/$fileName');

    await file.writeAsBytes(excel.encode()!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Platform.isAndroid
              ? 'Report disimpan di Download\n$fileName'
              : 'Report disimpan di\n${file.path}',
        ),
        backgroundColor: ColorManager.primary,
      ),
    );
  }




  @override
  void dispose() {
    _horizontalCtrl.dispose();
    super.dispose();
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
              _title(),
              const SizedBox(height: 20),
              _filterCard(),
              const SizedBox(height: 22),
              _resultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Transaction Report",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorManager.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Generate laporan transaksi dan export ke Excel",
          style: TextStyle(
            fontSize: 13,
            color: ColorManager.textDark.withOpacity(0.6),
          ),
        ),
      ],
    );
  }


  // ─────────────────────────────────────────────
  // FILTER CARD
  // ─────────────────────────────────────────────
  Widget _filterCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Periode",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorManager.textDark,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _dateField("Start Date", _startDate, (d) {
                setState(() => _startDate = d);
              })),
              const SizedBox(width: 12),
              Expanded(child: _dateField("End Date", _endDate, (d) {
                setState(() => _endDate = d);
              })),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _loadReport,
                  icon: const Icon(
                      Icons.analytics_rounded,
                      size: 20,
                      color: ColorManager.textWhite,
                  ),
                  label: const Text(
                    "Generate Report",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ColorManager.textWhite
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _exportButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportButton() {
    return InkWell(
      onTap: _data.isEmpty ? null : _exportExcel,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _data.isEmpty
              ? ColorManager.border.withOpacity(0.3)
              : ColorManager.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorManager.primary.withOpacity(0.3),
          ),
        ),
        child: Icon(
          Icons.download_rounded,
          color: _data.isEmpty
              ? ColorManager.textDark.withOpacity(0.4)
              : ColorManager.primary,
          size: 26,
        ),
      ),
    );
  }


  Widget _dateField(
      String label,
      DateTime? value,
      Function(DateTime) onPick,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ColorManager.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorManager.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.4,
                color: ColorManager.textDark.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value != null ? _fmt.format(value) : 'Pilih tanggal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value != null
                    ? ColorManager.textDark
                    : ColorManager.textDark.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─────────────────────────────────────────────
  // RESULT CARD
  // ─────────────────────────────────────────────
  Widget _resultCard() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return _card(
        child: Text(_error, style: TextStyle(color: ColorManager.error)),
      );
    }

    if (_data.isEmpty) {
      return _card(
        child: Text(
          "Tidak ada data transaksi pada periode ini",
          style: TextStyle(color: ColorManager.textDark.withOpacity(0.6)),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ PENTING
        children: [
          Text(
            "Detail Transaksi",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ColorManager.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ClipRect( // ✅ cegah overflow render
            child: _transactionTable(),
          ),
        ],
      ),
    );
  }



  Widget _transactionTable() {
    return SizedBox(
      height: 420,
      child: Row(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _horizontalCtrl,
              thumbVisibility: true,
              thickness: 4,
              child: SingleChildScrollView(
                controller: _horizontalCtrl,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000,
                  child: Column(
                    children: [
                      _tableHeader(),
                      const SizedBox(height: 6),

                      SizedBox(
                        height: 360, // sisa height untuk rows
                        child: ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (context, index) {
                            return _tableRow(
                              _data[index],
                              index.isEven,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }






  Widget _tableHeader() {
    return Container(
      width: 1000, // 👈 WAJIB agar scroll muncul di HP
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: ColorManager.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorManager.border),
      ),
      child: Row(
        children: [
          _th("Tanggal", 110),
          _th("Produk", 180),
          _th("SKU", 120),
          _th("Brand", 120, alignCenter: true),
          _th("Harga", 90, alignRight: true),
          _th("Qty", 70, alignCenter: true),
          _th("Tipe", 80, alignCenter: true),
          _th("PIC", 140, alignCenter: true),
        ],
      ),
    );
  }


  Widget _tableRow(TransactionData e, bool even) {
    final isIn = e.moveType == 'IN';

    return Container(
      width: 1000, // 👈 SAMA DENGAN HEADER
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: even ? ColorManager.bgBottom : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorManager.borderSoft),
      ),
      child: Row(
        children: [
          _td(_fmt.format(e.createdAt), 110),
          _td(e.productName, 180),
          _tdWrap(e.productSku, 120),
          _td(e.productBrand, 120, alignCenter: true),
          _td(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(e.productPrice),
            90,
            alignRight: true,
          ),
          _td(e.quantity.toString(), 70, alignCenter: true),
          _typeBadge(isIn), // pastikan width = 80 & center
          _td(e.picName, 140, alignCenter: true),
        ],
      ),
    );
  }


  Widget _th(
      String text,
      double width, {
        bool alignRight = false,
        bool alignCenter = false,
      }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: alignRight
            ? TextAlign.right
            : alignCenter
            ? TextAlign.center
            : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ColorManager.textDark.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _tdWrap(
      String text,
      double width, {
        bool alignCenter = false,
        bool alignRight = false,
      }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.visible,
        textAlign: alignCenter
            ? TextAlign.center
            : alignRight
            ? TextAlign.right
            : TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          color: ColorManager.textDark,
        ),
      ),
    );
  }



  Widget _td(
      String text,
      double width, {
        bool alignCenter = false,
        bool alignRight = false,
      }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignCenter
            ? TextAlign.center
            : alignRight
            ? TextAlign.right
            : TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          color: ColorManager.textDark,
        ),
      ),
    );
  }



  Widget _typeBadge(bool isIn) {
    return SizedBox(
      width: 80, // HARUS sama dengan header
      child: Center( // ✅ GANTI INI
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isIn
                ? ColorManager.success.withOpacity(0.15)
                : ColorManager.danger.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isIn ? 'IN' : 'OUT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isIn ? ColorManager.success : ColorManager.danger,
            ),
          ),
        ),
      ),
    );
  }





  Widget _transactionItem(TransactionData e) {
    final isIn = e.moveType == 'IN';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorManager.bgBottom,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIn
                  ? ColorManager.success.withOpacity(0.15)
                  : ColorManager.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIn ? Icons.call_received_rounded : Icons.call_made_rounded,
              color: isIn ? ColorManager.success : ColorManager.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Qty: ${e.quantity} • ${e.picName}",
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorManager.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            e.moveType,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIn ? ColorManager.success : ColorManager.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorManager.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ColorManager.shadowLightBlue,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}