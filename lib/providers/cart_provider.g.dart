// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoldRate)
final goldRateProvider = GoldRateProvider._();

final class GoldRateProvider extends $NotifierProvider<GoldRate, List<String>> {
  GoldRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goldRateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goldRateHash();

  @$internal
  @override
  GoldRate create() => GoldRate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$goldRateHash() => r'86e2f28ac3e2fa83985e4106144fde02d29dc900';

abstract class _$GoldRate extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Cart)
final cartProvider = CartProvider._();

final class CartProvider extends $NotifierProvider<Cart, List<JewelleryItem>> {
  CartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartHash();

  @$internal
  @override
  Cart create() => Cart();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<JewelleryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<JewelleryItem>>(value),
    );
  }
}

String _$cartHash() => r'5b4834c172e14ea8898c36dd40827f590e6230c7';

abstract class _$Cart extends $Notifier<List<JewelleryItem>> {
  List<JewelleryItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<JewelleryItem>, List<JewelleryItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<JewelleryItem>, List<JewelleryItem>>,
              List<JewelleryItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
