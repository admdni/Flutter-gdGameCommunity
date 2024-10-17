import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/ constants.dart';
import '../widgets/video_player.dart';
import 'game_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> favoriteGames = [];
  List<Map<String, dynamic>> favoriteVideos = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteGamesJson = prefs.getString('favoriteGames') ?? '{}';
      final favoriteVideosJson = prefs.getString('favoriteVideos') ?? '{}';

      setState(() {
        favoriteGames = json
            .decode(favoriteGamesJson)
            .values
            .toList()
            .cast<Map<String, dynamic>>();
        favoriteVideos = json
            .decode(favoriteVideosJson)
            .values
            .toList()
            .cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load favorites. Please try again.');
    }
  }

  Future<void> _removeFavoriteItem(String id, bool isGame) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = isGame ? 'favoriteGames' : 'favoriteVideos';
      final jsonString = prefs.getString(key) ?? '{}';
      final Map<String, dynamic> favoritesMap = json.decode(jsonString);

      favoritesMap.remove(id);
      await prefs.setString(key, json.encode(favoritesMap));

      setState(() {
        if (isGame) {
          favoriteGames =
              favoritesMap.values.toList().cast<Map<String, dynamic>>();
        } else {
          favoriteVideos =
              favoritesMap.values.toList().cast<Map<String, dynamic>>();
        }
      });

      _showSuccessSnackBar('Item removed from favorites');
    } catch (e) {
      print('Error removing favorite item: $e');
      _showErrorSnackBar('Failed to remove item. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Games', icon: Icon(Icons.games)),
            Tab(text: 'Videos', icon: Icon(Icons.video_library)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoriteList(favoriteGames, true),
                _buildFavoriteList(favoriteVideos, false),
              ],
            ),
    );
  }

  Widget _buildFavoriteList(List<Map<String, dynamic>> items, bool isGames) {
    return items.isEmpty
        ? Center(
            child: Text('No favorite ${isGames ? 'games' : 'videos'} yet.',
                style: TextStyle(color: ON_SURFACE_COLOR)))
        : AnimationLimiter(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 2,
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: item['image'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          title: Text(item['name'],
                              style: TextStyle(
                                  color: ON_SURFACE_COLOR,
                                  fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFavoriteItem(
                                item['id'].toString(), isGames),
                          ),
                          onTap: () => isGames
                              ? _navigateToGameDetail(item)
                              : _showVideoPlayer(item),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _navigateToGameDetail(Map<String, dynamic> game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameDetailScreen(game: game)),
    );
  }

  void _showVideoPlayer(Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VideoPlayerWidget(
          videoUrl: video['url']), // Bu widget'ı oluşturmanız gerekecek
    );
  }
}
