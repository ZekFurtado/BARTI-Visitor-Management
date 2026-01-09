import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitor_bloc.dart';

class PendingVisitorsScreen extends StatefulWidget {
  const PendingVisitorsScreen({super.key, required this.user});

  final LocalUser user;

  @override
  State<PendingVisitorsScreen> createState() => _PendingVisitorsScreenState();
}

class _PendingVisitorsScreenState extends State<PendingVisitorsScreen> {
  @override
  void initState() {
    super.initState();

    // Subscribe to real-time visitor updates based on user role
    if (widget.user.role == 'gatekeeper') {
      // Gatekeepers see all pending visitors
      context.read<VisitorBloc>().add(
        const GetVisitorsByStatusEvent(status: VisitorStatus.pending),
      );
    } else {
      // Employees see only their pending visitors
      context.read<VisitorBloc>().add(
        SubscribeToVisitorsForEmployeeEvent(employeeId: widget.user.uid ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Visitors'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<VisitorBloc, VisitorState>(
        builder: (context, state) {
          if (state is VisitorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VisitorError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load pending visitors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _refreshPendingVisitors(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is VisitorsLoaded) {
            final pendingVisitors = state.visitors
                .where((visitor) => visitor.status == VisitorStatus.pending)
                .toList();

            if (pendingVisitors.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending visitors',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.user.role == 'gatekeeper'
                            ? 'All visitors have been processed.'
                            : 'You have no pending visitor requests.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshPendingVisitors(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingVisitors.length,
                itemBuilder: (context, index) {
                  final visitor = pendingVisitors[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildVisitorCard(context, visitor),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _refreshPendingVisitors() {
    if (widget.user.role == 'gatekeeper') {
      context.read<VisitorBloc>().add(
        const GetVisitorsByStatusEvent(status: VisitorStatus.pending),
      );
    } else {
      context.read<VisitorBloc>().add(
        SubscribeToVisitorsForEmployeeEvent(employeeId: widget.user.uid ?? ''),
      );
    }
  }

  Widget _buildVisitorCard(BuildContext context, Visitor visitor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: visitor.photoUrl != null
                      ? NetworkImage(visitor.photoUrl!)
                      : null,
                  child: visitor.photoUrl == null
                      ? Text(
                          visitor.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        visitor.origin,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (visitor.phoneNumber?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          visitor.phoneNumber ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Purpose', visitor.purpose),
            if (visitor.expectedDuration != null)
              _buildDetailRow('Duration', visitor.expectedDuration!),
            if (visitor.notes?.isNotEmpty == true)
              _buildDetailRow('Notes', visitor.notes!),
            _buildDetailRow('Registered', _formatDateTime(visitor.createdAt)),

            // Show employee info for gatekeepers
            if (widget.user.role == 'gatekeeper' &&
                visitor.employeeToMeetName?.isNotEmpty == true)
              _buildDetailRow(
                'Employee to Meet',
                visitor.employeeToMeetName ?? 'Unknown',
              ),

            // Action buttons for employees only
            if (widget.user.role == 'employee') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _updateVisitorStatus(visitor, VisitorStatus.rejected),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateVisitorStatus(visitor, VisitorStatus.approved),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final visitDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (visitDay == today) {
      dateStr = 'Today';
    } else if (visitDay == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday';
    } else if (visitDay == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr at $timeStr';
  }

  void _updateVisitorStatus(Visitor visitor, VisitorStatus status) {
    context.read<VisitorBloc>().add(
      UpdateVisitorStatusEvent(visitorId: visitor.id ?? '', status: status),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Visitor ${status == VisitorStatus.approved ? 'approved' : 'rejected'} successfully',
        ),
        backgroundColor: status == VisitorStatus.approved
            ? Colors.green
            : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    log(
      'Visitor ${visitor.name} ${status == VisitorStatus.approved ? 'approved' : 'rejected'}',
    );
  }
}
