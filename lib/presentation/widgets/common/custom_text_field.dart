import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final double borderRadius;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.fillColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: fillColor ?? (enabled ? AppColors.surfaceWhite : AppColors.backgroundLight),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: 22,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(
                  suffixIcon,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              )
            : null,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textHint,
            ),
        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
        counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

// Specialized text fields for common use cases
class EmailTextField extends CustomTextField {
  const EmailTextField({
    super.key,
    super.controller,
    super.label = 'Email Address',
    super.hint = 'Enter your email',
    super.validator,
    super.onChanged,
    super.enabled,
  }) : super(
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.next,
        );
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextInputAction textInputAction;

  const PasswordTextField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      onSuffixTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }
}

class SearchTextField extends CustomTextField {
  const SearchTextField({
    super.key,
    super.controller,
    super.hint = 'Search...',
    super.onChanged,
    super.onSubmitted,
  }) : super(
          prefixIcon: Icons.search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          borderRadius: 24,
        );
}

class MultilineTextField extends CustomTextField {
  const MultilineTextField({
    super.key,
    super.controller,
    super.label,
    super.hint,
    super.validator,
    super.onChanged,
    super.maxLength,
    super.enabled,
  }) : super(
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          contentPadding: const EdgeInsets.all(16),
        );
}

