import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../app/routes.dart';
import '../../widgets/ticket/ticket_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTickets();
    });
  }

  void _initializeTickets() {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    ticketProvider.initAdminTickets();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        backgroundColor: AppColors.accentOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.name.split(' ').first ?? 'Admin'}! 👑',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Stats cards
                Consumer<TicketProvider>(
                  builder: (context, ticketProvider, child) {
                    return Row(
                      children: [
                        _buildStatCard(
                          context,
                          'Open',
                          ticketProvider.openCount.toString(),
                          AppColors.statusOpen,
                          Icons.error_outline,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          context,
                          'In Progress',
                          ticketProvider.inProgressCount.toString(),
                          AppColors.statusInProgress,
                          Icons.pending_outlined,
                        ),
                        const SizedBox(width: 8),
                        _buildStatCard(
                          context,
                          'Resolved',
                          ticketProvider.resolvedCount.toString(),
                          AppColors.statusResolved,
                          Icons.check_circle_outline,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Filter chips
          Consumer<TicketProvider>(
            builder: (context, ticketProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All Tickets',
                      ticketProvider.currentFilter == 'all',
                      () => ticketProvider.setFilter('all'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Open',
                      ticketProvider.currentFilter == 'open',
                      () => ticketProvider.setFilter('open'),
                      color: AppColors.statusOpen,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'In Progress',
                      ticketProvider.currentFilter == 'in progress',
                      () => ticketProvider.setFilter('in progress'),
                      color: AppColors.statusInProgress,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Resolved',
                      ticketProvider.currentFilter == 'resolved',
                      () => ticketProvider.setFilter('resolved'),
                      color: AppColors.statusResolved,
                    ),
                  ],
                ),
              );
            },
          ),

          // Tickets list
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, ticketProvider, child) {
                if (ticketProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  );
                }

                if (ticketProvider.tickets.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _initializeTickets();
                  },
                  color: AppColors.accentOrange,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: ticketProvider.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = ticketProvider.tickets[index];
                      return TicketCard(
                        ticket: ticket,
                        showReporter: true,
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.ticketDetails,
                            arguments: ticket.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.accentOrange) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.accentOrange) : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? AppColors.accentOrange).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Clear!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No tickets match the current filter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
