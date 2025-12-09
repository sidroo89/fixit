import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/ticket_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ticket_provider.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  TicketModel? _ticket;
  bool _isLoading = true;
  TicketStatus? _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final ticket = await ticketProvider.getTicket(widget.ticketId);
    
    if (mounted) {
      setState(() {
        _ticket = ticket;
        _selectedStatus = ticket?.status;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null || _selectedStatus == _ticket?.status) return;

    setState(() {
      _isUpdating = true;
    });

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final success = await ticketProvider.updateTicketStatus(
      widget.ticketId,
      _selectedStatus!,
    );

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.ticketUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        _loadTicket(); // Reload to get updated data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.errorMessage ?? AppStrings.errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? _buildNotFound()
              : CustomScrollView(
                  slivers: [
                    // Image header
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      backgroundColor: AppColors.primaryTeal,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _ticket!.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _ticket!.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.backgroundTeal,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Container(
                        transform: Matrix4.translationValues(0, -24, 0),
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                _ticket!.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),

                              // Meta info row
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _buildInfoChip(
                                    Icons.calendar_today_outlined,
                                    DateFormat('MMM d, yyyy').format(_ticket!.createdAt),
                                  ),
                                  _buildInfoChip(
                                    Icons.flag_outlined,
                                    _ticket!.priority.displayName,
                                    color: AppColors.getPriorityColor(
                                        _ticket!.priority.displayName),
                                  ),
                                  _buildInfoChip(
                                    Icons.category_outlined,
                                    _ticket!.category.displayName,
                                  ),
                                  _buildInfoChip(
                                    Icons.person_outline,
                                    _ticket!.createdByName,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Description
                              Text(
                                'Description',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  _ticket!.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.6,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Status section
                              Text(
                                'Status',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),

                              if (isAdmin)
                                _buildStatusSelector()
                              else
                                _buildStatusDisplay(),

                              const SizedBox(height: 24),

                              // Update button (admin only)
                              if (isAdmin && _selectedStatus != _ticket!.status)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating ? null : _updateStatus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentOrange,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: _isUpdating
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.check, color: Colors.white),
                                    label: Text(
                                      _isUpdating ? 'Updating...' : AppStrings.updateStatus,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                              // Timeline (if resolved)
                              if (_ticket!.resolvedAt != null) ...[
                                const SizedBox(height: 24),
                                _buildTimeline(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.backgroundTeal,
      child: Center(
        child: Icon(
          _getCategoryIcon(_ticket!.category),
          size: 80,
          color: AppColors.primaryTeal.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primaryTeal).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.primaryTeal),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppColors.primaryTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(_ticket!.status.displayName)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getStatusColor(_ticket!.status.displayName),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(_ticket!.status),
            color: AppColors.getStatusColor(_ticket!.status.displayName),
          ),
          const SizedBox(width: 8),
          Text(
            _ticket!.status.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getStatusColor(_ticket!.status.displayName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: TicketStatus.values.map((status) {
        final isSelected = _selectedStatus == status;
        final color = AppColors.getStatusColor(status.displayName);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: isSelected ? Colors.white : color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resolved',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'on ${DateFormat('MMM d, yyyy at h:mm a').format(_ticket!.resolvedAt!)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.success.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Ticket not found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Icons.error_outline;
      case TicketStatus.inProgress:
        return Icons.pending_outlined;
      case TicketStatus.resolved:
        return Icons.check_circle_outline;
    }
  }

  IconData _getCategoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.it:
        return Icons.computer;
      case TicketCategory.electrical:
        return Icons.electrical_services;
      case TicketCategory.plumbing:
        return Icons.plumbing;
      case TicketCategory.hvac:
        return Icons.ac_unit;
      case TicketCategory.furniture:
        return Icons.chair;
      case TicketCategory.other:
        return Icons.more_horiz;
    }
  }
}

