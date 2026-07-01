import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';
import '../../../events/domain/entities/event_entity.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Extract eventId from ticketId (assuming ticketId is eventId_userId)
    final eventId = ticketId.split('_')[0];
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Entry Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: eventAsync.when(
        data: (event) => _buildTicketBody(context, event, user),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildTicketBody(BuildContext context, EventEntity event, user) {
    // Prepare JSON data for the QR code
    final qrData = jsonEncode({
      'userName': user?.name ?? 'Guest',
      'eventName': event.title,
      'ticketId': ticketId,
      'date': DateFormat('dd MMM yyyy').format(event.startDate),
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // The Digital Ticket
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                // Top Part: Event Info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        event.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(50)),
                            child: Text(event.category.name.toUpperCase(), style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dashed Line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(30, (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index % 2 == 0 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    )),
                  ),
                ),

                // Middle Part: QR Code
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      // STUNNING GRADIENT QR CODE
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFFA855F7), Color(0xFFEC4899)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.transparent,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.white),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SCAN FOR ENTRY',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3),
                      ),
                    ],
                  ),
                ),

                // Dashed Line
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(30, (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index % 2 == 0 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    )),
                  ),
                ),

                // Bottom Part: Details
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TicketInfo(label: 'DATE', value: DateFormat('dd MMM').format(event.startDate)),
                      _TicketInfo(label: 'TIME', value: DateFormat('jm').format(event.startDate)),
                      _TicketInfo(label: 'VENUE', value: event.venue, isExpanded: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // User Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person_rounded, color: Colors.white54)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TICKET HOLDER', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800)),
                  Text(user?.name ?? 'Guest User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool isExpanded;
  const _TicketInfo({required this.label, required this.value, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
    return isExpanded ? Expanded(child: Padding(padding: const EdgeInsets.only(left: 16), child: content)) : content;
  }
}
