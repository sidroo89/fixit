import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/ticket_provider.dart';
import '../../../app/routes.dart';
import '../../widgets/ticket/ticket_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTickets();
    });
  }

  void _initializeTickets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      ticketProvider.initUserTickets(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.myRequests),
        backgroundColor: AppColors.primaryTeal,
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
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name.split(' ').first ?? 'User'}! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your facility requests below',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),

          // Tickets list
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, ticketProvider, child) {
                if (ticketProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryTeal,
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
                  color: AppColors.primaryTeal,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: ticketProvider.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = ticketProvider.tickets[index];
                      return TicketCard(
                        ticket: ticket,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.createTicket);
        },
        backgroundColor: AppColors.primaryTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Issue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tickets Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to report\nyour first facility issue',
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
