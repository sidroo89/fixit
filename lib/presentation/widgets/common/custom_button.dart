import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum ButtonType { primary, secondary, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius = 28,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isLoading && !isDisabled && onPressed != null;

    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context, isEnabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, isEnabled);
      case ButtonType.outlined:
        return _buildOutlinedButton(context, isEnabled);
      case ButtonType.text:
        return _buildTextButton(context, isEnabled);
    }
  }

  Widget _buildPrimaryButton(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryTeal,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: AppColors.borderMedium,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.accentOrange,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: AppColors.borderMedium,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool isEnabled) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primaryTeal,
          side: BorderSide(
            color: isEnabled ? AppColors.primaryTeal : AppColors.borderMedium,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(textColor ?? AppColors.primaryTeal),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryTeal,
      ),
      child: _buildButtonContent(textColor ?? AppColors.primaryTeal),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Convenience constructors
class PrimaryButton extends CustomButton {
  const PrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.icon,
    super.width,
  }) : super(type: ButtonType.primary);
}

class SecondaryButton extends CustomButton {
  const SecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.icon,
    super.width,
  }) : super(type: ButtonType.secondary);
}

class OutlinedAppButton extends CustomButton {
  const OutlinedAppButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.icon,
    super.width,
  }) : super(type: ButtonType.outlined);
}

