
import 'package:flutter/material.dart';
import '../../products/screens/product_list_screen.dart';
import '../../users/screens/profile_screen.dart';
import '../../authentication/screens/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color navy = Color(0xFF151A35);
  static const Color purple = Color(0xFF7657F6);
  static const Color background = Color(0xFFF6F5FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.all_inclusive_rounded, color: purple, size: 29),
            SizedBox(width: 9),
            Text(
              'BrightLoop',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: navy),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 55, 22, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [navy, Color(0xFF30265D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: purple,
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Welcome Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage your BrightLoop account',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            _drawerItem(
              context,
              Icons.dashboard_rounded,
              'Dashboard',
              () => Navigator.pop(context),
            ),
            _drawerItem(
              context,
              Icons.person_outline_rounded,
              'My Profile',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              Icons.shopping_bag_outlined,
              'Products',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(indent: 20, endIndent: 20),

            _drawerItem(
              context,
              Icons.logout_rounded,
              'Logout',
              () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              color: Colors.redAccent,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7657F6), Color(0xFF4A35AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: purple.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR CONTROL CENTER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Everything you need to manage your subscriptions, all in one place.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: -8,
                    bottom: -12,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white.withValues(alpha: 0.13),
                      size: 105,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'A quick look at your workspace',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),

            const SizedBox(height: 18),

            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: 1.18,
              children: const [
                DashboardCard(
                  title: 'Products',
                  value: '0',
                  icon: Icons.inventory_2_outlined,
                  color: Color(0xFF7657F6),
                ),
                DashboardCard(
                  title: 'Subscriptions',
                  value: '0',
                  icon: Icons.autorenew_rounded,
                  color: Color(0xFF269B79),
                ),
                DashboardCard(
                  title: 'Active Plans',
                  value: '0',
                  icon: Icons.verified_outlined,
                  color: Color(0xFFE69A35),
                ),
                DashboardCard(
                  title: 'Payments',
                  value: '0',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Color(0xFF3994D6),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 16),

            _actionCard(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Manage Products',
              subtitle: 'Add, edit and explore products',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 13),

            _actionCard(
              context,
              icon: Icons.person_outline_rounded,
              title: 'My Profile',
              subtitle: 'Manage your personal information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'BRIGHTLOOP • SMARTER SUBSCRIPTIONS',
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  static Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = navy,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  static Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFECEAF4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0ECFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: purple, size: 25),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEAF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF151A35),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
