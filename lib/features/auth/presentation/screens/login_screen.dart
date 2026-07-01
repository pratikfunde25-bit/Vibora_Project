import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    
    final error = await ref.read(authControllerProvider.notifier)
        .signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    
    if (!mounted) return;
    setState(() => _loading = false);
    
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // High-end Deep Noir
      body: Stack(
        children: [
          // Premium Background elements
          Positioned(top: -50, right: -50, child: _CircularBlob(color: AppColors.primary.withOpacity(0.15), size: 280)),
          Positioned(bottom: -100, left: -50, child: _CircularBlob(color: AppColors.accent.withOpacity(0.1), size: 350)),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    _LogoWidget().animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 40),
                    Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                    const SizedBox(height: 8),
                    Text('Enter your credentials to continue', style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.5))),
                    const SizedBox(height: 48),
                    
                    // Error Message Area
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_errorMessage!, style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ).animate().shake(duration: 400.ms).fadeIn(),

                    AppTextField(
                      hint: 'Email',
                      label: 'Email',
                      controller: _emailCtrl,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      hint: 'Password',
                      label: 'Password',
                      controller: _passCtrl,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: Text('Forgot Password?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppPrimaryButton(
                      label: 'Login',
                      isLoading: _loading,
                      onPressed: _signIn,
                    ),
                    const SizedBox(height: 24),
                    
                    // Social & Phone Login
                    Center(child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2))),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            onPressed: () async {
                              setState(() => _loading = true);
                              final error = await ref.read(authControllerProvider.notifier).signInWithGoogle();
                              if (mounted) setState(() => _loading = false);
                              if (error != null) setState(() => _errorMessage = error);
                              else context.go(AppRoutes.home);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.phone_android_rounded,
                            label: 'Phone',
                            onPressed: () => context.push(AppRoutes.phoneOtp),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.6))),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _SocialButton({required this.icon, required this.label, required this.onPressed});
  
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    ),
  );
}

class _CircularBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _CircularBlob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
    child: const Icon(Icons.bolt_rounded, size: 36, color: Colors.white),
  );
}
