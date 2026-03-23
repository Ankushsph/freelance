
import '../models/social_profile.dart';
import 'api_service.dart';
import 'auth_storage.dart';
import 'social_profile_mapper.dart';

class MockSocialService {


  static Future<SocialProfile?> instagram() async {

    final stored = await AuthStorage.getStoredInstagramProfile();
    if (stored != null) {

      return SocialProfileMapper.instagram(stored);
    }


    final token = await AuthStorage.getToken();
    if (token == null) return null;

    try {
      final data = await ApiService.getInstagramProfile();
      await AuthStorage.saveInstagramProfile(data);
      return SocialProfileMapper.instagram(data);
    } catch (_) {
      return null;
    }
  }


  static SocialProfile twitter() => SocialProfile(
    name: "Jit",
    username: "@codesbyjit",
    bio: "Developer • Hackathons • Startups",
    profileImage: "assets/images/mock/img.png",
    location: "India",
    stats: {
      "Followers": "860",
      "Following": "120",
    },
    connected: true,
  );


  static SocialProfile linkedin() => SocialProfile(
    name: "Jit",
    username: "Full Stack Dev",
    bio: "B.Tech • Founder @CodesbyJit",
    profileImage: "assets/images/mock/img.png",
    location: "Kolkata",
    stats: {"Connections": "500+"},
    connected: true,
  );


  static Future<SocialProfile?> facebook() async {


    final stored = await AuthStorage.getStoredFacebookProfile();
    if (stored != null) {
      return SocialProfileMapper.facebook(stored);
    }


    final token = await AuthStorage.getToken();
    if (token == null) return null;

    try {
      final data = await ApiService.getFacebookProfile();
      await AuthStorage.saveFacebookProfile(data);
      return SocialProfileMapper.facebook(data);
    } catch (_) {
      return null;
    }
  }

}