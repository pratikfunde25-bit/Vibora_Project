import 'package:equatable/equatable.dart';

/// Domain entity — zero external dependencies.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final List<String> interests;
  final List<String> skills;
  final String? college;
  final String? company;
  final bool isProfilePublic;
  final bool isVerified;
  final int points; // gamification
  final List<String> badges;
  final List<String> savedEvents;
  final List<String> registeredEvents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.interests = const [],
    this.skills = const [],
    this.college,
    this.company,
    this.isProfilePublic = true,
    this.isVerified = false,
    this.points = 0,
    this.badges = const [],
    this.savedEvents = const [],
    this.registeredEvents = const [],
    required this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    List<String>? interests,
    List<String>? skills,
    String? college,
    String? company,
    bool? isProfilePublic,
    int? points,
    List<String>? badges,
    List<String>? savedEvents,
    List<String>? registeredEvents,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      college: college ?? this.college,
      company: company ?? this.company,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      isVerified: isVerified,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      savedEvents: savedEvents ?? this.savedEvents,
      registeredEvents: registeredEvents ?? this.registeredEvents,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, email, phone, avatarUrl, bio,
    interests, skills, college, company,
    isProfilePublic, isVerified, points, badges, savedEvents, registeredEvents,
    createdAt, updatedAt,
  ];
}
