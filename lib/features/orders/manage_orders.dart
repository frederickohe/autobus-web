import 'package:autobus/barrel.dart';

class ManageOrders extends StatelessWidget {
  const ManageOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManageScreenStyle.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: ManageScreenStyle.bodyDecoration(),
          ),
          SafeArea(
            child: Column(
              children: [
                const ManageScreenHeader(title: 'Manage Orders'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Orders',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeTitleStyle(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Track, manage, and automate order processing with smart AI assistance.',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 8),
                          const SizedBox(height: 40),
                          ManageHubGrid(
                            children: [
                              ManageHubActionCard(
                                icon: Icons.pending_actions_outlined,
                                label: 'Pending Orders',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const ActiveQueries(),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.receipt_long_outlined,
                                label: 'All Orders',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AllOrdersHistory(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
