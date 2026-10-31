import 'package:flutter/material.dart';

import 'features/authentication/screens/login_screen.dart';
import 'features/subscriptions/screens/subscription_dashboard.dart';
import 'features/finance/screens/finance_home.dart';
import 'features/invoices/screens/invoice_list_screen.dart';
import 'features/invoices/screens/tax_details_screen.dart';
import 'features/invoices/screens/discount_management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrightLoopApp());
}

class BrightLoopApp extends StatelessWidget {
  const BrightLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrightLoop',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3157D5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const BrightLoopNavigation(),
      },
    );
  }
}

class BrightLoopNavigation extends StatefulWidget {
  const BrightLoopNavigation({super.key});

  @override
  State<BrightLoopNavigation> createState() =>
      _BrightLoopNavigationState();
}

class _BrightLoopNavigationState extends State<BrightLoopNavigation> {
  int selectedIndex = 0;

  late final List<Widget> screens = [
    const SubscriptionDashboard(),
    const FinanceHome(),
    const InvoiceManagementScreen(),
  ];

  final List<String> titles = [
    'Subscriptions',
    'Finance',
    'Invoices & Tax',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.all_inclusive,
              color: Color(0xFF3157D5),
            ),
            const SizedBox(width: 8),
            Text(
              'BrightLoop - ${titles[selectedIndex]}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.subscriptions_outlined),
            selectedIcon: Icon(Icons.subscriptions),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState
    extends State<InvoiceManagementScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    InvoiceListScreen(),
    TaxDetailsScreen(),
    DiscountManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: screens,
          ),
        ),
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
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
              label: 'GST',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_offer_outlined),
              selectedIcon: Icon(Icons.local_offer),
              label: 'Discounts',
            ),
          ],
        ),
      ],
    );
  }
}