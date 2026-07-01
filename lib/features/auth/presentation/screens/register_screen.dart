import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept terms & conditions')),
      );
      return;
    }
    setState(() => _loading = true);
    final error = await ref
        .read(authControllerProvider.notifier)
        .signUpWithEmail(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
      ));
    } else {
      context.go(AppRoutes.interests);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Create Account 🚀',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1))
                    .animate()
                    .fadeIn()
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 6),
                Text('Join thousands of event enthusiasts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.5)))
                    .animate()
                    .fadeIn(delay: 80.ms),
                const SizedBox(height: 32),

                _label('Full Name'),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'John Doe',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                _label('Email Address'),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                      return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                _label('Password'),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Minimum 8 characters',
                  controller: _passCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                _label('Confirm Password'),
                const SizedBox(height: 10),
                AppTextField(
                  hint: 'Re-enter password',
                  controller: _confirmCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),

                // Terms
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Create Account',
                  isLoading: _loading,
                  onPressed: _register,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        )),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text('Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTypography.labelLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      );
}
