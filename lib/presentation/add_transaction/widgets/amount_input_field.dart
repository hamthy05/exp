import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';


/// Amount input field with LKR currency formatting
class AmountInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AmountInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    // Remove any non-digit characters except decimal point
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points
    List<String> parts = cleanValue.split('.');
    if (parts.length > 2) {
      cleanValue = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit decimal places to 2
    if (parts.length == 2 && parts[1].length > 2) {
      cleanValue = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    return cleanValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: widget.errorText != null
                  ? theme.colorScheme.error
                  : _focusNode.hasFocus
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Text(
                  'Rs.',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 16.h,
                    ),
                  ),
                  onChanged: (value) {
                    final formatted = _formatCurrency(value);
                    if (formatted != value) {
                      widget.controller.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                    widget.onChanged?.call(formatted);
                  },
                ),
              ),
              SizedBox(width: 16.w),
            ],
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
