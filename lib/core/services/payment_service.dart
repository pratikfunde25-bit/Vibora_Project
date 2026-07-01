import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../features/events/domain/entities/event_entity.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref);
});

class PaymentService {
  final Ref _ref;
  late Razorpay _razorpay;
  
  // Real Test Key ID from Razorpay Dashboard
  static const String _razorpayKey = "rzp_test_ShYWtLR1VKyVQA";

  PaymentService(this._ref) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  // Temporary storage for processing
  EventEntity? _processingEvent;
  BuildContext? _context;

  Future<void> startPayment({
    required BuildContext context,
    required EventEntity event,
  }) async {
    _processingEvent = event;
    _context = context;

    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    var options = {
      'key': _razorpayKey,
      'amount': (event.price * 100).toInt(), // Amount in paise
      'name': 'Vibora',
      'description': 'Registration for ${event.title}',
      'timeout': 300, // 5 minutes
      'prefill': {
        'contact': user.phone ?? '9999999999',
        'email': user.email,
        'name': user.name,
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': false,
      },
      'theme': {
        'color': '#6366F1' // Matches your AppColors.primary
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_processingEvent == null || _context == null) return;

    final userId = _ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    // Trigger Firestore Registration after successful payment
    final result = await _ref.read(eventsRepositoryProvider)
        .registerForEvent(_processingEvent!.id, userId);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(content: Text('Payment Success, but registration failed: ${failure.message}')),
        );
      },
      (_) {
        showDialog(
          context: _context!,
          builder: (context) => AlertDialog(
            title: const Text('Payment Successful!'),
            content: Text('You are now registered for ${_processingEvent!.title}. Check your tickets!'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_context == null) return;
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Optional: Handle external wallets like PhonePe/GPay if needed
  }
}
