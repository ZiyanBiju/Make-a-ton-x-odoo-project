import 'package:flutter/material.dart';

void main() {
  runApp(const BrightloopApp());
}

class BrightloopApp extends StatelessWidget {
  const BrightloopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brightloop Subscriptions',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const SubscriptionDashboard(),
    );
  }
}

class Subscription {
  final String id;
  final String customer;
  final String plan;
  final String startDate;
  final String endDate;
  final String status;

  const Subscription({
    required this.id,
    required this.customer,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class SubscriptionDashboard extends StatefulWidget {
  const SubscriptionDashboard({super.key});

  @override
  State<SubscriptionDashboard> createState() => _SubscriptionDashboardState();
}

class _SubscriptionDashboardState extends State<SubscriptionDashboard> {
  final TextEditingController searchController = TextEditingController();

  String selectedFilter = 'All';

  final List<Subscription> subscriptions = [
    const Subscription(
      id: 'SUB001',
      customer: 'John Mathew',
      plan: 'Premium',
      startDate: '01 Oct 2026',
      endDate: '01 Nov 2026',
      status: 'Active',
    ),
    const Subscription(
      id: 'SUB002',
      customer: 'Anna Joseph',
      plan: 'Basic',
      startDate: '15 Oct 2026',
      endDate: '15 Nov 2026',
      status: 'Pending',
    ),
    const Subscription(
      id: 'SUB003',
      customer: 'David Thomas',
      plan: 'Enterprise',
      startDate: '01 Sep 2026',
      endDate: '01 Oct 2026',
      status: 'Expired',
    ),
    const Subscription(
      id: 'SUB004',
      customer: 'Maria George',
      plan: 'Premium',
      startDate: '20 Oct 2026',
      endDate: '20 Nov 2026',
      status: 'Active',
    ),
    const Subscription(
      id: 'SUB005',
      customer: 'Kevin Paul',
      plan: 'Basic',
      startDate: '10 Oct 2026',
      endDate: '10 Nov 2026',
      status: 'Cancelled',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Subscription> get filteredSubscriptions {
    return subscriptions.where((subscription) {
      final matchesFilter =
          selectedFilter == 'All' || subscription.status == selectedFilter;

      final query = searchController.text.toLowerCase();
      final matchesSearch =
          subscription.customer.toLowerCase().contains(query) ||
          subscription.id.toLowerCase().contains(query) ||
          subscription.plan.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int countStatus(String status) {
    return subscriptions.where((s) => s.status == status).length;
  }

  void addSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription form will be added in the next step.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.all_inclusive, color: Color(0xFF3157D5), size: 30),
            SizedBox(width: 8),
            Text('Brightloop', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE5EBFF),
              child: Icon(Icons.person, color: Color(0xFF3157D5)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription Management',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage and monitor all customer subscriptions.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 22),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  summaryCard(
                    'Total',
                    subscriptions.length.toString(),
                    Icons.layers_outlined,
                    Colors.blue,
                  ),
                  summaryCard(
                    'Active',
                    countStatus('Active').toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  summaryCard(
                    'Pending',
                    countStatus('Pending').toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                  summaryCard(
                    'Expired',
                    countStatus('Expired').toString(),
                    Icons.event_busy,
                    Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Subscriptions',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  FilledButton.icon(
                    onPressed: addSubscription,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search subscriptions...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Pending', 'Expired', 'Cancelled']
                      .map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: selectedFilter == filter,
                            onSelected: (_) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),

              ...filteredSubscriptions.map(
                (subscription) => subscriptionCard(subscription),
              ),

              if (filteredSubscriptions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('No subscriptions found.')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 155,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget subscriptionCard(Subscription subscription) {
    final statusColors = {
      'Active': Colors.green,
      'Pending': Colors.orange,
      'Expired': Colors.red,
      'Cancelled': Colors.grey,
    };

    final color = statusColors[subscription.status] ?? Colors.blue;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3157D5),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subscription.status,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subscription.customer,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('Plan: ${subscription.plan}'),
            const SizedBox(height: 5),
            Text(
              '${subscription.startDate}  →  ${subscription.endDate}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
