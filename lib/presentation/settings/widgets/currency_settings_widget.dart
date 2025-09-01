import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Currency settings widget for LKR format customization and decimal precision
class CurrencySettingsWidget extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  const CurrencySettingsWidget({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.attach_money,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Currency Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Currency format options
          _buildCurrencyOption(
            context,
            'LKR',
            'Sri Lankan Rupee (Rs. 1,000.00)',
            '🇱🇰',
          ),

          _buildCurrencyOption(
            context,
            'USD',
            'US Dollar (\$1,000.00)',
            '🇺🇸',
          ),

          _buildCurrencyOption(
            context,
            'EUR',
            'Euro (€1,000.00)',
            '🇪🇺',
          ),

          _buildCurrencyOption(
            context,
            'GBP',
            'British Pound (£1,000.00)',
            '🇬🇧',
          ),

          const Divider(height: 1),

          // Decimal precision setting
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decimal Precision',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Show amounts with 2 decimal places',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: true, // Default to 2 decimal places
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    // Handle decimal precision toggle
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context,
    String value,
    String displayName,
    String flag,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedCurrency == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onCurrencyChanged(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected) ...[
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ] else ...[
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
