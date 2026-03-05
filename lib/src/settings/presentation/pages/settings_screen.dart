import 'package:flutter/material.dart';
import 'package:visitor_management/core/utils/routes.dart';
import 'package:visitor_management/src/legal/legal_content.dart';

/// Main settings screen that groups app and legal/compliance options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── App Settings ────────────────────────────────────────────────
          _SectionHeader(title: 'App Settings'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Background Notifications',
            subtitle: 'Configure background notification delivery',
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.backgroundSettings),
          ),

          const Divider(height: 1),

          // ── Legal & Compliance ───────────────────────────────────────────
          _SectionHeader(title: 'Legal & Compliance'),
          _LegalTile(
            icon: Icons.article_outlined,
            title: 'Terms & Conditions',
            type: LegalDocumentType.termsAndConditions,
          ),
          _LegalTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            type: LegalDocumentType.privacyPolicy,
          ),
          _LegalTile(
            icon: Icons.gavel_outlined,
            title: 'End User License Agreement (EULA)',
            type: LegalDocumentType.eula,
          ),
          _LegalTile(
            icon: Icons.delete_outline,
            title: 'Data & Account Deletion',
            type: LegalDocumentType.dataDeletion,
          ),

          const Divider(height: 1),

          // ── Support ──────────────────────────────────────────────────────
          _SectionHeader(title: 'Support'),
          _LegalTile(
            icon: Icons.support_agent_outlined,
            title: 'Contact & Support',
            type: LegalDocumentType.contactSupport,
          ),

          const SizedBox(height: 32),

          // App version footer
          Center(
            child: Text(
              'E-Pravesh v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© ${DateTime.now().year} BARTI',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.title,
    required this.type,
  });

  final IconData icon;
  final String title;
  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.of(context).pushNamed(
        Routes.legalDocument,
        arguments: type,
      ),
    );
  }
}
