import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan Entry Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!_isScanning) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // Corner accents
                  _buildCorner(0, 0, 0, 0),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Align QR code within frame',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(double t, double l, double r, double b) {
    return Container(); // Simplified for now
  }

  void _handleScan(String data) {
    setState(() => _isScanning = false);
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);
      _showSuccessSheet(decoded);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR Code Format')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isScanning = true);
      });
    }
  }

  void _showSuccessSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 80),
            const SizedBox(height: 24),
            const Text(
              'VERIFIED ENTRY',
              style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
            ),
            const SizedBox(height: 32),
            _infoRow('TICKET HOLDER', data['userName'] ?? 'Unknown'),
            const Divider(color: Colors.white10, height: 32),
            _infoRow('EVENT NAME', data['eventName'] ?? 'Unknown'),
            const Divider(color: Colors.white10, height: 32),
            _infoRow('TICKET ID', data['ticketId'] ?? 'Unknown'),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isScanning = true);
              },
              child: const Text('SCAN NEXT', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => setState(() => _isScanning = true));
  }

  Widget _infoRow(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      ],
    );
  }
}
