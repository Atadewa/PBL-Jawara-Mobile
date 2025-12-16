import 'package:flutter/material.dart';

/// Reusable form field component untuk edit kegiatan
/// Supports text input dengan label, hint, prefix icon, dan validation indicator
class EditFormField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool readOnly;
  final IconData? prefixIcon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final String? errorText;

  const EditFormField({
    Key? key,
    required this.label,
    required this.isRequired,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefixIcon,
    this.onTap,
    this.validator,
    this.errorText,
  }) : super(key: key);

  @override
  State<EditFormField> createState() => _EditFormFieldState();
}

class _EditFormFieldState extends State<EditFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Label dengan indikator required
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (widget.isRequired)
              const SizedBox(width: 4)
            else
              const SizedBox(),
            if (widget.isRequired)
              const Text(
                '*',
                style: TextStyle(color: Color(0xFFFA2B36), fontSize: 16),
              ),
          ],
        ),

        // Text field dengan border dinamis
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: ShapeDecoration(
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1.28,
                  color: widget.errorText != null
                      ? const Color(0xFFFA2B36)
                      : _isFocused
                      ? const Color(0xFF10B981)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly || widget.onTap != null,
              maxLines: widget.maxLines,
              minLines: 1,
              validator: widget.validator,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? const Color(0xFF10B981)
                              : const Color(0xFFCBD5E1),
                          size: 20,
                        ),
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 0 : 16,
                  vertical: 12,
                ),
                suffixIcon: widget.readOnly && widget.prefixIcon == null
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.lock,
                          color: Color(0xFFCBD5E1),
                          size: 20,
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        // Error message di bawah field
        if (widget.errorText != null)
          Text(
            widget.errorText!,
            style: const TextStyle(
              color: Color(0xFFFA2B36),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
