import 'package:autobus/barrel.dart';
import 'package:flutter/services.dart';

abstract final class WebAuthColors {
  static const bg = Color(0xFFF6F8FF);
  static const brand = Color(0xFF2A1447);
  static const fieldFill = Color(0xFF2A1447);
  static const borderStart = Color(0xFF8692A6);
  static const borderEnd = Color(0xFF343840);
}

class WebAuthScaffold extends StatelessWidget {
  const WebAuthScaffold({
    super.key,
    required this.form,
    this.imageAsset = 'assets/img/logintech.png',
  });

  final Widget form;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebAuthColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 980;

            if (isNarrow) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    form,
                    const SizedBox(height: 32),
                    _WebAuthImagePanel(imageAsset: imageAsset, height: 360),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(64, 32, 64, 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 445, child: form),
                  const SizedBox(width: 112),
                  Expanded(child: _WebAuthImagePanel(imageAsset: imageAsset)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WebAuthImagePanel extends StatelessWidget {
  const _WebAuthImagePanel({required this.imageAsset, this.height});

  final String imageAsset;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height ?? 960,
        width: double.infinity,
        child: Image.asset(imageAsset, fit: BoxFit.cover),
      ),
    );
  }
}

class WebAuthLogo extends StatelessWidget {
  const WebAuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        AutobusMark(circleSize: 40),
        SizedBox(width: 9),
        AutobusWordmark(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          baseColor: WebAuthColors.brand,
          accentColor: CustColors.logodeep,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

class WebAuthHeading extends StatelessWidget {
  const WebAuthHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class WebAuthField extends StatefulWidget {
  const WebAuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool showVisibilityToggle;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<WebAuthField> createState() => _WebAuthFieldState();
}

class _WebAuthFieldState extends State<WebAuthField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(WebAuthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showVisibilityToggle &&
        widget.obscureText != oldWidget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [WebAuthColors.borderStart, WebAuthColors.borderEnd],
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: WebAuthColors.fieldFill,
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              obscureText: _obscured,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: widget.showVisibilityToggle
                    ? IconButton(
                        onPressed: () => setState(() => _obscured = !_obscured),
                        icon: Icon(
                          _obscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WebAuthPinField extends StatelessWidget {
  const WebAuthPinField({
    super.key,
    required this.label,
    required this.controllers,
    required this.focusNodes,
    this.enabled = true,
    this.onCompleted,
  });

  final String label;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool enabled;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    assert(controllers.length == 4 && focusNodes.length == 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 4; index++) ...[
                if (index > 0) const SizedBox(width: 16),
                _WebAuthPinCell(
                  index: index,
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  focusNodes: focusNodes,
                  enabled: enabled,
                  onChanged: (value) => _handleChanged(index, value),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
        onCompleted?.call();
      }
      return;
    }

    if (index > 0) {
      controllers[index - 1].clear();
      focusNodes[index - 1].requestFocus();
    }
  }
}

class _WebAuthPinCell extends StatelessWidget {
  const _WebAuthPinCell({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.focusNodes,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<FocusNode> focusNodes;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [WebAuthColors.borderStart, WebAuthColors.borderEnd],
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          color: WebAuthColors.fieldFill,
          borderRadius: BorderRadius.circular(7),
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          obscureText: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: onChanged,
          onTap: () {
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          },
          onSubmitted: (_) {
            if (index < 3) focusNodes[index + 1].requestFocus();
          },
        ),
      ),
    );
  }
}

class WebAuthOutlinedButton extends StatelessWidget {
  const WebAuthOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: WebAuthColors.brand,
          side: const BorderSide(color: WebAuthColors.brand),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class WebAuthCheckboxRow extends StatelessWidget {
  const WebAuthCheckboxRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: (checked) => onChanged(checked ?? false),
            activeColor: WebAuthColors.brand,
            side: const BorderSide(color: Colors.black, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class WebAuthGhanaCardField extends StatelessWidget {
  const WebAuthGhanaCardField({
    super.key,
    required this.digitsController,
    required this.checkDigitController,
    required this.checkDigitFocusNode,
    this.enabled = true,
  });

  final TextEditingController digitsController;
  final TextEditingController checkDigitController;
  final FocusNode checkDigitFocusNode;
  final bool enabled;

  static const _prefix = 'GHA';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghana Card*',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [WebAuthColors.borderStart, WebAuthColors.borderEnd],
            ),
          ),
          padding: const EdgeInsets.all(1),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: WebAuthColors.fieldFill,
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _prefix,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '-',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: digitsController,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXXXXXXXX',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      if (value.length == 9) {
                        FocusScope.of(
                          context,
                        ).requestFocus(checkDigitFocusNode);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '-',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(
                  width: 24,
                  child: TextField(
                    controller: checkDigitController,
                    focusNode: checkDigitFocusNode,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'X',
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WebAuthFooterLink extends StatelessWidget {
  const WebAuthFooterLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: prefix),
              TextSpan(
                text: action,
                style: const TextStyle(
                  color: WebAuthColors.brand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
