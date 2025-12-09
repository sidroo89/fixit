import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../app/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: authProvider.isAdmin
            ? AppColors.accentOrange
            : AppColors.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: authProvider.isAdmin
                    ? AppColors.accentOrange
                    : AppColors.primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: user?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(user.name),
                            ),
                          )
                        : _buildAvatarPlaceholder(user?.name ?? 'U'),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    user?.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? 'USER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account section
                  _buildSectionTitle(context, 'Account'),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () {
                        // TODO: Implement edit profile
                        _showComingSoon(context);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        // TODO: Implement change password
                        _showComingSoon(context);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Preferences section
                  _buildSectionTitle(context, AppStrings.appearance),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppStrings.darkMode,
                      trailing: Switch(
                        value: false, // TODO: Implement dark mode
                        onChanged: (value) {
                          _showComingSoon(context);
                        },
                        activeTrackColor: AppColors.primaryTeal,
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.language_outlined,
                      title: AppStrings.language,
                      subtitle: 'English',
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // General section
                  _buildSectionTitle(context, 'General'),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications,
                      onTap: () {
                        AppRoutes.navigateTo(context, AppRoutes.notifications);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.security_outlined,
                      title: AppStrings.privacySecurity,
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: AppStrings.helpSupport,
                      onTap: () {
                        _showComingSoon(context);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App version
                  Center(
                    child: Text(
                      'FixIt Now v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.backgroundTeal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryTeal, size: 22),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (context.mounted) {
      AppRoutes.navigateAndClearStack(context, AppRoutes.login);
    }
  }
}

