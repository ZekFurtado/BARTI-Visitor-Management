import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management/src/visitor/domain/entities/visitor.dart';
import 'package:visitor_management/src/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../../../core/utils/routes.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key, required this.user});

  final LocalUser user;

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  // Cache the last known visitors to prevent flash on state changes
  List<Visitor> _lastKnownVisitors = [];

  @override
  void initState() {
    super.initState();
    // Initialize with real-time stream only to avoid state conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log('🔄 Setting up real-time stream for employee: ${widget.user.uid}');
      
      // Only use the stream subscription - no initial one-time load
      // This prevents the "flash then disappear" issue
      context.read<VisitorBloc>().add(
        SubscribeToVisitorsForEmployeeEvent(
          employeeId: widget.user.uid ?? '',
        ),
      );

      // Subscribe to real-time dashboard statistics for this employee  
      context.read<DashboardBloc>().add(
        SubscribeToEmployeeStatsEvent(employeeId: widget.user.uid ?? ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BARTI - Employee'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.notifications, arguments: widget.user);
                },
              ),
              // Notification badge
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                log('Navigate to profile');
                // TODO: Navigate to profile screen
              } else if (value == 'logout') {
                context.read<AuthenticationBloc>().add(SignOutUserEvent());
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login,
                      (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) =>
            [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Welcome Card
          Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme
                    .of(context)
                    .colorScheme
                    .primary,
                Theme
                    .of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${widget.user.name ?? 'Employee'}!',
                style: Theme
                    .of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have visitor requests to review',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary
                      .withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.user.jobRole ?? 'Employee'} • ${widget.user
                        .department ?? 'Department'}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Pending Visitors Section
        Text(
          'Pending Visitor Requests',
          style: Theme
              .of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Real pending visitor cards from Firestore (real-time updates)
        BlocListener<VisitorBloc, VisitorState>(
          listener: (context, state) {
            // Update cached visitors when we get new data
            if (state is VisitorsLoaded) {
              setState(() {
                _lastKnownVisitors = state.visitors;
              });
              log('🔄 Updated cached visitors: ${_lastKnownVisitors.length} visitors');
            }
          },
          child: BlocBuilder<VisitorBloc, VisitorState>(
            builder: (context, state) {
              log('🔍 Current VisitorBloc state: ${state.runtimeType}');
              
              // Use cached visitors if available, otherwise use current state
              List<Visitor> visitorsToDisplay = _lastKnownVisitors;
              
              if (state is VisitorsLoaded) {
                visitorsToDisplay = state.visitors;
                log('✅ VisitorsLoaded: ${visitorsToDisplay.length} total visitors');
              } else if (state is VisitorLoading && _lastKnownVisitors.isEmpty) {
                log('⏳ VisitorBloc state: Initial Loading');
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is VisitorError && _lastKnownVisitors.isEmpty) {
                log('❌ VisitorBloc error: ${state.message}');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading visitor requests',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.read<VisitorBloc>().add(
                                SubscribeToVisitorsForEmployeeEvent(
                                  employeeId: widget.user.uid ?? '',
                                ),
                              ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              log('Employee ID being checked: ${widget.user.uid}');
              
              for (final visitor in visitorsToDisplay) {
                log('Visitor: ${visitor.name} | Employee: ${visitor.employeeToMeetId} | Status: ${visitor.status}');
              }
              
              final pendingVisitors = visitorsToDisplay.where(
                    (visitor) => visitor.status == VisitorStatus.pending,
              ).toList();
              
              log('🔴 Found ${pendingVisitors.length} pending visitors from ${visitorsToDisplay.length} total');

              if (pendingVisitors.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pending visitor requests',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll see new visitor requests here when they arrive.',
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: pendingVisitors
                    .take(5) // Show only first 5 pending visitors
                    .map((visitor) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildPendingVisitorCard(
                        context,
                        visitor,
                            () => _handleVisitorAction(visitor),
                      ),
                    ))
                    .toList(),
              );
            },
          ),
        ),

          const SizedBox(height: 24),

          // Quick Stats
          Text(
            'Today\'s Statistics',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoaded) {
                final stats = state.stats;
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Pending',
                        stats.pendingApprovals.toString(),
                        Icons.pending_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Approved',
                        stats.approvedToday.toString(),
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Rejected',
                        stats.rejectedToday.toString(),
                        Icons.cancel_outlined,
                        Colors.red,
                      ),
                    ),
                  ],
                );
              }

              // Show loading or default stats
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Pending',
                      '--',
                      Icons.pending_outlined,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Approved',
                      '--',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Rejected',
                      '--',
                      Icons.cancel_outlined,
                      Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  log('Navigate to visitor history');
                  Navigator.of(context).pushNamed(
                      Routes.visitorHistory, arguments: {
                    'userRole': 'employee',
                    'userId': widget.user.uid,
                  });
                },
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View History'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent activity - show recent approved/rejected visitors
          BlocBuilder<VisitorBloc, VisitorState>(
            builder: (context, state) {
              if (state is VisitorsLoaded) {
                final recentActivity = state.visitors
                    .where((visitor) =>
                visitor.status == VisitorStatus.approved ||
                    visitor.status == VisitorStatus.rejected)
                    .take(3)
                    .toList();

                if (recentActivity.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No recent activity',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return Column(
                  children: recentActivity.map((visitor) {
                    final isApproved = visitor.status == VisitorStatus.approved;
                    final timeAgo = _getTimeAgo(
                        visitor.updatedAt ?? visitor.createdAt);

                    return _buildActivityItem(
                      context,
                      '${isApproved
                          ? 'Approved'
                          : 'Rejected'} visitor: ${visitor.name}',
                      timeAgo,
                      isApproved ? Icons.check_circle : Icons.cancel,
                      isApproved ? Colors.green : Colors.red,
                    );
                  }).toList(),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Loading recent activity...',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme
            .of(context)
            .colorScheme
            .primary,
        unselectedItemColor: Theme
            .of(context)
            .colorScheme
            .onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
            // Already on home
              break;
            case 1:
              Navigator.of(context).pushNamed(Routes.pendingVisitors, arguments: widget.user);
              break;
            case 2:
              Navigator.of(context).pushNamed(Routes.notifications, arguments: widget.user);
              break;
            case 3:
              log('Navigate to profile');
              break;
          }
        },
      ),
    );
  }

  void _handleVisitorAction(Visitor visitor) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Visitor Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${visitor.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('From: ${visitor.origin}'),
                const SizedBox(height: 8),
                Text('Purpose: ${visitor.purpose}'),
                if (visitor.expectedDuration != null) ...[
                  const SizedBox(height: 8),
                  Text('Duration: ${visitor.expectedDuration}'),
                ],
                if (visitor.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${visitor.notes}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _updateVisitorStatus(visitor, VisitorStatus.rejected);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateVisitorStatus(visitor, VisitorStatus.approved);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _updateVisitorStatus(Visitor visitor, VisitorStatus status) {
    context.read<VisitorBloc>().add(
      UpdateVisitorStatusEvent(
        visitorId: visitor.id ?? '',
        status: status,
      ),
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Visitor ${status == VisitorStatus.approved
              ? 'approved'
              : 'rejected'} successfully',
        ),
        backgroundColor: status == VisitorStatus.approved
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Yesterday' : '${difference
          .inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1
          ? ''
          : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1
          ? ''
          : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildPendingVisitorCard(BuildContext context,
      Visitor visitor,
      VoidCallback onTap,) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    backgroundImage: visitor.photoUrl != null
                        ? NetworkImage(visitor.photoUrl!)
                        : null,
                    child: visitor.photoUrl == null
                        ? Text(
                      visitor.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          visitor.origin,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
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
              const SizedBox(height: 12),
              Text(
                'Purpose: ${visitor.purpose}',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
              ),
              if (visitor.expectedDuration != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Duration: ${visitor.expectedDuration}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _updateVisitorStatus(visitor, VisitorStatus.rejected);
                      },
                      icon: Icon(Icons.close, size: 18),
                      label: Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _updateVisitorStatus(visitor, VisitorStatus.approved);
                      },
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme
              .of(context)
              .colorScheme
              .outline
              .withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme
                .of(context)
                .colorScheme
                .shadow
                .withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme
                .of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme
                .of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context,
      String title,
      String time,
      IconData icon,
      Color color,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}