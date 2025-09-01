import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showFilter;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showFilter = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _isSearchActive = widget.initialQuery?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchActive
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _isSearchActive = value.isNotEmpty;
                  });
                  widget.onSearchChanged?.call(value);
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: _isSearchActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                  suffixIcon: _isSearchActive
                      ? GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _controller.clear();
                            setState(() {
                              _isSearchActive = false;
                            });
                            widget.onSearchChanged?.call('');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (widget.showFilter) ...[
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onFilterPressed?.call();
              },
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'tune',
                    color: theme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
