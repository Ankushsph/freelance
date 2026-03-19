import 'social_profile.dart';

class SocialAccount {
  final String name;
  final String logo;
  final SocialProfile profile;

  bool get connected => profile.connected;

  SocialAccount({
    required this.name,
    required this.logo,
    required this.profile,
  });
}