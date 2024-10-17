// widgets/game_grid.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/game_detail_screen.dart';

class GameGrid extends StatelessWidget {
  final List<dynamic> games;

  GameGrid({required this.games});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final imageUrl = game['background_image'] ??
              'https://via.placeholder.com/300x200.png?text=No+Image';
          final gameName = game['name'] ?? 'Unknown Game';

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GameDetailScreen(game: game)),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 120,
                    child: Text(
                      gameName,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
