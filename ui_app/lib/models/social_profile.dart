class SocialProfile {
  final String name;
  final String username;
  final String bio;
  final String profileImage;
  final String location;
  final Map<String, String> stats;
  final bool connected;

  SocialProfile({
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImage,
    required this.location,
    required this.stats,
    this.connected = false,
  });
}