import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final auth = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
          data: (user) {
            if (user == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_moon_rounded, size: 56, color: AppColors.neonCyan),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await auth.signInWithGoogle();
                        } catch (e) {
                          _showError(context, e);
                        }
                      },
                      icon: const Icon(Icons.g_mobiledata_rounded),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await auth.signInWithApple();
                        } catch (e) {
                          _showError(context, e);
                        }
                      },
                      icon: const Icon(Icons.apple_rounded),
                      label: const Text('Continue with Apple'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showEmailSheet(context, ref),
                      icon: const Icon(Icons.email_rounded),
                      label: const Text('Continue with Email'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.surfaceElevated,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? const Icon(Icons.person, size: 36) : null,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(user.displayName ?? user.email ?? 'CyberMind User',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded, color: AppColors.neonViolet),
                    title: const Text('Go Premium'),
                    subtitle: const Text('Unlimited scans, faster analysis, deep reports'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/premium'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: const Text('Scan History'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                    title: const Text('Sign Out'),
                    onTap: () => auth.signOut(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }

  void _showEmailSheet(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authRepositoryProvider).registerWithEmail(emailCtrl.text, passCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        _showError(ctx, e);
                      }
                    },
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authRepositoryProvider).signInWithEmail(emailCtrl.text, passCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        _showError(ctx, e);
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
