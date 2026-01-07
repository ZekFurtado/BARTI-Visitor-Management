import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

/// Widget for searching visitor history
class VisitorHistorySearch extends StatefulWidget {
  final TextEditingController phoneController;
  final Function(String) onPhoneSearch;
  final Function(DateTime, DateTime) onDateRangeSearch;
  final VoidCallback onRecentVisits;

  const VisitorHistorySearch({
    super.key,
    required this.phoneController,
    required this.onPhoneSearch,
    required this.onDateRangeSearch,
    required this.onRecentVisits,
  });

  @override
  State<VisitorHistorySearch> createState() => _VisitorHistorySearchState();
}

class _VisitorHistorySearchState extends State<VisitorHistorySearch> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone search
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: const Icon(IconlyLight.call),
                  suffixIcon: IconButton(
                    icon: const Icon(IconlyLight.search),
                    onPressed: () {
                      final phone = widget.phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        widget.onPhoneSearch(phone);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
                onSubmitted: (value) {
                  final phone = value.trim();
                  if (phone.isNotEmpty) {
                    widget.onPhoneSearch(phone);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Date range search
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                'From Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                context,
                'To Date',
                _endDate,
                (date) => setState(() => _endDate = date),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(IconlyLight.calendar, size: 18),
              label: const Text('Search'),
              onPressed: (_startDate != null && _endDate != null)
                  ? () {
                      if (_startDate!.isAfter(_endDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Start date must be before end date'),
                          ),
                        );
                        return;
                      }
                      widget.onDateRangeSearch(_startDate!, _endDate!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Quick actions
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Recent Visits'),
              avatar: const Icon(IconlyLight.time_circle, size: 18),
              onSelected: (_) => widget.onRecentVisits(),
            ),
            FilterChip(
              label: const Text('Clear Phone'),
              avatar: const Icon(IconlyLight.delete, size: 18),
              onSelected: (_) {
                widget.phoneController.clear();
                widget.onRecentVisits();
              },
            ),
            FilterChip(
              label: const Text('Clear Dates'),
              avatar: const Icon(IconlyLight.close_square, size: 18),
              onSelected: (_) {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
                widget.onRecentVisits();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(IconlyLight.calendar, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Select date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}