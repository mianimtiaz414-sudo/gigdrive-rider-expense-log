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
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(4, (int i) {
        final bool filled = i < length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
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
    required this.onBackspace,
    this.size = 72,
    this.rowGap = 14,
  });

  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final double size;
  final double rowGap;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> rows = <List<String>>[
      <String>['1', '2', '3'],
      <String>['4', '5', '6'],
      <String>['7', '8', '9'],
    ];
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final List<String> row in rows) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (final String digit in row)
                  _PadKey(
                    size: size,
                    onTap: () => onDigit(digit),
                    child: _DigitLabel(digit),
                  ),
              ],
            ),
            SizedBox(height: rowGap),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(width: size, height: size),
              _PadKey(
                size: size,
                onTap: () => onDigit('0'),
                child: const _DigitLabel('0'),
              ),
              _PadKey(
                size: size,
                onTap: onBackspace,
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

class _DigitLabel extends StatelessWidget {
  const _DigitLabel(this.digit);

  final String digit;

  @override
  Widget build(BuildContext context) {
    return Text(
      digit,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    required this.size,
    required this.onTap,
    required this.child,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;

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
