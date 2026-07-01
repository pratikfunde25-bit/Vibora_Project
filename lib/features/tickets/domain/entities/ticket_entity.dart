import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final String id;
  final String eventId;
  final String eventTitle;
  final String? eventBannerUrl;
  final String userId;
  final String userName;
  final String? userEmail;
  final String qrCode;
  final String ticketNumber;
  final DateTime purchasedAt;
  final DateTime eventDate;
  final String venue;
  final double amountPaid;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String? teamName;
  final List<String>? teamMembers;
  final bool isValid;

  const TicketEntity({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.eventBannerUrl,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.qrCode,
    required this.ticketNumber,
    required this.purchasedAt,
    required this.eventDate,
    required this.venue,
    required this.amountPaid,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.teamName,
    this.teamMembers,
    this.isValid = true,
  });

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get isPast => eventDate.isBefore(DateTime.now());

  @override
  List<Object?> get props => [id, qrCode, ticketNumber];
}
