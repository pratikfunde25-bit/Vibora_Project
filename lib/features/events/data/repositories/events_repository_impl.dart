import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/event_entity.dart';
import '../models/event_model.dart';

// ─── Provider ─────────────────────────────────────────────
final eventsRepositoryProvider = Provider<EventsRepository>(
  (_) => EventsRepositoryImpl(FirebaseFirestore.instance),
);

// ─── Events List Provider (Real-time) ─────────────────────
final eventsProvider = StreamProvider.family<List<EventEntity>, String?>(
  (ref, category) {
    final repo = ref.read(eventsRepositoryProvider);
    return repo.watchEvents(category: category);
  },
);

// ─── Featured Events Provider (Real-time) ─────────────────
final featuredEventsProvider = StreamProvider<List<EventEntity>>((ref) {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.watchFeaturedEvents();
});

// ─── Repository Interface ─────────────────────────────────
abstract interface class EventsRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents({String? category});
  Stream<List<EventEntity>> watchEvents({String? category});
  Stream<List<EventEntity>> watchFeaturedEvents();
  Future<Either<Failure, List<EventEntity>>> getFeaturedEvents();
  Future<Either<Failure, EventEntity>> getEventById(String id);
  Future<Either<Failure, List<EventEntity>>> searchEvents(String query);
  Future<Either<Failure, String>> createEvent(EventEntity event);
  Future<Either<Failure, String>> uploadEventImage(File image);
  Future<Either<Failure, void>> registerForEvent(String eventId, String userId);
  Future<Either<Failure, void>> saveEvent(String eventId, String userId);
}

// ─── Repository Implementation ────────────────────────────
class EventsRepositoryImpl implements EventsRepository {
  final FirebaseFirestore _db;
  EventsRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents({String? category}) async {
    try {
      Query query = _db
          .collection(AppConstants.eventsCollection)
          .where('status', isEqualTo: 'upcoming')
          .orderBy('startDate')
          .limit(AppConstants.pageSize);
      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category.toLowerCase());
      }
      final snap = await query.get();
      final events = snap.docs.map((d) => EventModel.fromFirestore(d)).toList();
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<EventEntity>> watchEvents({String? category}) {
    Query query = _db
        .collection(AppConstants.eventsCollection)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('startDate');

    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category.toLowerCase());
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((d) => EventModel.fromFirestore(d)).toList();
    });
  }

  @override
  Stream<List<EventEntity>> watchFeaturedEvents() {
    // First try to get explicitly featured events
    return _db
        .collection(AppConstants.eventsCollection)
        .where('isFeatured', isEqualTo: true)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('startDate')
        .limit(5)
        .snapshots()
        .asyncMap((featuredSnap) async {
          if (featuredSnap.docs.isNotEmpty) {
            return featuredSnap.docs.map((d) => EventModel.fromFirestore(d)).toList();
          }
          
          // Fallback: If no featured events, show the latest upcoming events
          final fallbackSnap = await _db
              .collection(AppConstants.eventsCollection)
              .where('status', isEqualTo: 'upcoming')
              .orderBy('startDate')
              .limit(5)
              .get();
              
          return fallbackSnap.docs.map((d) => EventModel.fromFirestore(d)).toList();
        });
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getFeaturedEvents() async {
    try {
      final snap = await _db
          .collection(AppConstants.eventsCollection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('startDate')
          .limit(5)
          .get();
      return Right(snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById(String id) async {
    try {
      final snap = await _db.collection(AppConstants.eventsCollection).doc(id).get();
      if (!snap.exists) return Left(const NotFoundFailure());
      return Right(EventModel.fromFirestore(snap));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> searchEvents(String query) async {
    try {
      final snap = await _db
          .collection(AppConstants.eventsCollection)
          .orderBy('titleLowercase')
          .startAt([query.toLowerCase()])
          .endAt(['${query.toLowerCase()}\uf8ff'])
          .limit(20)
          .get();
      return Right(snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createEvent(EventEntity event) async {
    try {
      final model = EventModel.fromEntity(event);
      final ref = await _db.collection(AppConstants.eventsCollection).add(model.toMap());
      return Right(ref.id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerForEvent(String eventId, String userId) async {
    try {
      final eventDoc = await _db.collection(AppConstants.eventsCollection).doc(eventId).get();
      if (!eventDoc.exists) return Left(const NotFoundFailure());
      final event = EventModel.fromFirestore(eventDoc);

      final batch = _db.batch();
      final regRef = _db.collection(AppConstants.registrationsCollection).doc('${eventId}_$userId');
      
      // 1. Create registration doc
      batch.set(regRef, {
        'eventId': eventId,
        'userId': userId,
        'registeredAt': FieldValue.serverTimestamp(),
      });
      
      // 2. Increment attendee count
      batch.update(
        _db.collection(AppConstants.eventsCollection).doc(eventId),
        {'registeredCount': FieldValue.increment(1)},
      );
      
      // 3. Add to user's registered list
      batch.update(
        _db.collection(AppConstants.usersCollection).doc(userId),
        {'registeredEvents': FieldValue.arrayUnion([eventId])},
      );
      
      await batch.commit();

      // 4. Schedule Reminders
      await NotificationService().scheduleEventReminders(eventId, event.title, event.startDate);
      
      // 5. Show Immediate Success
      await NotificationService().showImmediate(
        id: eventId.hashCode,
        title: 'Registration Confirmed!',
        body: 'You have successfully registered for ${event.title}.',
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveEvent(String eventId, String userId) async {
    try {
      final doc = await _db.collection(AppConstants.usersCollection).doc(userId).get();
      final saved = List<String>.from(doc.data()?['savedEvents'] ?? []);
      
      if (saved.contains(eventId)) {
        await _db.collection(AppConstants.usersCollection).doc(userId).update({
          'savedEvents': FieldValue.arrayRemove([eventId]),
        });
      } else {
        await _db.collection(AppConstants.usersCollection).doc(userId).update({
          'savedEvents': FieldValue.arrayUnion([eventId]),
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, String>> uploadEventImage(File image) async {
    try {
      // Bypass Paid Storage: Save to Local App Directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final localPath = '${directory.path}/$fileName';
      
      final localFile = await image.copy(localPath);
      return Right('local://${localFile.path}');
    } catch (e) {
      return Left(ServerFailure('Local storage failed: ${e.toString()}'));
    }
  }
}
