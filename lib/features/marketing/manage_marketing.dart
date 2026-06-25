import 'package:autobus/barrel.dart';

class ManageMarketing extends StatelessWidget {
  const ManageMarketing({super.key});

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
                const ManageScreenHeader(
                  title: 'Manage Marketing',
                  creditCategory: CreditCategory.imageGen,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Marketing',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeTitleStyle(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Create smarter campaigns, generate marketing content, and reach the right audience with AI-driven tools.',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 8),
                          const SizedBox(height: 40),
                          ManageHubGrid(
                            children: [
                              ManageHubActionCard(
                                icon: Icons.campaign_outlined,
                                label: 'Create Campaigns',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const DigitalMarketingSelection(),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.link_outlined,
                                label: 'Link Social Media',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const ManageOutlets(),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.history_edu_outlined,
                                label: 'Recent campaigns',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const RecentCampaignsPage(),
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
