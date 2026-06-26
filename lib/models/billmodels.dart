class EstimateInput {
  double goldPrice;
  double goldWeight;
  double wastageCharge;
  bool isMakingFixed;
  bool isWastageInGrams;
  double makingCharge;
  bool enableGstTax;

  EstimateInput({
    required this.goldPrice,
    required this.goldWeight,
    required this.wastageCharge,
    this.isWastageInGrams = false,
    required this.makingCharge,
    this.isMakingFixed = false,
    this.enableGstTax = true,
  });
}

class EstimateResult {
  double totalBill;
  double goldValue;
  double wastageCharges;
  double makingCharges;
  double taxAmount;

  EstimateResult({
    required this.totalBill,
    required this.goldValue,
    required this.wastageCharges,
    required this.makingCharges,
    required this.taxAmount,
  });
}

class JewelleryItem {
  final String id;
  final String type; // e.g., Gold Coin, Ring, Chain, Bangle, etc.
  final String purity;
  final double goldRate; // 24K, 22K, 18K
  final double grossWeight;
  final double stoneWeight;
  final double stoneRate; // Price per gram for stones
  final double netWeight;
  final double wastageCharge;
  final bool isWastageInGrams;
  final double makingCharge;
  final bool isMakingFixed; // true = fixed, false = percentage
  final bool enableGst;
  final int quantity;

  JewelleryItem({
    required this.id,
    required this.type,
    required this.purity,
    required this.goldRate,
    required this.grossWeight,
    required this.stoneWeight,
    required this.stoneRate,
    required this.netWeight,
    required this.wastageCharge,
    required this.isWastageInGrams,
    required this.makingCharge,
    required this.isMakingFixed,
    required this.enableGst,
    required this.quantity,
  });

  double calculateGoldValue(double goldRate) {
    return netWeight * goldRate * quantity;
  }

  double calculateStoneCost() {
    return stoneWeight * stoneRate * quantity;
  }

  double calculateWastageAmount(double goldRate) {
    if (isWastageInGrams) {
      return wastageCharge * goldRate * quantity;
    } else {
      final goldVal = calculateGoldValue(goldRate);
      return goldVal * (wastageCharge / 100);
    }
  }

  double calculateMakingCharges(double goldRate) {
    if (isMakingFixed) {
      return makingCharge * quantity;
    } else {
      final goldVal = calculateGoldValue(goldRate);
      return goldVal * (makingCharge / 100);
    }
  }

  double calculateSubtotal(double goldRate) {
    return calculateGoldValue(goldRate) +
        calculateStoneCost() +
        calculateWastageAmount(goldRate) +
        calculateMakingCharges(goldRate);
  }

  double calculateGstAmount(double goldRate) {
    if (!enableGst) return 0.0;
    return calculateSubtotal(goldRate) * 0.03;
  }

  double calculateFinalAmount(double goldRate) {
    return calculateSubtotal(goldRate) + calculateGstAmount(goldRate);
  }

  JewelleryItem copyWith({
    String? id,
    String? type,
    String? purity,
    double? goldRate,
    double? grossWeight,
    double? stoneWeight,
    double? stoneRate,
    double? netWeight,
    double? wastageCharge,
    bool? isWastageInGrams,
    double? makingCharge,
    bool? isMakingFixed,
    bool? enableGst,
    int? quantity,
  }) {
    return JewelleryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      purity: purity ?? this.purity,
      goldRate: goldRate ?? this.goldRate,
      grossWeight: grossWeight ?? this.grossWeight,
      stoneWeight: stoneWeight ?? this.stoneWeight,
      stoneRate: stoneRate ?? this.stoneRate,
      netWeight: netWeight ?? this.netWeight,
      wastageCharge: wastageCharge ?? this.wastageCharge,
      isWastageInGrams: isWastageInGrams ?? this.isWastageInGrams,
      makingCharge: makingCharge ?? this.makingCharge,
      isMakingFixed: isMakingFixed ?? this.isMakingFixed,
      enableGst: enableGst ?? this.enableGst,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'purity': purity,
      'goldRate': goldRate,
      'grossWeight': grossWeight,
      'stoneWeight': stoneWeight,
      'stoneRate': stoneRate,
      'netWeight': netWeight,
      'wastageCharge': wastageCharge,
      'isWastageInGrams': isWastageInGrams,
      'makingCharge': makingCharge,
      'isMakingFixed': isMakingFixed,
      'enableGst': enableGst,
      'quantity': quantity,
    };
  }

  factory JewelleryItem.fromJson(Map<String, dynamic> json) {
    return JewelleryItem(
      id: json['id'] as String,
      type: json['type'] as String,
      purity: json['purity'] as String,
      goldRate: json['goldRate'] as double,
      grossWeight: (json['grossWeight'] as num).toDouble(),
      stoneWeight: (json['stoneWeight'] as num).toDouble(),
      stoneRate: (json['stoneRate'] as num).toDouble(),
      netWeight: (json['netWeight'] as num).toDouble(),
      wastageCharge: (json['wastageCharge'] as num).toDouble(),
      isWastageInGrams: json['isWastageInGrams'] as bool,
      makingCharge: (json['makingCharge'] as num).toDouble(),
      isMakingFixed: json['isMakingFixed'] as bool,
      enableGst: json['enableGst'] as bool,
      quantity: json['quantity'] as int,
    );
  }
}