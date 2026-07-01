import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier)
        .sendPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() { _loading = false; if (error == null) _sent = true; });
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _sent ? _SuccessView(email: _emailCtrl.text) : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 28),
                Text('Forgot Password?',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  "Enter your registered email. We'll send you a link to reset your password.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  hint: 'Email address',
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                      return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                AppPrimaryButton(
                  label: 'Send Reset Link',
                  isLoading: _loading,
                  icon: Icons.send_rounded,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded, size: 56, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          Text('Email Sent!',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            'We\'ve sent a password reset link to\n$email',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            label: 'Back to Sign In',
            width: 200,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
