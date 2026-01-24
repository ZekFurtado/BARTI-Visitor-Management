import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management/core/common/user_provider.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Widget that conditionally renders children based on feature flag status
///
/// Wraps features that should only be available to organizations with specific
/// feature flags enabled. Shows fallback widget or hides content if feature is disabled.
///
/// Example usage:
/// ```dart
/// FeatureGuard(
///   featureName: 'visitorPhotos',
///   child: PhotoCaptureButton(),
///   fallback: Text('Photo capture not available in your plan'),
/// )
/// ```
class FeatureGuard extends StatelessWidget {
  /// Name of the feature to check (must match FeatureConfig property names)
  final String featureName;

  /// Widget to show if feature is enabled
  final Widget child;

  /// Optional widget to show if feature is disabled
  /// If null, nothing is rendered when feature is disabled
  final Widget? fallback;

  /// Optional callback when feature is disabled and user tries to access it
  final VoidCallback? onFeatureDisabled;

  /// Whether to show upgrade prompt when feature is disabled
  final bool showUpgradePrompt;

  const FeatureGuard({
    super.key,
    required this.featureName,
    required this.child,
    this.fallback,
    this.onFeatureDisabled,
    this.showUpgradePrompt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final organization = userProvider.currentOrganization;

        // If no organization context, hide feature (fail-safe)
        if (organization == null) {
          return fallback ?? const SizedBox.shrink();
        }

        // Check if feature is enabled
        final isEnabled = organization.features.isFeatureEnabled(featureName);

        if (isEnabled) {
          return child;
        }

        // Feature is disabled - handle accordingly
        if (onFeatureDisabled != null) {
          onFeatureDisabled!();
        }

        if (showUpgradePrompt) {
          return _UpgradePromptWidget(
            featureName: featureName,
            organizationName: organization.name,
          );
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Specialized feature guard for IconButtons
/// Automatically disables the button if feature is not available
class FeatureGuardIconButton extends StatelessWidget {
  final String featureName;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const FeatureGuardIconButton({
    super.key,
    required this.featureName,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final organization = userProvider.currentOrganization;
        final isEnabled =
            organization?.features.isFeatureEnabled(featureName) ?? false;

        return IconButton(
          icon: Icon(icon),
          onPressed: isEnabled
              ? onPressed
              : () => _showFeatureDisabledDialog(context, organization?.name),
          tooltip: isEnabled
              ? tooltip
              : 'This feature is not available in your plan',
          color: isEnabled ? color : Colors.grey,
        );
      },
    );
  }

  void _showFeatureDisabledDialog(BuildContext context, String? orgName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Not Available'),
        content: Text(
          'The "$featureName" feature is not available in your current plan. '
          'Please contact your administrator or upgrade your subscription to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to upgrade screen
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

/// Specialized feature guard for ElevatedButtons
class FeatureGuardElevatedButton extends StatelessWidget {
  final String featureName;
  final VoidCallback onPressed;
  final Widget child;

  const FeatureGuardElevatedButton({
    super.key,
    required this.featureName,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final organization = userProvider.currentOrganization;
        final isEnabled =
            organization?.features.isFeatureEnabled(featureName) ?? false;

        return ElevatedButton(
          onPressed: isEnabled
              ? onPressed
              : () => _showFeatureDisabledSnackBar(context),
          child: child,
        );
      },
    );
  }

  void _showFeatureDisabledSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'The "$featureName" feature is not available in your current plan',
        ),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: () {
            // TODO: Navigate to upgrade screen
          },
        ),
      ),
    );
  }
}

/// Widget shown when a feature is disabled and upgrade prompt is enabled
class _UpgradePromptWidget extends StatelessWidget {
  final String featureName;
  final String organizationName;

  const _UpgradePromptWidget({
    required this.featureName,
    required this.organizationName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade Required',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The "$featureName" feature is not available in your current plan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to upgrade screen or contact admin
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade Plan'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show more info about plans
              },
              child: const Text('Compare Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to check if a feature is enabled
/// Useful for conditional logic outside of widget tree
bool isFeatureEnabled(BuildContext context, String featureName) {
  final userProvider = context.read<UserProvider>();
  final organization = userProvider.currentOrganization;
  return organization?.features.isFeatureEnabled(featureName) ?? false;
}

/// Helper function to show feature disabled message
void showFeatureDisabledMessage(
  BuildContext context,
  String featureName, {
  bool showUpgradeOption = true,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Feature Not Available'),
      content: Text(
        'The "$featureName" feature is not included in your current subscription plan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        if (showUpgradeOption)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to upgrade screen
            },
            child: const Text('Upgrade Plan'),
          ),
      ],
    ),
  );
}

/// Extension on BuildContext for easy feature checking
extension FeatureCheckExtension on BuildContext {
  /// Check if a feature is enabled in the current organization
  bool hasFeature(String featureName) {
    return isFeatureEnabled(this, featureName);
  }

  /// Get the current organization from context
  Organization? get currentOrganization {
    return read<UserProvider>().currentOrganization;
  }

  /// Check if user can add more employees
  bool canAddEmployee(int currentCount) {
    final org = currentOrganization;
    return org?.features.canAddEmployee(currentCount) ?? false;
  }

  /// Check if user can add more gatekeepers
  bool canAddGatekeeper(int currentCount) {
    final org = currentOrganization;
    return org?.features.canAddGatekeeper(currentCount) ?? false;
  }
}
