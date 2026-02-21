import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/components/navbar.dart';
import 'package:foodapin/components/navbar_admin.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_cubit.dart';
import 'package:foodapin/features/profile/bloc/current/current_user_bloc.dart';
import 'package:foodapin/features/profile/bloc/current/current_user_event.dart';
import 'package:foodapin/features/profile/bloc/current/current_user_state.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CurrentUserBloc(userRepository: context.read<UserRepository>())
                ..add(GetCurrentUser()),
        ),
      ],
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserBloc, CurrentUserState>(
        builder: (context, state) {
          final role = state is CurrentUserLoaded ? state.user.role : 'user';
          final isAdmin = role == 'admin';
          const profileIndex = 3;

          return Scaffold(
            backgroundColor: AppTheme.fourtenary,
            body: _buildBody(context, state),
            bottomNavigationBar: SafeArea(
              child: isAdmin
                  ? CurvedBottomNavBarAdmin(
                      currentIndex: profileIndex,
                      onTap: (index) {
                        if (index == profileIndex) return;
                        if (index == 0) {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        } else if (index == 1) {
                          Navigator.pushReplacementNamed(context, '/users');
                        } else if (index == 2) {
                          Navigator.pushReplacementNamed(
                              context, '/transactions');
                        } else if (index == 3) {
                          Navigator.pushReplacementNamed(
                              context, '/profile');
                        }
                      },
                    )
                  : CurvedBottomNavBar(
                      currentIndex: profileIndex,
                      onTap: (index) {
                        if (index == profileIndex) return;
                        if (index == 0) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else if (index == 1) {
                          Navigator.pushReplacementNamed(
                              context, '/my-transactions');
                        } else if (index == 2) {
                          Navigator.pushReplacementNamed(
                              context, '/my-likes');
                        } else if (index == 3) {
                          Navigator.pushReplacementNamed(
                              context, '/profile');
                        }
                      },
                    ),
            ),
          );
        },
    );
  }

  Widget _buildBody(BuildContext context, CurrentUserState state) {
    if (state is CurrentUserLoading || state is CurrentUserInitial) {
      return SafeArea(
        child: Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true)),
      );
    } else if (state is CurrentUserError) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    style: AppTheme.bodyStyle, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                  onPressed: () =>
                      context.read<CurrentUserBloc>().add(GetCurrentUser()),
                  child: Text('Retry', style: AppTheme.buttonStyle),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (state is CurrentUserLoaded) {
      return _ProfileContent(user: state.user);
    }
    return const SizedBox.shrink();
  }
}

class _ProfileContent extends StatelessWidget {
  final Users user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, screenWidth),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'User',
                  style: AppTheme.headingStyle.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == 'admin'
                        ? AppTheme.primary.withValues(alpha: 0.12)
                        : AppTheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _capitalize(user.role),
                    style: AppTheme.cardTitle.copyWith(
                      color: user.role == 'admin'
                          ? AppTheme.primary
                          : AppTheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionLabel('Account Info'),
                const SizedBox(height: 10),
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: user.name.isNotEmpty ? user.name : '-',
                    ),
                    _divider(),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email.isNotEmpty ? user.email : '-',
                    ),
                    _divider(),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phoneNumber.isNotEmpty
                          ? user.phoneNumber
                          : '-',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionLabel('Settings'),
                const SizedBox(height: 10),
                _InfoCard(
                  children: [
                    _ActionRow(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () async {
                        final updated = await Navigator.pushNamed(
                          context,
                          '/update-profile',
                          arguments: user,
                        );
                        if (updated == true && context.mounted) {
                          context
                              .read<CurrentUserBloc>()
                              .add(GetCurrentUser());
                        }
                      },
                    ),
                    _divider(),
                    _ActionRow(
                      icon: Icons.logout,
                      label: 'Sign Out',
                      isDestructive: true,
                      onTap: () => _showLogoutSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth) {
    final initials = _getInitials(user.name);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: screenWidth,
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary,
                AppTheme.primary.withValues(alpha: 0.75),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Profile',
                style: AppTheme.headingStyle
                    .copyWith(color: AppTheme.white),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -52,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.white,
                border: Border.all(color: AppTheme.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: user.profilePictureUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.profilePictureUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _initialsAvatar(initials),
                      ),
                    )
                  : _initialsAvatar(initials),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.fourtenary,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.headingStyle
              .copyWith(color: AppTheme.primary, fontSize: 30),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTheme.titleDetail.copyWith(fontSize: 14)),
      );

  Widget _divider() => Divider(
        height: 1,
        color: Colors.grey.shade100,
        indent: 16,
        endIndent: 16,
      );

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LogoutSheet(parentContext: context),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.cardBody
                        .copyWith(color: Colors.grey.shade500, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.cardTitle.copyWith(
                    fontSize: 14,
                    color: valueColor ?? AppTheme.black,
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

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTheme.primary : AppTheme.black;
    final iconColor = isDestructive ? AppTheme.primary : AppTheme.primary;
    final iconBg = isDestructive
        ? Colors.red.shade50
        : AppTheme.primary.withValues(alpha: 0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style:
                    AppTheme.cardTitle.copyWith(fontSize: 14, color: color),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDestructive
                  ? AppTheme.primary
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutSheet extends StatelessWidget {
  final BuildContext parentContext;

  const _LogoutSheet({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text('Sign Out',
              style: AppTheme.headingStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            'Are you sure you want to sign out?',
            style: AppTheme.bodyStyle.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: AppTheme.cardTitle.copyWith(
                          color: AppTheme.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);

                    await parentContext.read<AuthCubit>().logout();

                    Navigator.pushNamedAndRemoveUntil(
                      parentContext,
                      '/signin',
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Out',
                        style: AppTheme.cardTitle.copyWith(
                          color: AppTheme.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}