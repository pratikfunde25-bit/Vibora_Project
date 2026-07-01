import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.organizerId,
    required super.organizerName,
    super.organizerAvatar,
    required super.category,
    super.status,
    super.isFeatured,
    super.bannerUrl,
    super.imageUrls,
    required super.startDate,
    required super.endDate,
    required super.venue,
    super.address,
    super.latitude,
    super.longitude,
    required super.maxAttendees,
    super.registeredCount,
    super.price,
    super.isFree,
    super.isTeamEvent,
    super.maxTeamSize,
    super.tags,
    super.rating,
    super.reviewCount,
    super.isRegistered,
    super.isSaved,
    super.customFields,
    required super.createdAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      organizerId: d['organizerId'] ?? '',
      organizerName: d['organizerName'] ?? '',
      organizerAvatar: d['organizerAvatar'],
      category: _parseCategory(d['category']),
      status: _parseStatus(d['status']),
      isFeatured: d['isFeatured'] ?? false,
      bannerUrl: d['bannerUrl'],
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      startDate: (d['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (d['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: d['venue'] ?? '',
      address: d['address'],
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      maxAttendees: d['maxAttendees'] ?? 100,
      registeredCount: d['registeredCount'] ?? 0,
      price: (d['price'] as num?)?.toDouble() ?? 0,
      isFree: d['isFree'] ?? true,
      isTeamEvent: d['isTeamEvent'] ?? false,
      maxTeamSize: d['maxTeamSize'],
      tags: List<String>.from(d['tags'] ?? []),
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: d['reviewCount'] ?? 0,
      customFields: d['customFields'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory EventModel.fromEntity(EventEntity e) => EventModel(
        id: e.id,
        title: e.title,
        description: e.description,
        organizerId: e.organizerId,
        organizerName: e.organizerName,
        organizerAvatar: e.organizerAvatar,
        category: e.category,
        status: e.status,
        isFeatured: e.isFeatured,
        bannerUrl: e.bannerUrl,
        imageUrls: e.imageUrls,
        startDate: e.startDate,
        endDate: e.endDate,
        venue: e.venue,
        address: e.address,
        latitude: e.latitude,
        longitude: e.longitude,
        maxAttendees: e.maxAttendees,
        registeredCount: e.registeredCount,
        price: e.price,
        isFree: e.isFree,
        isTeamEvent: e.isTeamEvent,
        maxTeamSize: e.maxTeamSize,
        tags: e.tags,
        rating: e.rating,
        reviewCount: e.reviewCount,
        customFields: e.customFields,
        createdAt: e.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'titleLowercase': title.toLowerCase(),
        'description': description,
        'organizerId': organizerId,
        'organizerName': organizerName,
        'organizerAvatar': organizerAvatar,
        'category': category.name,
        'status': status.name,
        'isFeatured': isFeatured,
        'bannerUrl': bannerUrl,
        'imageUrls': imageUrls,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'venue': venue,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'maxAttendees': maxAttendees,
        'registeredCount': registeredCount,
        'price': price,
        'isFree': isFree,
        'isTeamEvent': isTeamEvent,
        'maxTeamSize': maxTeamSize,
        'tags': tags,
        'rating': rating,
        'reviewCount': reviewCount,
        'customFields': customFields,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  static EventCategory _parseCategory(String? v) {
    return EventCategory.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EventCategory.other,
    );
  }

  static EventStatus _parseStatus(String? v) {
    return EventStatus.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EventStatus.upcoming,
    );
  }
}
