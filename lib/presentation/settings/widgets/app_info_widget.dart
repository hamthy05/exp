import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App information widget displaying version number, privacy policy link,
/// terms of service, and contact support options
class AppInfoWidget extends StatelessWidget {
  const AppInfoWidget({super.key});

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
                    color: Colors.indigo.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'App Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // App version
          _buildInfoItem(
            context,
            Icons.app_registration,
            'Version',
            '1.0.0 (Build 1)',
            null,
            showTrailing: false,
          ),

          const Divider(height: 1),

          // Privacy policy
          _buildInfoItem(
            context,
            Icons.privacy_tip,
            'Privacy Policy',
            'How we protect your data',
            () => _openPrivacyPolicy(context),
          ),

          const Divider(height: 1),

          // Terms of service
          _buildInfoItem(
            context,
            Icons.description,
            'Terms of Service',
            'App usage terms and conditions',
            () => _openTermsOfService(context),
          ),

          const Divider(height: 1),

          // Contact support
          _buildInfoItem(
            context,
            Icons.support_agent,
            'Contact Support',
            'Get help with the app',
            () => _contactSupport(context),
          ),

          const Divider(height: 1),

          // Rate app
          _buildInfoItem(
            context,
            Icons.star_rate,
            'Rate ExpenseVoice',
            'Share your feedback',
            () => _rateApp(context),
          ),

          const Divider(height: 1),

          // About developer
          _buildInfoItem(
            context,
            Icons.code,
            'About Developer',
            'Learn more about the team',
            () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool showTrailing = true,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSurfaceVariant,
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
              if (showTrailing && onTap != null)
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

  void _openPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'ExpenseVoice Privacy Policy\n\n'
            'Your privacy is important to us. This privacy statement explains '
            'the personal data ExpenseVoice processes, how we process it, and for what purposes.\n\n'
            'Data Collection:\n'
            '• Transaction data is stored locally on your device\n'
            '• Voice recordings are processed locally and not transmitted\n'
            '• No personal data is shared with third parties\n\n'
            'Data Security:\n'
            '• All data is encrypted on your device\n'
            '• Optional cloud backup uses end-to-end encryption\n'
            '• You can delete all data at any time\n\n'
            'Contact us if you have questions about this privacy policy.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'ExpenseVoice Terms of Service\n\n'
            'By using ExpenseVoice, you agree to these terms:\n\n'
            'Usage:\n'
            '• Use the app for personal expense tracking only\n'
            '• Do not attempt to reverse engineer the app\n'
            '• Report bugs and issues through proper channels\n\n'
            'Liability:\n'
            '• The app is provided "as is" without warranties\n'
            '• We are not liable for data loss or financial decisions\n'
            '• Users are responsible for backing up their data\n\n'
            'Updates:\n'
            '• Terms may be updated with app updates\n'
            '• Continued use constitutes acceptance of new terms\n\n'
            'Last updated: January 2024',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help? Choose a support option:'),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              Icons.email,
              'Email Support',
              'support@expensevoice.com',
              () => _sendEmail(context),
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              context,
              Icons.bug_report,
              'Report Bug',
              'Report technical issues',
              () => _reportBug(context),
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              context,
              Icons.help,
              'FAQ',
              'Frequently asked questions',
              () => _showFAQ(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(
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

  void _sendEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
      ),
    );
  }

  void _reportBug(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug report functionality ready for implementation'),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: const SingleChildScrollView(
          child: Text(
            'Q: How do I backup my data?\n'
            'A: Go to Settings > Data Management > Backup to Cloud\n\n'
            'Q: Can I export my transactions?\n'
            'A: Yes, you can export as CSV or PDF from Data Management\n\n'
            'Q: Is my voice data stored?\n'
            'A: No, voice processing happens locally on your device\n\n'
            'Q: How do I change the app language?\n'
            'A: Go to Settings > Language and select your preference\n\n'
            'Q: Can I set spending limits?\n'
            'A: Yes, create goals in the Savings Goals section\n\n'
            'Q: How do I reset the app?\n'
            'A: Go to Settings > Data Management > Clear All Data',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate ExpenseVoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enjoying ExpenseVoice? Please rate us!'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  5,
                  (index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      )),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ExpenseVoice',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'ExpenseVoice is a smart expense tracking app that uses voice input '
          'to make recording transactions quick and easy.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Developed with ❤️ using Flutter',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
