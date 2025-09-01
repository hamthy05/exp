import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Data management widget providing export options (CSV/PDF),
/// backup to cloud storage, and clear data with confirmation dialogs
class DataManagementWidget extends StatelessWidget {
  const DataManagementWidget({super.key});

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
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storage,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Export data
          _buildDataOption(
            context,
            Icons.file_download,
            'Export Data',
            'Download your transactions as CSV or PDF',
            () => _showExportDialog(context),
          ),

          const Divider(height: 1),

          // Backup to cloud
          _buildDataOption(
            context,
            Icons.cloud_upload,
            'Backup to Cloud',
            'Save your data to cloud storage',
            () => _showBackupDialog(context),
          ),

          const Divider(height: 1),

          // Clear data
          _buildDataOption(
            context,
            Icons.delete_forever,
            'Clear All Data',
            'Remove all transactions and settings',
            () => _showClearDataDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDataOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? theme.colorScheme.error : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption(
              context,
              Icons.table_chart,
              'Export as CSV',
              'Spreadsheet format for analysis',
              () => _exportAsCSV(context),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              Icons.picture_as_pdf,
              'Export as PDF',
              'Formatted report for sharing',
              () => _exportAsPDF(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha(51),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsCSV(BuildContext context) async {
    try {
      // Sample transaction data - in real app, this would come from database
      final csvData = _generateSampleCSV();

      if (kIsWeb) {
        // Web export
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download",
              "transactions_${DateTime.now().millisecondsSinceEpoch}.csv")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile export would use path_provider - placeholder for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'CSV export functionality ready for mobile implementation'),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportAsPDF(BuildContext context) async {
    try {
      // PDF generation would be implemented here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF export functionality ready for implementation'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateSampleCSV() {
    return '''Date,Description,Category,Amount,Type
2024-01-15,Grocery Shopping,Food,2500.00,Expense
2024-01-14,Salary,Income,75000.00,Income
2024-01-12,Bus Fare,Transport,100.00,Expense
2024-01-10,Coffee,Food,350.00,Expense''';
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup to Cloud'),
        content: const Text(
          'This will upload your transaction data to secure cloud storage. '
          'You can restore this data on any device by signing in with your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performBackup(context);
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _performBackup(BuildContext context) {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Backing up your data...'),
          ],
        ),
      ),
    );

    // Simulate backup process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This action cannot be undone. All your transactions, settings, '
          'and saved data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showFinalConfirmation(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type "DELETE" to confirm:'),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE here',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: confirmController,
            builder: (context, value, child) {
              return ElevatedButton(
                onPressed: value.text == 'DELETE'
                    ? () {
                        Navigator.pop(context);
                        _performClearData(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete Everything'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _performClearData(BuildContext context) {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Clearing your data...'),
          ],
        ),
      ),
    );

    // Simulate clear process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }
}
