import 'package:flutter/material.dart';
import '../models/social_profile.dart';

class ProfileHeader extends StatelessWidget {
  final SocialProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundImage: AssetImage(profile.profileImage),
        ),
        const SizedBox(height: 12),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (profile.bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
      ],
    );
  }
}