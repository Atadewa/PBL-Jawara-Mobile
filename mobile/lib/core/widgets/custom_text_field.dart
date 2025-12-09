import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatelessWidget {
  final Key? textFieldKey;
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.textFieldKey,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: textFieldKey,
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
