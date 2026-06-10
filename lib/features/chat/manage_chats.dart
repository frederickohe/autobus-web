import 'package:autobus/barrel.dart';

class ManageChats extends StatefulWidget {
  const ManageChats({super.key});

  @override
  State<ManageChats> createState() => _ManageChatsState();
}

class _ManageChatsState extends State<ManageChats> {
  bool _loadRequested = false;
  bool _loading = true;
  String? _statusError;

  bool _chatwootConfigured = false;
  bool _chatwootProvisioned = false;
  bool _subscriptionActive = false;

  /// Inbox total from Chatwoot when fetched; `null` if not fetched or fetch failed.
  int? _linkedInboxTotal;
  bool _inboxesFetchFailed = false;

  String _shortError(String raw, {int max = 160}) {
    final t = raw.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  Future<void> _loadChannelIntegrationState() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _statusError = null;
      _inboxesFetchFailed = false;
    });
    try {
      final api = context.read<ApiService>();
      final status = await api.getChatwootStatus();
      if (!mounted) return;

      final configured = status['chatwoot_configured'] as bool? ?? false;
      final provisioned = status['chatwoot_provisioned'] as bool? ?? false;
      final subActive = status['subscription_active'] as bool? ?? false;

      int? inboxTotal;
      var inboxFailed = false;

      if (configured && provisioned && subActive) {
        try {
          inboxTotal = await api.getChatwootInboxTotal();
        } catch (_) {
          inboxFailed = true;
        }
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _chatwootConfigured = configured;
        _chatwootProvisioned = provisioned;
        _subscriptionActive = subActive;
        _linkedInboxTotal = inboxFailed ? null : inboxTotal;
        _inboxesFetchFailed = inboxFailed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusError = e.toString();
        _linkedInboxTotal = null;
        _inboxesFetchFailed = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadRequested) return;
    _loadRequested = true;
    _loadChannelIntegrationState();
  }

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
                  title: 'Manage Inbox',
                  creditCategory: CreditCategory.llm,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Inbox',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeTitleStyle(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Deliver instant, intelligent customer support with AI trained on your business data through linked social messaging channels.',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                          ),
                          const SizedBox(height: 32),
                          if (_loading) ...[
                            const SizedBox(height: 8),
                            const Center(
                              child:                               const AutobusLoadingIndicator(size: 28),
                            ),
                            const SizedBox(height: 24),
                          ] else if (_statusError != null) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.12,
                              ),
                              borderColor: Colors.amber.withValues(alpha: 0.45),
                              icon: Icons.cloud_off_outlined,
                              iconColor: Colors.amber.shade300,
                              trailing: IconButton(
                                onPressed: _loadChannelIntegrationState,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 22,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              child: Text(
                                'Could not load Chatwoot status. Check your connection and try again.\n${_shortError(_statusError!)}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (!_chatwootConfigured) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.12,
                              ),
                              borderColor: Colors.amber.withValues(alpha: 0.45),
                              icon: Icons.settings_suggest_outlined,
                              iconColor: Colors.amber.shade300,
                              child: Text(
                                'Chat linking is not enabled on this server (Chatwoot is not configured).',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (!_chatwootProvisioned) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: const Color(
                                0xFF581C87,
                              ).withValues(alpha: 0.1),
                              borderColor: const Color(
                                0xFF9333EA,
                              ).withValues(alpha: 0.5),
                              icon: Icons.warning_rounded,
                              iconColor: Colors.red.shade400,
                              child: Text(
                                'No Chatwoot workspace is linked to your account yet. An active subscription provisions your workspace.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (!_subscriptionActive) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.12,
                              ),
                              borderColor: Colors.amber.withValues(alpha: 0.45),
                              icon: Icons.lock_outline,
                              iconColor: Colors.amber.shade300,
                              child: Text(
                                'An active subscription is required to link messaging channels in Chatwoot.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (_inboxesFetchFailed) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.12,
                              ),
                              borderColor: Colors.amber.withValues(alpha: 0.45),
                              icon: Icons.cloud_off_outlined,
                              iconColor: Colors.amber.shade300,
                              trailing: IconButton(
                                onPressed: _loadChannelIntegrationState,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 22,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              child: Text(
                                'Could not load your Chatwoot inboxes. Pull to refresh after reconnecting.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if ((_linkedInboxTotal ?? 0) == 0) ...[
                            _ChatwootMessagePanel(
                              backgroundColor: const Color(
                                0xFF581C87,
                              ).withValues(alpha: 0.1),
                              borderColor: const Color(
                                0xFF9333EA,
                              ).withValues(alpha: 0.5),
                              icon: Icons.warning_rounded,
                              iconColor: Colors.red.shade400,
                              child: Text(
                                'You have not linked any messaging channel in Chatwoot yet. Use Link Channel to add WhatsApp, Facebook, and other inboxes.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else
                            const SizedBox(height: 8),
                          const SizedBox(height: 40),
                          ManageHubGrid(
                            children: [
                              ManageHubActionCard(
                                icon: Icons.link_outlined,
                                label: 'Link Channel',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const ManageChannels(),
                                    ),
                                  ).then((_) {
                                    if (mounted) {
                                      _loadChannelIntegrationState();
                                    }
                                  });
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.mark_chat_unread_outlined,
                                label: 'Live Chats',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const LiveChatsPage(),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.chat_bubble_outline,
                                label: 'All Chats',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const AllChatsPage(),
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

class _ChatwootMessagePanel extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final Widget child;

  const _ChatwootMessagePanel({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
