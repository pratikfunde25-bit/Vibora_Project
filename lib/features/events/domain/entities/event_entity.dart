import 'package:equatable/equatable.dart';

enum EventCategory {
  hackathon, workshop, conference, cultural,
  sports, techTalk, corporate, networking, webinar, other,
}

enum EventStatus { upcoming, ongoing, completed, cancelled }

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String? organizerAvatar;
  final EventCategory category;
  final EventStatus status;
  final bool isFeatured;
  final String? bannerUrl;
  final List<String> imageUrls;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int maxAttendees;
  final int registeredCount;
  final double price;
  final bool isFree;
  final bool isTeamEvent;
  final int? maxTeamSize;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isRegistered;
  final bool isSaved;
  final Map<String, dynamic>? customFields;
  final DateTime createdAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    this.organizerAvatar,
    required this.category,
    this.status = EventStatus.upcoming,
    this.isFeatured = false,
    this.bannerUrl,
    this.imageUrls = const [],
    required this.startDate,
    required this.endDate,
    required this.venue,
    this.address,
    this.latitude,
    this.longitude,
    required this.maxAttendees,
    this.registeredCount = 0,
    this.price = 0,
    this.isFree = true,
    this.isTeamEvent = false,
    this.maxTeamSize,
    this.tags = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.isRegistered = false,
    this.isSaved = false,
    this.customFields,
    required this.createdAt,
  });

  bool get isFull => registeredCount >= maxAttendees;
  int get spotsLeft => maxAttendees - registeredCount;
  double get fillPercentage => registeredCount / maxAttendees;

  EventEntity copyWith({
    EventStatus? status,
    int? registeredCount,
    double? rating,
    int? reviewCount,
    bool? isRegistered,
    bool? isSaved,
    String? bannerUrl,
    bool? isFeatured,
    DateTime? createdAt,
  }) =>
      EventEntity(
        id: id,
        title: title,
        description: description,
        organizerId: organizerId,
        organizerName: organizerName,
        organizerAvatar: organizerAvatar,
        category: category,
        status: status ?? this.status,
        isFeatured: isFeatured ?? this.isFeatured,
        bannerUrl: bannerUrl ?? this.bannerUrl,
        imageUrls: imageUrls,
        startDate: startDate,
        endDate: endDate,
        venue: venue,
        address: address,
        latitude: latitude,
        longitude: longitude,
        maxAttendees: maxAttendees,
        registeredCount: registeredCount ?? this.registeredCount,
        price: price,
        isFree: isFree,
        isTeamEvent: isTeamEvent,
        maxTeamSize: maxTeamSize,
        tags: tags,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        isRegistered: isRegistered ?? this.isRegistered,
        isSaved: isSaved ?? this.isSaved,
        customFields: customFields,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, title, organizerId, startDate, status, isFeatured];
}
