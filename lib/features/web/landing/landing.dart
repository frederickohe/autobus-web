import 'package:autobus/barrel.dart';
import 'package:autobus/features/web/landing/auth_choice_page.dart';
import 'package:autobus/features/web/landing/landing_footer.dart';
import 'package:autobus/features/web/landing/public_site_chatbot.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scrollController = ScrollController();
  final _aboutSectionKey = GlobalKey();

  static const _bg = Color(0xFFF6F8FF);
  static const _ink = Color(0xFF000000);
  static const _muted = Color(0xFF474B64);
  static const _outline = Color(0xFFDCE0EC);
  void _scrollToAbout() {
    final context = _aboutSectionKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 980;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _HeroSection(isNarrow: isNarrow, onReadMore: _scrollToAbout),
                const SizedBox(height: 6),
                const _OrganizationsSlider(),
                const SizedBox(height: 6),
                _AboutMetricsSection(
                  sectionKey: _aboutSectionKey,
                  isNarrow: isNarrow,
                  onGetStarted: () => AuthChoicePage.openSignup(context),
                ),
                LandingFooter(
                  isNarrow: isNarrow,
                  onGetStarted: () => AuthChoicePage.openSignup(context),
                ),
              ],
            ),
          );
        },
      ),
          const PublicSiteChatbot(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isNarrow, required this.onReadMore});

  final bool isNarrow;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                AutobusMark(circleSize: 40),
                SizedBox(width: 9),
                AutobusWordmark(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  baseColor: Color(0xFF2A1447),
                  accentColor: CustColors.logodeep,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const SizedBox(height: 70),
            Text(
              'The new business experience with AI, today',
              style: GoogleFonts.montserrat(
                fontSize: isNarrow ? 40 : 64,
                fontWeight: FontWeight.w700,
                height: 1.08,
                color: _LandingPageState._ink,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Transform your business with our new Artificial Intelligence engine that allows you to control your business and organization with a simple voice command interface',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: _LandingPageState._muted,
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _PrimaryButton(
                  label: 'Get Started',
                  onPressed: () => AuthChoicePage.openSignup(context),
                ),
                _SecondaryButton(label: 'Read More', onPressed: onReadMore),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );

    final heroImage = ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(58)),
      child: Image.asset(
        'assets/img/landingtop.jpg',
        fit: BoxFit.cover,
        width: double.infinity,
        height: isNarrow ? 360 : 798,
      ),
    );

    if (isNarrow) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            content,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: heroImage,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return SizedBox(
      height: 798,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: content),
          ),
          SizedBox(width: 619, child: heroImage),
        ],
      ),
    );
  }
}

class _OrganizationsSlider extends StatefulWidget {
  const _OrganizationsSlider();

  @override
  State<_OrganizationsSlider> createState() => _OrganizationsSliderState();
}

class _OrganizationsSliderState extends State<_OrganizationsSlider> {
  static const _organizations = [
    _OrgEntry(name: 'Company', icon: Icons.apartment_outlined),
    _OrgEntry(name: 'Startup', icon: Icons.trending_up_rounded),
    _OrgEntry(name: 'Organization', icon: Icons.hub_outlined),
    _OrgEntry(name: 'Enterprise', icon: Icons.grid_view_rounded),
    _OrgEntry(name: 'Venture', icon: Icons.link_rounded),
    _OrgEntry(name: 'Retail', icon: Icons.storefront_outlined),
    _OrgEntry(name: 'Agency', icon: Icons.groups_outlined),
  ];

  final _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      final next = _scrollController.offset + 1.2;
      if (next >= max) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [..._organizations, ..._organizations];

    return SizedBox(
      height: 124,
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 72),
            itemBuilder: (context, index) => _OrgLogoTile(entry: items[index]),
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: _EdgeFade(align: Alignment.centerLeft),
          ),
          const Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _EdgeFade(align: Alignment.centerRight),
          ),
        ],
      ),
    );
  }
}

class _OrgEntry {
  const _OrgEntry({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

class _OrgLogoTile extends StatelessWidget {
  const _OrgLogoTile({required this.entry});

  final _OrgEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(entry.icon, size: 28, color: const Color(0xFF1E293B)),
        const SizedBox(width: 12),
        Text(
          entry.name,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.align});

  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: align,
            end: align == Alignment.centerLeft
                ? Alignment.centerRight
                : Alignment.centerLeft,
            colors: const [Color(0xFFF6F8FF), Color(0x00F6F8FF)],
          ),
        ),
      ),
    );
  }
}

class _AboutMetricsSection extends StatelessWidget {
  const _AboutMetricsSection({
    required this.sectionKey,
    required this.isNarrow,
    required this.onGetStarted,
  });

  final Key sectionKey;
  final bool isNarrow;
  final VoidCallback onGetStarted;

  static const _metrics = [
    _Metric(label: 'Businesses', value: '200'),
    _Metric(label: 'Team members', value: '50'),
    _Metric(label: 'AI operations', value: '5M'),
    _Metric(label: 'Years of experience', value: '15'),
  ];

  @override
  Widget build(BuildContext context) {
    final leftContent = _AboutCopy(
      isNarrow: isNarrow,
      onGetStarted: onGetStarted,
    );
    final centerImage = _AiCircleImage(isNarrow: isNarrow);
    final metrics = _MetricsPanel(metrics: _metrics, isNarrow: isNarrow);

    return Container(
      key: sectionKey,
      width: double.infinity,
      color: _LandingPageState._bg,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 80,
        vertical: isNarrow ? 48 : 80,
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftContent,
                const SizedBox(height: 40),
                Center(child: centerImage),
                const SizedBox(height: 40),
                metrics,
              ],
            )
          : SizedBox(
              height: 680,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: leftContent),
                  Expanded(flex: 5, child: Center(child: centerImage)),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: metrics,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AiCircleImage extends StatelessWidget {
  const _AiCircleImage({required this.isNarrow});

  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final size = isNarrow ? 280.0 : 400.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16 : 32,
        vertical: isNarrow ? 16 : 24,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset('assets/img/aicircle.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _AboutCopy extends StatelessWidget {
  const _AboutCopy({required this.isNarrow, required this.onGetStarted});

  final bool isNarrow;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.7,
      color: const Color(0xFF64748B),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Autobus',
          style: GoogleFonts.montserrat(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustColors.mainCol,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Get Started →',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isNarrow ? 340 : 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Autobus brings AI-powered operations to businesses of every size. '
                'From voice commands to automated workflows, we help teams run smarter '
                'and move faster.',
                style: bodyStyle,
              ),
              const SizedBox(height: 16),
              Text(
                'Join the growing number of companies using Autobus to streamline '
                'customer engagement, marketing, orders, and day-to-day operations.',
                style: bodyStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.metrics, required this.isNarrow});

  final List<_Metric> metrics;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isNarrow ? double.infinity : 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            _MetricRow(metric: metrics[i], isNarrow: isNarrow),
            if (i < metrics.length - 1)
              const Divider(height: 32, thickness: 1, color: Color(0xFFE2E8F0)),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric, required this.isNarrow});

  final _Metric metric;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metric.label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: isNarrow ? 36 : 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            children: [
              TextSpan(
                text: '+',
                style: const TextStyle(color: CustColors.mainCol),
              ),
              TextSpan(text: metric.value),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustColors.mainCol,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _LandingPageState._ink,
          side: const BorderSide(color: _LandingPageState._outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
