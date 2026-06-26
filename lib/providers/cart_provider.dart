import 'dart:convert';
import 'package:goldbill_calc/models/billmodels.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:goldbill_calc/providers/shared_preferences_provider.dart';

part 'cart_provider.g.dart';

// Persistent gold rate notifier using Riverpod generator
@Riverpod(keepAlive: true)
class GoldRate extends _$GoldRate {
  static const _key = 'gold_rate';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    try {
      return prefs.getStringList(_key) ?? ['0.0', '0.0', '0.0'];
    } catch (e) {
      prefs.remove(_key);
      return ['0.0', '0.0', '0.0'];
    }
  }

  void setRate(double rate, String purity) {
    final rateList = List<String>.from(state);
    String rateStr = rate.toString();
    if (purity == '18K') {
      rateList[0] = rateStr;
    } else if (purity == '22K') {
      rateList[1] = rateStr;
    } else if (purity == '24K') {
      rateList[2] = rateStr;
    }
    state = rateList;
    ref.read(sharedPreferencesProvider).setStringList(_key, rateList);
  }
}

// Persistent cart notifier using Riverpod generator
@Riverpod(keepAlive: true)
class Cart extends _$Cart {
  static const _key = 'gold_cart_items';

  @override
  List<JewelleryItem> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    try {
      final jsonList = prefs.getStringList(_key);
      if (jsonList == null) return [];
      return jsonList
          .map((itemStr) => JewelleryItem.fromJson(json.decode(itemStr) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      prefs.remove(_key);
      return [];
    }
  }

  void _saveToPrefs(List<JewelleryItem> items) {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonList = items.map((item) => json.encode(item.toJson())).toList();
    prefs.setStringList(_key, jsonList);
  }

  void addItem(JewelleryItem item) {
    state = [...state, item];
    _saveToPrefs(state);
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveToPrefs(state);
  }

  void updateItem(JewelleryItem updatedItem) {
    state = state.map((item) => item.id == updatedItem.id ? updatedItem : item).toList();
    _saveToPrefs(state);
  }

  void clearCart() {
    state = [];
    _saveToPrefs(state);
  }
}
