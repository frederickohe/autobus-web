import 'package:autobus/barrel.dart';

class ManageCustomers extends StatelessWidget {
  const ManageCustomers({super.key});

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
                const ManageScreenHeader(title: 'Manage Customers'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Customers',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeTitleStyle(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Save contacts for your business — phone, email, and network — so you can message them quickly from SMS and email.',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                          ),
                          const SizedBox(height: 72),
                          ManageHubGrid(
                            children: [
                              ManageHubActionCard(
                                icon: Icons.person_add_outlined,
                                label: 'Add Customer',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const AddCustomerPage(),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.contacts_outlined,
                                label: 'View Customers',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const ViewCustomersPage(),
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
