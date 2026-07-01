/// Global application constants.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Vibora';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Discover. Connect. Experience.';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String ticketsCollection = 'tickets';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String notificationsCollection = 'notifications';
  static const String reviewsCollection = 'reviews';
  static const String registrationsCollection = 'registrations';
  static const String categoriesCollection = 'categories';

  // Storage Paths
  static const String userAvatarsPath = 'avatars';
  static const String eventImagesPath = 'events';
  static const String eventBannersPath = 'banners';
  static const String certificatesPath = 'certificates';

  // Shared Pref Keys
  static const String prefOnboardingSeen = 'onboarding_seen';
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserId = 'user_id';
  static const String prefFcmToken = 'fcm_token';

  // Pagination
  static const int pageSize = 20;
  static const int chatPageSize = 30;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration xSlow = Duration(milliseconds: 900);

  // Event Categories
  static const List<String> eventCategories = [
    'All',
    'Hackathon',
    'Workshop',
    'Conference',
    'Cultural',
    'Sports',
    'Tech Talk',
    'Corporate',
    'Networking',
    'Webinar',
  ];

  // Premium Category Image Gallery
  static const Map<String, List<String>> categoryImages = {
    'hackathon': [
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&w=1000',
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=1000',
      'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000',
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1000',
    ],
    'workshop': [
      'https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=1000',
      'https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&w=1000',
      'https://images.unsplash.com/photo-1515187029135-18ee286d815b?q=80&w=1000',
      'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?q=80&w=1000',
    ],
    'conference': [
      'https://images.unsplash.com/photo-1540575861501-7ad060e39fe5?q=80&w=1000',
      'https://images.unsplash.com/photo-1475721027187-4024733923f7?q=80&w=1000',
      'https://images.unsplash.com/photo-1505373630103-f21ee4c6ad18?q=80&w=1000',
      'https://images.unsplash.com/photo-1558403194-611308249627?q=80&w=1000',
    ],
    'cultural': [
      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1000',
      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=1000',
      'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=1000',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=1000',
    ],
    'sports': [
      'https://images.unsplash.com/photo-1461896756985-2346a8b16f9b?q=80&w=1000',
      'https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=1000',
      'https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=1000',
      'https://images.unsplash.com/photo-1471295253337-3ceaaedca402?q=80&w=1000',
    ],
    'techtalk': [
      'https://images.unsplash.com/photo-1517048676732-d65bc937f952?q=80&w=1000',
      'https://images.unsplash.com/photo-1551818255-e6e10975bc17?q=80&w=1000',
      'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?q=80&w=1000',
      'https://images.unsplash.com/photo-1558403194-611308249627?q=80&w=1000',
    ],
    'corporate': [
      'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1000',
      'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000',
      'https://images.unsplash.com/photo-1497215728101-856f4ea42174?q=80&w=1000',
      'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?q=80&w=1000',
    ],
    'networking': [
      'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=1000',
      'https://images.unsplash.com/photo-1515169067868-5387ec356754?q=80&w=1000',
      'https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=1000',
      'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=1000',
    ],
    'webinar': [
      'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b?q=80&w=1000',
      'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?q=80&w=1000',
      'https://images.unsplash.com/photo-1610484826967-09c5720778c7?q=80&w=1000',
      'https://images.unsplash.com/photo-1524178232363-1fb280c29161?q=80&w=1000',
    ],
    'other': [
      'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000',
      'https://images.unsplash.com/photo-1472653423587-59a316b820aa?q=80&w=1000',
      'https://images.unsplash.com/photo-1531058020387-3be344556be6?q=80&w=1000',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1000',
    ],
  };

  // Interest Tags
  static const List<String> interestTags = [
    'AI/ML',
    'Web Dev',
    'Mobile Dev',
    'DevOps',
    'Blockchain',
    'Cybersecurity',
    'Data Science',
    'UI/UX',
    'IoT',
    'Cloud',
    'Gaming',
    'Entrepreneurship',
    'Finance',
    'Healthcare',
    'Education',
    'Music',
    'Art',
    'Sports',
  ];
}
