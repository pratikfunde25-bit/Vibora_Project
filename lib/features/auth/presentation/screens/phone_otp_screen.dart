import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/auth_controller.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const PhoneOtpScreen({super.key, required this.phoneNumber});
  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  bool _otpSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber.isNotEmpty) {
      _phoneCtrl.text = widget.phoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    setState(() => _loading = true);
    final result = await ref.read(authControllerProvider.notifier)
        .sendOtp('+91${_phoneCtrl.text.trim()}');
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!), backgroundColor: AppColors.error),
      );
    } else {
      setState(() { _otpSent = true; _verificationId = result.verificationId; });
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP')),
      );
      return;
    }
    setState(() => _loading = true);
    final error = await ref.read(authControllerProvider.notifier)
        .verifyOtp(verificationId: _verificationId!, otp: otp);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      context.go(AppRoutes.home);
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
        title: const Text('Phone Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.phone_android_rounded, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                _otpSent ? 'Enter OTP' : 'Phone Verification',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'We sent a 6-digit code to +91 ${_phoneCtrl.text}'
                    : 'Enter your phone number to receive an OTP',
                style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5, fontSize: 15),
              ),
              const SizedBox(height: 40),
              if (!_otpSent) ...[
                Text('Phone Number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Text('+91', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        hint: '10-digit number',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                AppPrimaryButton(label: 'Send OTP', isLoading: _loading, onPressed: _sendOtp),
              ] else ...[
                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _OtpBox(
                    controller: _otpCtrls[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                    },
                  )),
                ),
                const SizedBox(height: 40),
                AppPrimaryButton(label: 'Verify OTP', isLoading: _loading, onPressed: _verifyOtp),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () { setState(() => _otpSent = false); for (final c in _otpCtrls) c.clear(); },
                    icon: Icon(Icons.refresh_rounded, size: 18, color: Colors.white.withOpacity(0.7)),
                    label: Text('Resend OTP', style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.white.withOpacity(0.05),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}
