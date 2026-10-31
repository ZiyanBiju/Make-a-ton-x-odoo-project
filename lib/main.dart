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

  final List<String> titles = [
    'Invoices',
    'GST Details',
    'Discounts',
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
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEAE4FF),
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