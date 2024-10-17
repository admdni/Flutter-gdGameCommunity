import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class VideosScreen extends StatefulWidget {
  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final String apiKey =
      'k8g38P38WizgZxQtcpRvo1Gh635QqtxETSWrcU5zZ9l2h82S0pN454U2'; // Pexels API anahtarınızı buraya ekleyin
  final String baseUrl = 'https://api.pexels.com/videos';

  List<dynamic> videos = [];
  bool isLoading = true;
  Map<String, bool> favoriteVideos = {};
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadFavoriteVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    try {
      final fetchedVideos = await fetchVideos();
      setState(() {
        videos = fetchedVideos;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading videos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> fetchVideos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=gamer&gaming&game&games&per_page=1000'),
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> fetchedVideos = data['videos'];
      return fetchedVideos;
    } else {
      throw Exception('Failed to load videos: ${response.statusCode}');
    }
  }

  Future<void> _loadFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteVideosJson = prefs.getString('favoriteVideos') ?? '{}';
    final Map<String, dynamic> favoriteVideosMap =
        json.decode(favoriteVideosJson);

    setState(() {
      favoriteVideos = Map.fromEntries(
          favoriteVideosMap.entries.map((entry) => MapEntry(entry.key, true)));
    });
  }

  Future<void> _toggleFavoriteVideo(Map<String, dynamic> video) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteVideosJson = prefs.getString('favoriteVideos') ?? '{}';
    final Map<String, dynamic> favoriteVideosMap =
        json.decode(favoriteVideosJson);

    final videoId = video['id'].toString();
    if (favoriteVideosMap.containsKey(videoId)) {
      favoriteVideosMap.remove(videoId);
    } else {
      favoriteVideosMap[videoId] = {
        'id': video['id'],
        'name': video['user']['name'],
        'image': video['image'],
        'url': video['video_files'][0]['link'],
      };
    }

    await prefs.setString('favoriteVideos', json.encode(favoriteVideosMap));

    setState(() {
      favoriteVideos[videoId] = !favoriteVideos.containsKey(videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Gaming Videos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: videos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoPage(
                  video: video,
                  isFavorite:
                      favoriteVideos.containsKey(video['id'].toString()),
                  onFavoriteToggle: () => _toggleFavoriteVideo(video),
                );
              },
            ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  VideoPage(
      {required this.video,
      required this.isFavorite,
      required this.onFavoriteToggle});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(widget.video['video_files'][0]['link'])
          ..initialize().then((_) {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Center(child: CircularProgressIndicator()),
        Align(
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            iconSize: 50,
            color: Colors.white.withOpacity(0.7),
            onPressed: _togglePlayPause,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video['user']['name'],
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                'Duration: ${widget.video['duration']} seconds',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 20,
          child: IconButton(
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: widget.onFavoriteToggle,
          ),
        ),
      ],
    );
  }
}
