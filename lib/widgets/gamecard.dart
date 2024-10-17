import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/ constants.dart';

class GameCard extends StatelessWidget {
  final dynamic game;
  final VoidCallback onTap;

  const GameCard({Key? key, required this.game, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = game['background_image'] ??
        'https://via.placeholder.com/300x200.png?text=No+Image';
    final gameName = game['name'] ?? 'Unknown Game';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: SURFACE_COLOR),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            SizedBox(height: 8),
            Text(
              gameName,
              style: TextStyle(color: TEXT_COLOR, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
