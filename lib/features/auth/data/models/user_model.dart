import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatarUrl,
    super.bio,
    super.interests,
    super.skills,
    super.college,
    super.company,
    super.isProfilePublic,
    super.isVerified,
    super.points,
    super.badges,
    super.savedEvents,
    super.registeredEvents,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      interests: entity.interests,
      skills: entity.skills,
      college: entity.college,
      company: entity.company,
      isProfilePublic: entity.isProfilePublic,
      isVerified: entity.isVerified,
      points: entity.points,
      badges: entity.badges,
      savedEvents: entity.savedEvents,
      registeredEvents: entity.registeredEvents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'],
      avatarUrl: d['avatarUrl'],
      bio: d['bio'],
      interests: List<String>.from(d['interests'] ?? []),
      skills: List<String>.from(d['skills'] ?? []),
      college: d['college'],
      company: d['company'],
      isProfilePublic: d['isProfilePublic'] ?? true,
      isVerified: d['isVerified'] ?? false,
      points: d['points'] ?? 0,
      badges: List<String>.from(d['badges'] ?? []),
      savedEvents: List<String>.from(d['savedEvents'] ?? []),
      registeredEvents: List<String>.from(d['registeredEvents'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      avatarUrl: map['avatarUrl'],
      bio: map['bio'],
      interests: List<String>.from(map['interests'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      college: map['college'],
      company: map['company'],
      isProfilePublic: map['isProfilePublic'] ?? true,
      isVerified: map['isVerified'] ?? false,
      points: map['points'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      savedEvents: List<String>.from(map['savedEvents'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'interests': interests,
        'skills': skills,
        'college': college,
        'company': company,
        'isProfilePublic': isProfilePublic,
        'isVerified': isVerified,
        'points': points,
        'badges': badges,
        'savedEvents': savedEvents,
        'registeredEvents': registeredEvents,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt':
            updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };
}
