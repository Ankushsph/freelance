import '../models/social_profile.dart';

class SocialProfileMapper {
  static SocialProfile instagram(Map<String, dynamic> data) {
    final String username =
    data['username'] != null ? '@${data['username']}' : '';

    return SocialProfile(
      name: data['name'] ?? '',
      username: username,
      bio: data['biography'] ?? '',
      profileImage: data['profile_picture_url'] ?? '',
      location: 'Instagram',
      stats: {
        'Posts': (data['media_count'] ?? 0).toString(),
        'Followers': (data['followers_count'] ?? 0).toString(),
        'Following': (data['follows_count'] ?? 0).toString(),
      },
      connected: true,
    );
  }

  static SocialProfile facebook(Map<String, dynamic> data) {
    return SocialProfile(
      name: data['name'] ?? '',
      username: data['username'] != null
          ? '@${data['username']}'
          : '',
      bio: data['bio'] ?? '',
      profileImage: data['picture']?['data']?['url'] ?? '',
      location: 'Facebook',
      stats: {
        'Friends': (data['friends_count'] ?? 0).toString(),
        'Posts': (data['posts_count'] ?? 0).toString(),
        'Likes': (data['likes_count'] ?? 0).toString(),
      },
      connected: true,
    );
  }
}