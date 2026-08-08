/// Dummy portrait URLs for demo profile images.
abstract class AvatarUrls {
  AvatarUrls._();

  static const agent =
      'https://randomuser.me/api/portraits/men/22.jpg';

  static const Map<String, String> applicants = {
    'app-001': 'https://randomuser.me/api/portraits/men/32.jpg',
    'app-002': 'https://randomuser.me/api/portraits/women/44.jpg',
    'app-003': 'https://randomuser.me/api/portraits/women/65.jpg',
    'app-004': 'https://randomuser.me/api/portraits/men/15.jpg',
    'app-005': 'https://randomuser.me/api/portraits/women/28.jpg',
    'app-006': 'https://randomuser.me/api/portraits/men/52.jpg',
    'app-007': 'https://randomuser.me/api/portraits/women/17.jpg',
    'app-008': 'https://randomuser.me/api/portraits/men/32.jpg',
    'app-009': 'https://randomuser.me/api/portraits/men/73.jpg',
    'app-010': 'https://randomuser.me/api/portraits/women/81.jpg',
  };

  static String forApplicant(String id) =>
      applicants[id] ?? 'https://randomuser.me/api/portraits/men/12.jpg';
}
