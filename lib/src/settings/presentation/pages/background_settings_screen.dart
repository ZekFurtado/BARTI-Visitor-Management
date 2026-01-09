import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:visitor_management/core/services/background_service.dart';

class BackgroundSettingsScreen extends StatefulWidget {
  const BackgroundSettingsScreen({super.key});

  @override
  State<BackgroundSettingsScreen> createState() => _BackgroundSettingsScreenState();
}

class _BackgroundSettingsScreenState extends State<BackgroundSettingsScreen> {
  Map<String, dynamic>? serviceStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceStatus();
  }

  Future<void> _loadServiceStatus() async {
    setState(() => isLoading = true);
    
    try {
      final status = await BackgroundService.getServiceStatus();
      setState(() {
        serviceStatus = status;
        isLoading = false;
      });
    } catch (e) {
      log('Failed to load service status: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Notifications'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildInstructionsCard(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Background Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Configure your device to receive visitor notifications even when the app is closed.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    if (serviceStatus == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load status information',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final isAndroid = serviceStatus!['platform'] == 'android';
    final notificationsEnabled = serviceStatus!['notificationsEnabled'] ?? false;
    
    final batteryOptimizationDisabled = isAndroid 
        ? (serviceStatus!['batteryOptimizationDisabled'] ?? false)
        : true;
    
    final backgroundEnabled = isAndroid 
        ? (serviceStatus!['backgroundServiceRunning'] ?? false)
        : (serviceStatus!['backgroundAppRefreshEnabled'] ?? false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Notifications',
              notificationsEnabled,
              'App can show notifications',
            ),
            if (isAndroid) ...[
              _buildStatusItem(
                'Battery Optimization',
                batteryOptimizationDisabled,
                'App can run in background',
              ),
              _buildStatusItem(
                'Background Service',
                backgroundEnabled,
                'Background monitoring active',
              ),
            ] else ...[
              _buildStatusItem(
                'Background App Refresh',
                backgroundEnabled,
                'App can refresh in background',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isEnabled, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.error,
            color: isEnabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isEnabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Setup Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              BackgroundService.getBackgroundInstructions(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await BackgroundService.openBackgroundSettings();
              // Reload status after user potentially changes settings
              await Future.delayed(const Duration(seconds: 2));
              _loadServiceStatus();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Device Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await BackgroundService.restartBackgroundService();
              _loadServiceStatus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Restart Background Service'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _loadServiceStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}