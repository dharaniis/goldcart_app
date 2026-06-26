import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldbill_calc/components/text_input_formatters.dart';
import 'package:goldbill_calc/models/billmodels.dart';
import 'package:goldbill_calc/providers/cart_provider.dart';
import 'package:intl/intl.dart';

class AddItemTab extends ConsumerStatefulWidget {
  const AddItemTab({super.key});

  @override
  ConsumerState<AddItemTab> createState() => _AddItemTabState();
}

class _AddItemTabState extends ConsumerState<AddItemTab> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _rateController;
  final _netController = TextEditingController();
  final _stoneController = TextEditingController();
  final _stoneRateController = TextEditingController();
  final _wastageController = TextEditingController();
  final _makingChargeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  final purityIndex = {'18K': 0, '22K': 1, '24K': 2};

  String _selectedType = 'Ring';
  String _selectedPurity = '22K';
  bool _isWastageInGrams = false;
  bool _isMakingFixed = false;
  bool _enableGst = true;

  final List<String> _jewelleryTypes = [
    'Gold Coin',
    'Ring',
    'Chain',
    'Bangle',
    'Bracelet',
    'Necklace',
    'Earring',
    'Pendant',
    'Anklet',
    'Other',
  ];

  @override
  void dispose() {
    _netController.dispose();
    _stoneController.dispose();
    _stoneRateController.dispose();
    _wastageController.dispose();
    _makingChargeController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _netController.clear();
    _stoneController.clear();
    _stoneRateController.clear();
    _wastageController.clear();
    _makingChargeController.clear();
    _qtyController.text = '1';
    setState(() {
      _selectedType = 'Ring';
      _selectedPurity = '22K';
      _isWastageInGrams = false;
      _isMakingFixed = false;
      _enableGst = true;
    });
  }

  void _submit() {
    final rateList = ref.read(goldRateProvider);
    final selectedIndex = purityIndex[_selectedPurity] ?? 1;
    final goldRate = double.parse(rateList[selectedIndex]);
    if (goldRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Gold Rate at the top first.'),
          backgroundColor: Color(0xFFB3261E),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all required fields. Gold weight must be greater than 0.',
          ),
          backgroundColor: Color(0xFFB3261E),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final net = double.tryParse(_netController.text) ?? 0.0;
    if (net <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all required fields. Gold weight must be greater than 0.',
          ),
          backgroundColor: Color(0xFFB3261E),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final stone = double.tryParse(_stoneController.text) ?? 0.0;
    final stoneRate = double.tryParse(_stoneRateController.text) ?? 0.0;
    final gross = net + stone;
    final wastage = double.tryParse(_wastageController.text) ?? 0.0;
    final making = double.tryParse(_makingChargeController.text) ?? 0.0;
    final qty = int.tryParse(_qtyController.text) ?? 1;

    final newItem = JewelleryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      purity: _selectedPurity,
      goldRate: goldRate,
      grossWeight: gross,
      stoneWeight: stone,
      stoneRate: stoneRate,
      netWeight: net,
      wastageCharge: wastage,
      isWastageInGrams: _isWastageInGrams,
      makingCharge: making,
      isMakingFixed: _isMakingFixed,
      enableGst: _enableGst,
      quantity: qty,
    );

    ref.read(cartProvider.notifier).addItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_selectedType to cart successfully!'),
        backgroundColor: const Color(0xFF002856),
      ),
    );

    _resetForm();
  }

  Widget _buildPreviewRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? const Color(0xFF002856) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final rateList = ref.read(goldRateProvider);
    final currentRate = double.parse(rateList[1]);
    _rateController = TextEditingController(
      text: currentRate > 0 ? currentRate.toStringAsFixed(0) : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rateList = ref.watch(goldRateProvider);
    final selectedIndex = purityIndex[_selectedPurity] ?? 1;
    final goldRate = double.parse(rateList[selectedIndex]);
    _rateController.text = goldRate.toStringAsFixed(0);
    final double net = double.tryParse(_netController.text) ?? 0.0;
    final double stone = double.tryParse(_stoneController.text) ?? 0.0;
    final double stoneRate = double.tryParse(_stoneRateController.text) ?? 0.0;
    final double wastage = double.tryParse(_wastageController.text) ?? 0.0;
    final double making = double.tryParse(_makingChargeController.text) ?? 0.0;
    final int qty = int.tryParse(_qtyController.text) ?? 1;

    final double goldVal = net * goldRate * qty;
    final double stoneCost = stone * stoneRate * qty;
    final double wastageAmt = _isWastageInGrams
        ? (wastage * goldRate * qty)
        : (goldVal * (wastage / 100));
    final double makingAmt = _isMakingFixed
        ? (making * qty)
        : (goldVal * (making / 100));
    final double subtotal = goldVal + stoneCost + wastageAmt + makingAmt;
    final double gstAmt = _enableGst ? (subtotal * 0.03) : 0.0;
    final double finalAmt = subtotal + gstAmt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Jewellery Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedPurity Gold Rate',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "Rate per gram (â‚¹)",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.numberWithOptions(),
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Rate',
                        prefixText: 'â‚¹ ',
                        prefixStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      onChanged: (value) {
                        final rate = double.tryParse(value) ?? 0.0;
                        ref
                            .read(goldRateProvider.notifier)
                            .setRate(rate, _selectedPurity);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              "Jewellery Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _jewelleryTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 18)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            const Text(
              "Gold Purity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['24K', '22K', '18K'].map((purity) {
                final isSelected = _selectedPurity == purity;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          purity,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF002856),
                      backgroundColor: Colors.grey[200],
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedPurity = purity;
                          });
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gold Weight (g)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus
                              ?.unfocus();
                        },
                        controller: _netController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          suffixText: 'g',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        inputFormatters: [
                          SoftDecimalTextInputFormatter(
                            maxIntegerDigits: 4,
                            maxDecimalDigits: 2,
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Stone Weight (g)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus
                              ?.unfocus();
                        },
                        controller: _stoneController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: '0.00 (Opt)',
                          suffixText: 'g',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        inputFormatters: [
                          SoftDecimalTextInputFormatter(
                            maxIntegerDigits: 4,
                            maxDecimalDigits: 2,
                          ),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "Stone Rate (â‚¹/g)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus
                    ?.unfocus();
              },
              controller: _stoneRateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: 'â‚¹ ',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: [
                SoftDecimalTextInputFormatter(
                  maxIntegerDigits: 4,
                  maxDecimalDigits: 2,
                ),
              ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            const Text(
              "Wastage Charges Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF002856),
                  selectedForegroundColor: Colors.white,
                ),
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('% Percentage'),
                  ),
                  ButtonSegment<bool>(value: true, label: Text('g Grams')),
                ],
                selected: {_isWastageInGrams},
                onSelectionChanged: (value) {
                  setState(() {
                    _isWastageInGrams = value.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus
                    ?.unfocus();
              },
              controller: _wastageController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: _isWastageInGrams ? 'g' : '%',
                labelText: _isWastageInGrams
                    ? 'Wastage weight (grams)'
                    : 'Wastage Charges (%)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: _isWastageInGrams
                  ? [
                      SoftDecimalTextInputFormatter(
                        maxIntegerDigits: 4,
                        maxDecimalDigits: 2,
                      ),
                    ]
                  : [
                      SoftDecimalTextInputFormatter(
                        maxIntegerDigits: 2,
                        maxDecimalDigits: 2,
                      ),
                    ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            const Text(
              "Making Charges Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF002856),
                  selectedForegroundColor: Colors.white,
                ),
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('% Percentage'),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('â‚¹ Fixed Amount'),
                  ),
                ],
                selected: {_isMakingFixed},
                onSelectionChanged: (value) {
                  setState(() {
                    _isMakingFixed = value.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus
                    ?.unfocus();
              },
              controller: _makingChargeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: '0.0',
                prefixText: _isMakingFixed ? 'â‚¹ ' : null,
                suffixText: _isMakingFixed ? null : '%',
                labelText: _isMakingFixed
                    ? 'Making Charge (Fixed Amount)'
                    : 'Making Charge (Percentage of Gold Value)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: _isMakingFixed
                  ? [
                      SoftDecimalTextInputFormatter(
                        maxIntegerDigits: 4,
                        maxDecimalDigits: 2,
                      ),
                    ]
                  : [
                      SoftDecimalTextInputFormatter(
                        maxIntegerDigits: 2,
                        maxDecimalDigits: 2,
                      ),
                    ],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "GST 3%:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _enableGst,
                        activeThumbColor: const Color(0xFF002856),
                        onChanged: (val) {
                          setState(() {
                            _enableGst = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 28,
                            ),
                            onPressed: () {
                              final current =
                                  int.tryParse(_qtyController.text) ?? 1;
                              if (current > 1) {
                                setState(() {
                                  _qtyController.text = (current - 1)
                                      .toString();
                                });
                              }
                            },
                          ),
                          Expanded(
                            child: TextFormField(
                              onTapOutside: (event) {
                                FocusManager.instance.primaryFocus
                                    ?.unfocus();
                              },
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 28,
                            ),
                            onPressed: () {
                              final current =
                                  int.tryParse(_qtyController.text) ?? 1;
                              setState(() {
                                _qtyController.text = (current + 1).toString();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (goldRate <= 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF8B4B4),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFC81E1E)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Please enter the Gold Rate at the top of the screen to view live calculations and add items.",
                        style: TextStyle(
                          color: Color(0xFFC81E1E),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB0C4DE),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Live Price Preview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002856),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPreviewRow(
                      "Gold Weight:",
                      "${net.toStringAsFixed(3)} g",
                    ),
                    _buildPreviewRow(
                      "Gold Value:",
                      "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(goldVal.round())}",
                    ),
                    if (stoneCost > 0) ...[
                      _buildPreviewRow(
                        "Stone Weight:",
                        "${stone.toStringAsFixed(3)} g",
                      ),
                      _buildPreviewRow(
                        "Stone Cost:",
                        "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(stoneCost.round())}",
                      ),
                    ],
                    _buildPreviewRow(
                      "Wastage Amount:",
                      "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(wastageAmt.round())}",
                    ),
                    _buildPreviewRow(
                      "Making Charges:",
                      "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(makingAmt.round())}",
                    ),
                    if (_enableGst)
                      _buildPreviewRow(
                        "GST (3%):",
                        "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(gstAmt.round())}",
                      ),
                    const Divider(height: 16, thickness: 1, color: Colors.grey),
                    _buildPreviewRow(
                      "Estimated Total:",
                      "â‚¹ ${NumberFormat.decimalPattern('en_IN').format(finalAmt.round())}",
                      isTotal: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black54),
                    ),
                    child: const Text(
                      "Clear Form",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: goldRate > 0 ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002856),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


