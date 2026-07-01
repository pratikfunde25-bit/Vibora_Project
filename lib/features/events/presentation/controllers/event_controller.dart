import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/event_entity.dart';
import '../../data/repositories/events_repository_impl.dart';

final eventControllerProvider = StateNotifierProvider<EventController, AsyncValue<void>>((ref) {
  return EventController(ref);
});

class EventController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  EventController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> createEvent(EventEntity event, File? imageFile) async {
    state = const AsyncValue.loading();
    String? bannerUrl;

    if (imageFile != null) {
      final uploadResult = await ref.read(eventsRepositoryProvider).uploadEventImage(imageFile);
      uploadResult.fold(
        (failure) {
          debugPrint('Image upload failed, using fallback: ${failure.message}');
          // Don't fail the whole process, just log it and proceed with null banner (card fallbacks will handle it)
        },
        (url) => bannerUrl = url,
      );
    }

    final updatedEvent = event.copyWith(
      bannerUrl: bannerUrl,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(eventsRepositoryProvider).createEvent(updatedEvent);
    
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (eventId) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<void> toggleSaveEvent(String eventId, String userId) async {
    final result = await ref.read(eventsRepositoryProvider).saveEvent(eventId, userId);
    if (result.isLeft()) {
      state = AsyncValue.error('Failed to save event', StackTrace.current);
    }
  }
}
