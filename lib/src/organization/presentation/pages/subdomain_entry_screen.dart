import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:visitor_management/core/services/tenant_config_service.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Screen for entering organization subdomain on first launch
/// Shown when no cached subdomain is found
class SubdomainEntryScreen extends StatefulWidget {
  final TenantConfigService tenantService;
  final VoidCallback? onRestart;

  const SubdomainEntryScreen({
    super.key,
    required this.tenantService,
    this.onRestart,
  });

  @override
  State<SubdomainEntryScreen> createState() => _SubdomainEntryScreenState();
}

class _SubdomainEntryScreenState extends State<SubdomainEntryScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connectToOrganization() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final subdomain = _controller.text.trim().toLowerCase();
      log('Attempting to connect to subdomain: $subdomain',
          name: 'SubdomainEntryScreen');

      // Fetch organization config from registry
      final organization = await widget.tenantService.fetchTenantConfig(subdomain);

      // Save subdomain for future launches
      await widget.tenantService.saveSubdomain(subdomain);

      log('Successfully connected to organization: ${organization.name}',
          name: 'SubdomainEntryScreen');

      // Show success and instruct user to restart
      if (mounted) {
        _showSuccessDialog(organization);
      }
    } on TenantNotFoundException catch (e) {
      log('Organization not found: $e', name: 'SubdomainEntryScreen');
      setState(() {
        _errorMessage = 'Organization not found. Please check your subdomain and try again.';
      });
    } on TenantSuspendedException catch (e) {
      log('Organization suspended: $e', name: 'SubdomainEntryScreen');
      setState(() {
        _errorMessage = 'This organization is currently suspended. Please contact support.';
      });
    } on TenantConfigurationException catch (e) {
      log('Configuration error: $e', name: 'SubdomainEntryScreen');
      setState(() {
        _errorMessage = 'Unable to load organization configuration. Please try again later.';
      });
    } catch (e) {
      log('Unexpected error: $e', name: 'SubdomainEntryScreen');
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(Organization organization) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            const Text('Connected!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successfully connected to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              organization.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please restart the app to complete the setup.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRestart?.call();
            },
            child: const Text('Restart App'),
          ),
        ],
      ),
    );
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanning
    // This would open a QR code scanner that can read organization codes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code scanning coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.business,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Connect to Your Organization',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Enter your organization subdomain to get started',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Subdomain input field
                  TextFormField(
                    controller: _controller,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Organization Subdomain',
                      hintText: 'e.g., barti',
                      prefixIcon: const Icon(Icons.domain),
                      suffixText: '.epravesh.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subdomain';
                      }

                      final subdomain = value.trim().toLowerCase();
                      if (!TenantConfigService.isValidSubdomain(subdomain)) {
                        return 'Invalid subdomain format. Use lowercase letters, numbers, and hyphens only.';
                      }

                      return null;
                    },
                    onFieldSubmitted: (_) => _connectToOrganization(),
                  ),
                  const SizedBox(height: 24),

                  // Connect button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _connectToOrganization,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Connect',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // QR Code scan button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _scanQRCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan QR Code'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Help text
                  Text(
                    'Don\'t know your subdomain?',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show help dialog or contact support
                      _showHelpDialog();
                    },
                    child: const Text('Contact your administrator'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your organization subdomain is a unique identifier for your organization in E-Pravesh.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Example:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'If your organization URL is:\nbarti.epravesh.com\n\nYour subdomain is: barti',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contact your organization administrator or IT department if you need assistance.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
