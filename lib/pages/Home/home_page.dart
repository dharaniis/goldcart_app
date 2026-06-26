import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldbill_calc/pages/Home/widgets/add_item_tab.dart';
import 'package:goldbill_calc/pages/Home/widgets/cart_tab.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  DateTime? _lastPressedTime;
  final GlobalKey _cartTabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AddItemTab(),
      CartTab(key: _cartTabKey),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        final now = DateTime.now();
        
        if (_lastPressedTime == null || 
            now.difference(_lastPressedTime!) > const Duration(seconds: 5)) {
          
          _lastPressedTime = now;

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again'),
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/jewel.png',
              width: 35,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.star,
                color: Colors.amber,
                size: 30,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Gold Bill Estimator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 1) {
              (_cartTabKey.currentState as dynamic)?.resetMultiSelectMode();
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFF002856)),
            label: 'Add Jewellery',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFF002856)),
            label: 'Estimate Cart',
          ),
        ],
      ),
    )
    );
  }
}
