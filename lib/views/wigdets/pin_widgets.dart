import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, this.hasError = false});

  final int length;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final Color active = hasError ? AppColors.expense : AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(4, (int i) {
        final bool filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? active : Colors.transparent,
            border: Border.all(
              color: filled ? active : AppColors.textSecondary,
              width: 2,
            ),
            boxShadow: filled
                ? const <BoxShadow>[
                    BoxShadow(color: AppColors.primaryGlow, blurRadius: 12),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}



class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.size = 76,
    this.rowGap = 18,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onDelete;
  final double size;
  final double rowGap;

  Widget _row(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys
          .map((String k) => _KeyShell(
                size: size,
                onTap: () => onDigit(k),
                child: Text(
                  k,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _row(<String>['1', '2', '3']),
          SizedBox(height: rowGap),
          _row(<String>['4', '5', '6']),
          SizedBox(height: rowGap),
          _row(<String>['7', '8', '9']),
          SizedBox(height: rowGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(width: size, height: size),
              _KeyShell(
                size: size,
                onTap: () => onDigit('0'),
                child: const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _KeyShell(
                size: size,
                onTap: onDelete,
                child: const Icon(
                  Icons.backspace_outlined,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyShell extends StatelessWidget {
  const _KeyShell({
    required this.child,
    required this.onTap,
    required this.size,
  });

  final Widget child;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Center(child: child),
        ),
      ),
    );
  }
}


class PinScreen extends StatelessWidget {
  const PinScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.errorText,
    required this.onDigit,
    required this.onDelete,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int pinLength;
  final String errorText;
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;

  
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double topGap = compact ? 4 : 40;
    final double iconBox = compact ? 64 : 84;
    final double iconSize = compact ? 30 : 40;
    final double afterIcon = compact ? 14 : 24;
    final double afterSubtitle = compact ? 22 : 36;
    final double keypadSize = compact ? 66 : 76;
    final double rowGap = compact ? 12 : 18;
    final double bottomGap = compact ? 16 : 32;

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: topGap),
                      Container(
                        width: iconBox,
                        height: iconBox,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySoft,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.primary,
                          size: iconSize,
                        ),
                      ),
                      SizedBox(height: afterIcon),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: afterSubtitle),
                      PinDots(
                        length: pinLength,
                        hasError: errorText.isNotEmpty,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 22,
                        child: Text(
                          errorText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.expense,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      PinKeypad(
                        onDigit: onDigit,
                        onDelete: onDelete,
                        size: keypadSize,
                        rowGap: rowGap,
                      ),
                      SizedBox(height: bottomGap),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
