import 'package:flutter/material.dart';
import 'package:meducyte_app/core/constants/avatar_assets.dart';

class NotionAvatarRenderer extends StatelessWidget {
  final String avatarKey;
  final double size;

  const NotionAvatarRenderer({
    super.key,
    required this.avatarKey,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    //Look up the asset path
    final assetPath =
        AvatarAssets.readyAvatars[avatarKey] ??
        AvatarAssets.readyAvatars['avatar_1']!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          0.04,
        ), //Subtle background for consistency
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.person, size: size * 0.6, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}
