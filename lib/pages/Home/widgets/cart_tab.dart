import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldbill_calc/models/billmodels.dart';
import 'package:goldbill_calc/pages/Result/generate_estimate_pdf.dart';
import 'package:goldbill_calc/providers/cart_provider.dart';
import 'package:goldbill_calc/pages/Home/widgets/edit_item_page.dart';
import 'package:intl/intl.dart';

class CartTab extends ConsumerStatefulWidget {
  const CartTab({super.key});

  @override
  ConsumerState<CartTab> createState() => _CartTabState();
}

class _CartTabState extends ConsumerState<CartTab> {
  final purityIndex = {'18K': 0, '22K': 1, '24K': 2};
  final List<JewelleryItem> selectedItems = [];
  bool multiSelectMode = false;

  void resetMultiSelectMode() {
    setState(() {
      multiSelectMode = false;
      selectedItems.clear();
    });
  }

  void _deleteItem(JewelleryItem item) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text(
            'Are you sure you want to remove this ${item.type} from the estimate?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
              ),
              onPressed: () {
                ref.read(cartProvider.notifier).removeItem(item.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${item.type} from cart.'),
                    backgroundColor: const Color(0xFFB3261E),
                  ),
                );
              },
              child: const Text(
                'DELETE',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedItems() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Clear the Selected Items?'),
          content: const Text(
            'This will delete the selected items in the current estimate. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
              ),
              onPressed: () {
                for (var item in selectedItems) {
                  ref.read(cartProvider.notifier).removeItem(item.id);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selected estimate items cleared.'),
                    backgroundColor: Colors.black87,
                  ),
                );
              },
              child: const Text(
                'CLEAR ALL',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 17,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.black87,
            ),
          ),
          SizedBox(
            width: 150,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTotal ? 24 : 17,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
                  color: isTotal ? const Color(0xFF002856) : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final rateList = ref.watch(goldRateProvider);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Estimate Cart is Empty',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Please enter details in the "Add Jewellery" tab and click "Add to Cart" to start building your estimate.',
                style: TextStyle(fontSize: 16, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    double totalGoldWeight = 0.0;
    double totalGoldVal = 0.0;
    double totalStoneCost = 0.0;
    double totalWastage = 0.0;
    double totalMaking = 0.0;
    double totalGst = 0.0;
    double grandTotal = 0.0;
    int selectedIndex = 1;
    double goldRate = double.parse(rateList[1]);

    for (var item in items) {
      selectedIndex = purityIndex[item.purity] ?? 1;
      goldRate = double.parse(rateList[selectedIndex]);
      totalGoldWeight += item.netWeight * item.quantity;
      totalGoldVal += item.calculateGoldValue(goldRate);
      totalStoneCost += item.calculateStoneCost();
      totalWastage += item.calculateWastageAmount(goldRate);
      totalMaking += item.calculateMakingCharges(goldRate);
      totalGst += item.calculateGstAmount(goldRate);
      grandTotal += item.calculateFinalAmount(goldRate);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Estimate List (${items.length} ${items.length == 1 ? 'item' : 'items'})",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            (!multiSelectMode)
                ? TextButton.icon(
                    onPressed: () => setState(() {
                      multiSelectMode = true;
                      selectedItems.addAll(items);
                    }),
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Color(0xFFB3261E),
                    ),
                    label: const Text(
                      "Delete Items",
                      style: TextStyle(
                        color: Color(0xFFB3261E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _deleteSelectedItems,
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: Color(0xFFB3261E),
                    ),
                    label: const Text(
                      "Delete Selected",
                      style: TextStyle(
                        color: Color(0xFFB3261E),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),

        if (multiSelectMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF002856).withValues(alpha: 0.05),
                  const Color(0xFF002856).withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF002856).withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002856).withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002856),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Multi-Select Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002856),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'} selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF002856).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: resetMultiSelectMode,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF002856),
                    size: 22,
                  ),
                  tooltip: 'Disable Multi-Select Mode',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

        if (multiSelectMode) const SizedBox(height: 12),

        ...items.map((item) {
          selectedIndex = purityIndex[item.purity] ?? 1;
          goldRate = double.parse(rateList[selectedIndex]);
          final double itemGoldVal = item.calculateGoldValue(goldRate);
          final double itemStoneCost = item.calculateStoneCost();
          final double itemWastage = item.calculateWastageAmount(goldRate);
          final double itemMaking = item.calculateMakingCharges(goldRate);
          final double itemFinal = item.calculateFinalAmount(goldRate);

          return GestureDetector(
            onLongPress: () => setState(() {
              if (!multiSelectMode) {
                multiSelectMode = true;
                selectedItems.addAll(items);
              } else {
                resetMultiSelectMode();
              }
            }),
            onTap: multiSelectMode
                ? () {
                    setState(() {
                      if (selectedItems.contains(item)) {
                        selectedItems.remove(item);
                      } else {
                        selectedItems.add(item);
                      }
                    });
                  }
                : null,
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: (selectedItems.contains(item) && multiSelectMode)
                  ? const Color(0xFF002856).withValues(alpha: 0.08)
                  : Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: (selectedItems.contains(item) && multiSelectMode)
                      ? const Color(0xFF002856)
                      : Colors.grey,
                  width: selectedItems.contains(item) ? 2 : 1,
                ),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.type} (${item.purity})",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF002856),
                                size: 26,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditItemPage(item: item),
                                  ),
                                );
                              },
                              tooltip: 'Edit Item',
                            ),
                            if (multiSelectMode) ...[
                              Checkbox(
                                value: selectedItems.contains(item),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedItems.add(item);
                                    } else {
                                      selectedItems.remove(item);
                                    }
                                  });
                                },
                              ),
                            ] else ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFB3261E),
                                  size: 26,
                                ),
                                onPressed: () => _deleteItem(item),
                                tooltip: 'Delete Item',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Weight:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${item.grossWeight.toStringAsFixed(3)}g",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Gold Weight:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${item.netWeight.toStringAsFixed(3)} g",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Stone Weight:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${item.stoneWeight.toStringAsFixed(3)}g",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quantity:",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Gold Value (@ â‚¹ ${item.goldRate.toStringAsFixed(0)}/g) :",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemGoldVal.round())}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (itemStoneCost > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Stone Cost (@ â‚¹ ${item.stoneRate.toStringAsFixed(0)}/g):",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemStoneCost.round())}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wastage (${item.isWastageInGrams ? '${item.wastageCharge.toInt()}g' : '${item.wastageCharge.toInt()}%'}):",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemWastage.round())}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Making Charges (${item.isMakingFixed ? 'Fixed' : '${item.makingCharge.toInt()}%'}):",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemMaking.round())}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "GST (3%):",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        Text(
                          item.enableGst
                              ? "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemFinal.round() - (itemGoldVal + itemStoneCost + itemWastage + itemMaking).round())}"
                              : "Off",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Item Total:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(itemFinal.round())}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002856),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
        const Divider(thickness: 2),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "COMPLETE ESTIMATE",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Color(0xFF002856),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 24, thickness: 1.5, color: Colors.black26),

              _buildSummaryRow(
                "Total Gold Weight:",
                "${totalGoldWeight.toStringAsFixed(3)} g",
              ),
              _buildSummaryRow(
                "Total Gold Value:",
                "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(totalGoldVal.round())}",
              ),
              if (totalStoneCost > 0)
                _buildSummaryRow(
                  "Total Stone Cost:",
                  "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(totalStoneCost.round())}",
                ),
              _buildSummaryRow(
                "Total Wastage Charges:",
                "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(totalWastage.round())}",
              ),
              _buildSummaryRow(
                "Total Making Charges:",
                "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(totalMaking.round())}",
              ),
              _buildSummaryRow(
                "Total GST (3%):",
                "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(totalGst.round())}",
              ),

              const Divider(height: 24, thickness: 2, color: Colors.black),

              _buildSummaryRow(
                "GRAND TOTAL:",
                "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(grandTotal.round())}",
                isTotal: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        GenerateEstimatePdf(),

        const SizedBox(height: 40),
      ],
    );
  }
}
