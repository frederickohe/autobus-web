import 'package:autobus/barrel.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  static const _bg = Color(0xFFF6F8FF);
  static const _brand = Color(0xFF2A1447);
  static const _outline = Color(0xFFDCE0EC);

  static void openSignup(BuildContext context) {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 300),
        child: const Signup(),
      ),
    );
  }

  void _goToSignup(BuildContext context) => openSignup(context);

  void _goToSignin(BuildContext context) {
    Navigator.of(context).push(
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        childCurrent: const AuthChoicePage(),
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 300),
        child: const Signin(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 980;

            if (isNarrow) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _ChoicePanel(
                      onJoin: () => _goToSignup(context),
                      onLogin: () => _goToSignin(context),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _IllustrationImage(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ChoicePanel(
                    onJoin: () => _goToSignup(context),
                    onLogin: () => _goToSignin(context),
                  ),
                ),
                const Expanded(child: _IllustrationPanel()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({required this.onJoin, required this.onLogin});

  final VoidCallback onJoin;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 543),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  AutobusMark(circleSize: 40),
                  SizedBox(width: 9),
                  AutobusWordmark(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    baseColor: AuthChoicePage._brand,
                    accentColor: CustColors.logodeep,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              const SizedBox(height: 27),
              Text(
                'New to Autobus?',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 27),
              Column(
                children: [
                  _FilledButton(label: 'Join Autobus', onPressed: onJoin),
                  const SizedBox(height: 20),
                  _OutlinedButton(label: 'Login', onPressed: onLogin),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: _IllustrationImage(),
      ),
    );
  }
}

class _IllustrationImage extends StatelessWidget {
  const _IllustrationImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/workingai.png',
      fit: BoxFit.contain,
      width: 614,
      height: 555,
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.label, required this.onPressed});

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
          backgroundColor: AuthChoicePage._brand,
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({required this.label, required this.onPressed});

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
          foregroundColor: AuthChoicePage._brand,
          side: const BorderSide(color: AuthChoicePage._outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
