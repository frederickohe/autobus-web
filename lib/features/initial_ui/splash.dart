import 'package:autobus/barrel.dart';

class SplashPge extends StatefulWidget {
  const SplashPge({super.key});

  @override
  State<SplashPge> createState() => _SplashPgeState();
}

class _SplashPgeState extends State<SplashPge> {
  void _goNext() {
    print('=== SPLASH BUTTON PRESSED - NAVIGATING ===');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;

              final titleTop = h * (101 / 926);
              final markTop = h * (154 / 926);
              final yourTop = h * (465 / 926);
              final autonomousTop = h * (515 / 926);
              final subtitleTop = h * (585 / 926);
              final buttonTop = h * (690 / 926);

              const textCol = Color(0xFF09050F);
              const brandCol = CustColors.mainCol;

              return Stack(
                children: [
                  SafeArea(
                    child: Stack(
                      children: [
                        Positioned(
                          top: titleTop,
                          left: 0,
                          right: 0,
                          child: Center(child: const AutobusWordmark()),
                        ),
                        Positioned(
                          top: markTop,
                          left: (w - 240) / 2,
                          child: SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              children: const [
                                Positioned(
                                  left: 90,
                                  top: 100,
                                  child: AutobusMark(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: yourTop,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              "Your",
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: textCol,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: autonomousTop,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              "Autonomous",
                              style: GoogleFonts.montserrat(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: textCol,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: subtitleTop,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              "Business operations assistant!",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textCol,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: buttonTop,
                          left: (w - 270) / 2,
                          child: SizedBox(
                            width: 270,
                            height: 51,
                            child: ElevatedButton(
                              onPressed: _goNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandCol,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Get Started",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
