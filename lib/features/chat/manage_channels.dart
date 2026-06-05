import 'package:autobus/barrel.dart';
import 'package:autobus/features/chat/channel_catalog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageChannels extends StatefulWidget {
  const ManageChannels({super.key});

  @override
  State<ManageChannels> createState() => _ManageChannelsState();
}

class _ManageChannelsState extends State<ManageChannels> {
  var _loading = true;
  String? _loadError;
  List<LinkedChannel> _linked = [];
  List<ChannelOption> _unlinked = ChannelCatalog.all;

  @override
  void initState() {
    super.initState();
    _refreshInboxes();
  }

  Future<void> _refreshInboxes() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final api = context.read<ApiService>();
      final inboxes = await api.listChatwootInboxes();
      if (!mounted) return;
      final split = ChannelCatalog.partition(inboxes);
      setState(() {
        _linked = split.linked;
        _unlinked = split.unlinked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _linked = [];
        _unlinked = ChannelCatalog.all;
        _loading = false;
      });
    }
  }

  Future<void> _linkChannel(ChannelOption channel) async {
    final api = context.read<ApiService>();
    await openEmbeddedPlatformSession(
      context,
      title: 'Link ${channel.label}',
      fetchSession: () => api.getChatwootChannelLink(channel.apiSlug),
    );

    if (mounted) {
      await _refreshInboxes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: ManageScreenStyle.homeDashboardBodyDecoration,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Manage Channels',
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                      if (!_loading)
                        IconButton(
                          onPressed: _refreshInboxes,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          tooltip: 'Refresh',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _loading
                        ? const Center(child: AutobusLoadingIndicator(size: 32))
                        : RefreshIndicator(
                            onRefresh: _refreshInboxes,
                            color: Colors.white,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_loadError != null) ...[
                                    Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.amber.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Text(
                                    'Linked Channels',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_linked.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        'No channels linked yet. Add a messaging inbox below.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          height: 1.45,
                                        ),
                                      ),
                                    )
                                  else
                                    _ChannelGrid(
                                      children: [
                                        for (final item in _linked)
                                          _ChannelCard(
                                            label: item.channel.label,
                                            subtitle: item.subtitle,
                                            icon: FaIcon(item.channel.icon),
                                            iconColor: item.channel.iconColor,
                                            isLinked: true,
                                            onTap: () =>
                                                _linkChannel(item.channel),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Select to Link Channel',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'You will be signed in to your Chatwoot workspace automatically, then guided to add the inbox for that channel.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_unlinked.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'All available channels are linked.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else
                                    _ChannelGrid(
                                      children: [
                                        for (final channel in _unlinked)
                                          _ChannelCard(
                                            label: channel.label,
                                            icon: FaIcon(channel.icon),
                                            iconColor: channel.iconColor,
                                            onTap: () =>
                                                _linkChannel(channel),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelGrid extends StatelessWidget {
  final List<Widget> children;

  const _ChannelGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 133 / 89,
      children: children,
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget icon;
  final Color iconColor;
  final bool isLinked;
  final VoidCallback onTap;

  const _ChannelCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.isLinked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1333).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLinked ? const Color(0xFF22C55E) : const Color(0xFF3F1163),
            width: isLinked ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 40),
                child: icon,
              ),
            ),
            if (isLinked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 18,
                ),
              ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
