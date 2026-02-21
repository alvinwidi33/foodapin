import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/components/navbar_admin.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/admin/users/bloc/users_bloc.dart';
import 'package:foodapin/features/admin/users/bloc/users_event.dart';
import 'package:foodapin/features/admin/users/bloc/users_state.dart';
import 'package:lottie/lottie.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  final int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersBloc(
        userRepository: context.read<UserRepository>(),
      )..add(FetchUsersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Users", style: AppTheme.headingStyle),
          backgroundColor: AppTheme.white,
          foregroundColor: AppTheme.black,
          elevation: 0,
        ),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            if (state is UsersLoading) {
              return Center(child: Lottie.asset('assets/loading.json', width: 200, height: 200, repeat: true));
            }

            if (state is UsersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTheme.bodyStyle.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UsersBloc>().add(FetchUsersEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                      ),
                      child: Text("Retry", style: AppTheme.buttonStyle),
                    ),
                  ],
                ),
              );
            }

            if (state is UsersLoaded) {
              if (state.users.isEmpty) {
                return Center(
                  child: Text(
                    "No users found.",
                    style: AppTheme.bodyStyle.copyWith(color: Colors.grey.shade600),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  context.read<UsersBloc>().add(FetchUsersEvent());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = state.users[index];

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.fourtenary,
                            backgroundImage: user.profilePictureUrl.isNotEmpty
                                ? NetworkImage(user.profilePictureUrl)
                                : null,
                            child: user.profilePictureUrl.isEmpty
                                ? const Icon(Icons.person, color: AppTheme.primary, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name, style: AppTheme.titleDetail),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: AppTheme.subtitleDetail,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                if (user.phoneNumber.isNotEmpty)
                                  Text(
                                    user.phoneNumber,
                                    style: AppTheme.subtitleDetail,
                                  ),
                              ],
                            ),
                          ),

                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user.role == 'admin'
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : AppTheme.fourtenary,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: user.role == 'admin'
                                    ? AppTheme.primary
                                    : AppTheme.tertiary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.role,
                              style: AppTheme.cardBody.copyWith(
                                color: user.role == 'admin'
                                    ? AppTheme.primary
                                    : AppTheme.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
        bottomNavigationBar: SafeArea(
          child: CurvedBottomNavBarAdmin(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == _currentIndex) return;
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/foods');
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, '/users');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/transactions');
              } else if (index == 3) {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
          ),
        ),
      ),
    );
  }
}