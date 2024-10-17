import 'package:flutter/material.dart';

import 'package:game_communityapp/widgets/game_carousel.dart';
import 'package:game_communityapp/screens/game_detail_screen.dart';
import 'package:game_communityapp/widgets/gamecard.dart';
import 'package:game_communityapp/screens/search_screen.dart';

import '../services/ api_service.dart';
import '../utils/ constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> trendingGames = [];
  List<dynamic> topRatedGames = [];
  List<dynamic> newestGames = [];
  bool isLoadingTrending = true;
  bool isLoadingTopRated = true;
  bool isLoadingNewest = true;
  String errorMessage = '';
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadTrendingGames();
    _loadTopRatedGames();
    _loadNewestGames();
  }

  Future<void> _loadTrendingGames() async {
    try {
      final trending = await _apiService.fetchTrendingGames();
      if (mounted) {
        setState(() {
          trendingGames = trending;
          isLoadingTrending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load trending games. Please try again.';
          isLoadingTrending = false;
        });
      }
    }
  }

  Future<void> _loadTopRatedGames() async {
    try {
      final topRated = await _apiService.fetchTopRatedGames();
      if (mounted) {
        setState(() {
          topRatedGames = topRated;
          isLoadingTopRated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load top rated games. Please try again.';
          isLoadingTopRated = false;
        });
      }
    }
  }

  Future<void> _loadNewestGames() async {
    try {
      final newest = await _apiService.fetchNewestGames();
      if (mounted) {
        setState(() {
          newestGames = newest;
          isLoadingNewest = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load newest games. Please try again.';
          isLoadingNewest = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoadingTrending = true;
      isLoadingTopRated = true;
      isLoadingNewest = true;
      errorMessage = '';
    });
    await Future.wait(
        [_loadTrendingGames(), _loadTopRatedGames(), _loadNewestGames()]);
  }

  Future<void> _loadMoreGames() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreGames = await _apiService.fetchMoreGames(_currentPage);
      if (mounted) {
        setState(() {
          trendingGames.addAll(moreGames);
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        title: Text('Game Discovery', style: TextStyle(color: TEXT_COLOR)),
        backgroundColor: BACKGROUND_COLOR,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: ACCENT_COLOR),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoadingTrending && isLoadingTopRated && isLoadingNewest) {
      return Center(child: CircularProgressIndicator(color: ACCENT_COLOR));
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Retry'),
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(backgroundColor: ACCENT_COLOR),
            ),
          ],
        ),
      );
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoadingMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreGames();
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrendingGames(),
              _buildTopRatedGames(),
              _buildNewestGames(),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTrendingGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Trending Games', style: HEADER_TEXT_STYLE),
        ),
        isLoadingTrending
            ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
            : GameCarousel(
                games: trendingGames,
                onGameTap: (game) => _navigateToGameDetail(context, game),
              ),
      ],
    );
  }

  Widget _buildTopRatedGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Top Rated Games', style: HEADER_TEXT_STYLE),
        ),
        isLoadingTopRated
            ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
            : Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topRatedGames.length,
                  itemBuilder: (context, index) {
                    return GameCard(
                      game: topRatedGames[index],
                      onTap: () =>
                          _navigateToGameDetail(context, topRatedGames[index]),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildNewestGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Newest Games', style: HEADER_TEXT_STYLE),
        ),
        isLoadingNewest
            ? Center(child: CircularProgressIndicator(color: ACCENT_COLOR))
            : Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newestGames.length,
                  itemBuilder: (context, index) {
                    return GameCard(
                      game: newestGames[index],
                      onTap: () =>
                          _navigateToGameDetail(context, newestGames[index]),
                    );
                  },
                ),
              ),
      ],
    );
  }

  void _navigateToGameDetail(BuildContext context, dynamic game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(game: game),
      ),
    );
  }
}
