# Vibora - Premium Event Ecosystem 🐍✨

Vibora is a high-performance, visually stunning event discovery and community platform built with Flutter and Firebase. It follows a "Deep Noir" design philosophy, prioritizing sleek aesthetics, fluid animations, and robust real-time functionality.

## 🛠️ Technology Stack

### Core Frameworks
- **Flutter**: Cross-platform UI toolkit for high-fps animations.
- **Dart**: Strong-typed language for reliable business logic.
- **Firebase**: Backend-as-a-Service (BaaS) providing:
    - **Firestore**: Real-time NoSQL database.
    - **Authentication**: Secure email, Google, and Phone OTP login.
    - **Cloud Storage**: Secure media hosting.

### State & Navigation
- **Riverpod (2.x)**: Modern, compile-safe state management using `AsyncNotifier`.
- **GoRouter**: Declarative routing with custom transition animations and "Sticky Session" logic.

### UI & Animations
- **Flutter Animate**: Declarative micro-animations for buttons, cards, and transitions.
- **CachedNetworkImage**: Intelligent image caching and placeholder management.
- **Google Fonts**: Custom typography using 'Inter' and 'Outfit' for a premium feel.

### Advanced Services
- **Razorpay**: Integrated payment gateway for event ticketing.
- **Notification Service**: Local scheduled notifications with timezone support.
- **Local Auth**: Biometric security (Fingerprint/FaceID) integration.

---

## 🚀 Key Features

### 1. Global Rebranding (Vibora)
The app has been transformed from "EventConnect" to **Vibora**, featuring a custom dark-mode design system, updated app labels, and a high-end splash screen experience.

### 2. Community & Real-time Chat
Every event features a **Community Hub**, allowing attendees to chat in real-time. Supports:
- Public community discussions.
- Private 1-to-1 messaging between users.
- Real-time Firestore stream integration for zero-latency messaging.

### 3. Smart Notification Engine
Intelligent reminder system that automatically schedules alerts:
- **30 Minutes Before**: To get the user ready.
- **10 Minutes Before**: For final arrival/start confirmation.

### 4. Premium Visual Gallery
A curated visual system that replaces random placeholders with high-resolution Unsplash imagery.
- **Multi-Image Support**: 4-5 unique images per category (Hackathon, Workshop, etc.).
- **Dynamic Selection**: Images are selected based on the event's unique ID, ensuring no two events in the feed look the same.

### 5. Sticky Session Routing
Custom implementation in `AppRouter` that prevents "Splash Screen Jitter." The router maintains the user's logged-in state during background data syncs, providing a seamless "Pro" level navigation experience.

---

## 🏗️ Architecture & Class Structure

### Presentation Layer (UI)
- **`ViboraApp`**: Root widget managing theme and router configuration.
- **`DiscoverScreen`**: The main hub featuring categories, featured carousels, and search.
- **`EventDetailScreen`**: Deep-dive view for events with integrated chat and payment.
- **`FeaturedEventCard`**: High-impact horizontal component for trending events.
- **`EventListCard`**: Optimized list component for discovery feeds.

### Controller Layer (State)
- **`AuthController`**: Manages user session, profile updates, and authentication flow.
- **`EventController`**: Handles event creation, image uploads, and bookmarking logic.
- **`ChatController`**: Manages real-time message streams and room creation.

### Data Layer
- **`AuthRepositoryImpl`**: Bridge between Firebase Auth/Firestore and the app.
- **`EventsRepositoryImpl`**: Handles all CRUD operations for events and saving/bookmarking.
- **`NotificationService`**: Centralized logic for local notification scheduling.

---

## 🎨 Design Tokens
- **Primary Color**: `#6C5CE7` (Vibrant Purple)
- **Accent Color**: `#FF7675` (Soft Coral)
- **Background**: Deep Dark/Noir Gradient
- **Border Radius**: 18px - 24px (Modern Rounded)

---
*Vibora - Developed as a Pro-Level All-Rounder coding assistant project.* 🐍🚀✨
