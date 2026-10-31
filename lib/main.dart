import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/invoices/screens/invoice_list_screen.dart';
import 'features/invoices/screens/tax_details_screen.dart';
import 'features/invoices/screens/discount_management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    // Riverpod ProviderScope wraps root application
    const ProviderScope(
      child: SubscriptionApp(),
    ),
  );
}

class SubscriptionApp extends StatelessWidget {
  const SubscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const Member3NavigationShell(),
    );
  }
}

class Member3NavigationShell extends StatefulWidget {
  const Member3NavigationShell({super.key});

  @override
  State<Member3NavigationShell> createState() => _Member3NavigationShellState();
}

class _Member3NavigationShellState extends State<Member3NavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    InvoiceListScreen(),
    TaxDetailsScreen(),
    DiscountManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.percent_outlined),
            selectedIcon: Icon(Icons.percent),
            label: 'Tax (GST)',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Discounts',
          ),
        ],
      ),
    );
  }
}
