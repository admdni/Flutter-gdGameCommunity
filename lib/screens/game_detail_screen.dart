import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../services/ api_service.dart';
import '../utils/ constants.dart';

class GameDetailScreen extends StatefulWidget {
  final Map<String, dynamic> game;

  GameDetailScreen({required this.game});

  @override
  _GameDetailScreenState createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> gameDetails = {};
  bool isFavorite = false;
  bool isLoading = true;
  String errorMessage = '';
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _loadGameDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final details =
          await _apiService.fetchGameDetails(widget.game['id'].toString());
      setState(() {
        gameDetails = details;
        isLoading = false;
      });
      _initializeFirstVideo();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load game details: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _initializeFirstVideo() {
    final trailers = (gameDetails['clip'] != null) ? [gameDetails['clip']] : [];
    if (trailers.isNotEmpty) {
      _initializeVideoPlayer(trailers[0]['clip']);
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    _videoController?.dispose();
    _chewieController?.dispose();

    _videoController = VideoPlayerController.network(videoUrl);
    try {
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
      );
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.game['id'].toString());
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (isFavorite) {
        favorites.remove(widget.game['id'].toString());
      } else {
        favorites.add(widget.game['id'].toString());
      }
      isFavorite = !isFavorite;
    });

    await prefs.setStringList('favorites', favorites);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : _buildGameDetails(),
    );
  }

  Widget _buildGameDetails() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGameTitle(),
                SizedBox(height: 16),
                _buildDescription(),
                SizedBox(height: 16),
                _buildReleaseDate(),
                SizedBox(height: 16),
                _buildPlatforms(),
                SizedBox(height: 16),
                _buildGenres(),
                SizedBox(height: 16),
                _buildRating(),
                SizedBox(height: 16),
                _buildVisitGamePageButton(),
                SizedBox(height: 16),
                _buildVideosSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.game['name'], style: TextStyle(color: TEXT_COLOR)),
        background: CachedNetworkImage(
          imageUrl: widget.game['background_image'] ?? '',
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
              color: ACCENT_COLOR),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildGameTitle() {
    return Text(
      gameDetails['name'] ?? widget.game['name'],
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: TEXT_COLOR,
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        Text(
          gameDetails['description_raw'] ?? 'No description available.',
          style: TextStyle(fontSize: 16, color: TEXT_COLOR),
        ),
      ],
    );
  }

  Widget _buildReleaseDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Release Date',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        Text(
          gameDetails['released'] ?? 'Unknown',
          style: TextStyle(fontSize: 16, color: TEXT_COLOR),
        ),
      ],
    );
  }

  Widget _buildPlatforms() {
    final platforms = gameDetails['platforms'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Platforms',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: platforms.map<Widget>((platform) {
            return Chip(
              label: Text(platform['platform']['name']),
              backgroundColor: ACCENT_COLOR,
              labelStyle: TextStyle(color: TEXT_COLOR),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenres() {
    final genres = gameDetails['genres'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Genres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: genres.map<Widget>((genre) {
            return Chip(
              label: Text(genre['name']),
              backgroundColor: ACCENT_COLOR,
              labelStyle: TextStyle(color: TEXT_COLOR),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: ACCENT_COLOR),
            SizedBox(width: 8),
            Text(
              '${gameDetails['rating'] ?? 0.0}',
              style: TextStyle(fontSize: 16, color: TEXT_COLOR),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisitGamePageButton() {
    return ElevatedButton(
      onPressed: () {
        _launchURL(gameDetails['website'] ?? '');
      },
      child: Text('Visit Game Website'),
      style: ElevatedButton.styleFrom(
        foregroundColor: TEXT_COLOR,
        backgroundColor: ACCENT_COLOR,
      ),
    );
  }

  Widget _buildVideosSection() {
    final trailers = (gameDetails['clip'] != null) ? [gameDetails['clip']] : [];
    if (trailers.isEmpty || _chewieController == null) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TEXT_COLOR,
          ),
        ),
        SizedBox(height: 8),
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      ],
    );
  }
}
