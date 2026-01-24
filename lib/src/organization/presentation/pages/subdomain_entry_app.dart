import 'package:flutter/material.dart';
import 'package:visitor_management/core/services/tenant_config_service.dart';
import 'package:visitor_management/src/organization/presentation/pages/subdomain_entry_screen.dart';

/// Minimal MaterialApp wrapper for SubdomainEntryScreen
/// Used when no tenant configuration is available and we need to collect subdomain
class SubdomainEntryApp extends StatelessWidget {
  final TenantConfigService tenantService;

  const SubdomainEntryApp({
    super.key,
    required this.tenantService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Pravesh Setup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFA5013),
        ),
        useMaterial3: true,
      ),
      home: SubdomainEntryScreen(tenantService: tenantService),
    );
  }
}

/// Error app shown when tenant configuration fails to load
class TenantConfigErrorApp extends StatelessWidget {
  final dynamic error;

  const TenantConfigErrorApp({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Pravesh Error',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load organization configuration.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement retry or restart
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Clear cache and start over
                  },
                  child: const Text('Clear cache and try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
