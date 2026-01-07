import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

import '../bloc/visitor_history_bloc.dart';
import '../widgets/visitor_history_item.dart';
import '../widgets/visitor_history_search.dart';

/// Screen for displaying visitor history
class VisitorHistoryScreen extends StatefulWidget {
  /// The user role (gatekeeper or employee)
  final String userRole;

  /// The current user's ID
  final String userId;

  const VisitorHistoryScreen({
    super.key,
    required this.userRole,
    required this.userId,
  });

  @override
  State<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load recent visitors by default
    context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: VisitorHistorySearch(
              phoneController: _phoneController,
              onPhoneSearch: (phone) {
                if (phone.isNotEmpty) {
                  context.read<VisitorHistoryBloc>().add(
                    GetVisitorHistoryByPhoneEvent(phoneNumber: phone),
                  );
                }
              },
              onDateRangeSearch: (startDate, endDate) {
                context.read<VisitorHistoryBloc>().add(
                  GetVisitorsByDateRangeEvent(
                    startDate: startDate,
                    endDate: endDate,
                  ),
                );
              },
              onRecentVisits: () {
                context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent());
              },
            ),
          ),
          // Results section
          Expanded(
            child: BlocConsumer<VisitorHistoryBloc, VisitorHistoryState>(
              listener: (context, state) {
                if (state is VisitorHistoryLoading) {
                  // Show loading indicator if needed
                } else if (state is VisitorHistoryError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _buildContent(context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, VisitorHistoryState state) {
    if (state is VisitorHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is VisitorHistoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconlyLight.danger,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading visit history',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () => context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent()),
            ),
          ],
        ),
      );
    } else if (state is VisitorHistoryLoaded) {
      if (state.visitors.isEmpty) {
        return _buildEmptyState(context, state);
      } else {
        return _buildVisitorList(context, state);
      }
    } else {
      return _buildInitialState(context);
    }
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.document,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Visit History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by phone number or view recent visits',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(IconlyLight.calendar),
            label: const Text('View Recent Visits'),
            onPressed: () => context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, VisitorHistoryLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.paper_fail,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No visits found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No visitors found for "${state.searchDescription}"',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(IconlyLight.calendar),
            label: const Text('View All Recent Visits'),
            onPressed: () => context.read<VisitorHistoryBloc>().add(const GetRecentVisitorsEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorList(BuildContext context, VisitorHistoryLoaded state) {
    return Column(
      children: [
        // Results header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search Results',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.visitors.length} visit(s) found for "${state.searchDescription}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Visitor list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.visitors.length,
            itemBuilder: (context, index) {
              final visitor = state.visitors[index];
              return VisitorHistoryItem(
                visitor: visitor,
                showEmployeeInfo: widget.userRole == 'gatekeeper',
              );
            },
          ),
        ),
      ],
    );
  }
}
