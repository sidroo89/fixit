import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ticket_model.dart';
import 'package:intl/intl.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  final bool showReporter;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
    this.showReporter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              _buildThumbnail(),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      ticket.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Category & Date
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(ticket.category),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.category.displayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y').format(ticket.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    
                    // Reporter (for admin view)
                    if (showReporter) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'By: ${ticket.createdByName}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status chip
              _buildStatusChip(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        height: 70,
        child: ticket.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: ticket.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.backgroundLight,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.backgroundLight,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : Container(
                color: AppColors.backgroundTeal,
                child: Icon(
                  _getCategoryIcon(ticket.category),
                  color: AppColors.primaryTeal,
                  size: 32,
                ),
              ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(ticket.status.displayName),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ticket.status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
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

// Compact ticket card for notifications or smaller displays
class TicketCardCompact extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCardCompact({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.getStatusColor(ticket.status.displayName),
        child: Icon(
          _getStatusIcon(ticket.status),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        ticket.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${ticket.category.displayName} • ${DateFormat('MMM d').format(ticket.createdAt)}',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
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
}

